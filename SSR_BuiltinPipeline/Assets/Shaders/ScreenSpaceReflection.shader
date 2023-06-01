Shader "Hidden/Custom/ScreenSpaceReflection"
{
    HLSLINCLUDE
    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    TEXTURE2D_SAMPLER2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture);
    TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);

    float _Blend;
    float _RayDepthBias;
    float _RayMaxDistance;
    float _ReflectionAdditionalRate;
    float _ReflectionRayThickness;

    float4x4 _ViewMatrix;
    float4x4 _ViewProjectionMatrix;
    float4x4 _ProjectionMatrix;
    float4x4 _InverseViewMatrix;
    float4x4 _InverseViewProjectionMatrix;
    float4x4 _InverseProjectionMatrix;
    float _SamplingRotations[6];
    float _SamplingDistances[6];
    float _OcclusionSampleLength;
    float _OcclusionMinDistance;
    float _OcclusionMaxDistance;
    float _OcclusionBias;
    float _OcclusionStrength;
    float _OcclusionPower;
    float4 _OcclusionColor;

    // ------------------------------------------------------------------------------------------------
    // ref: UnityCG.cginc
    // ------------------------------------------------------------------------------------------------

    float DecodeFloatRG(float2 enc)
    {
        float2 kDecodeDot = float2(1.0, 1 / 255.0);
        return dot(enc, kDecodeDot);
    }

    void DecodeDepthNormal(float4 enc, out float depth, out float3 normal)
    {
        depth = DecodeFloatRG(enc.zw);
        normal = DecodeViewNormalStereo(enc);
    }

    // ------------------------------------------------------------------------------------------------

    float3 ReconstructWorldPositionFromDepth(float2 screenUV, float rawDepth)
    {
        // TODO: depthはgraphicsAPIを考慮している必要があるはず
        float4 clipPos = float4(screenUV * 2.0 - 1.0, rawDepth, 1.0);
        #if UNITY_UV_STARTS_AT_TOP
        clipPos.y = -clipPos.y;
        #endif
        float4 worldPos = mul(_InverseViewProjectionMatrix, clipPos);
        return worldPos.xyz / worldPos.w;
    }

    float3 ReconstructViewPositionFromDepth(float2 screenUV, float rawDepth)
    {
        // TODO: depthはgraphicsAPIを考慮している必要があるはず
        float4 clipPos = float4(screenUV * 2.0 - 1.0, rawDepth, 1.0);
        #if UNITY_UV_STARTS_AT_TOP
        clipPos.y = -clipPos.y;
        #endif
        float4 viewPos = mul(_InverseProjectionMatrix, clipPos);
        return viewPos.xyz / viewPos.w;
    }

    float SampleRawDepth(float2 uv)
    {
        float rawDepth = SAMPLE_DEPTH_TEXTURE_LOD(
            _CameraDepthTexture,
            sampler_CameraDepthTexture,
            UnityStereoTransformScreenSpaceTex(uv),
            0
        );
        return rawDepth;
    }

    float SampleLinear01Depth(float2 uv)
    {
        float rawDepth = SampleRawDepth(uv);
        float depth = Linear01Depth(rawDepth);
        return depth;
    }

    float InverseLinear01Depth(float d)
    {
        // Linear01Depth
        // return 1.0 / (_ZBufferParams.x * z + _ZBufferParams.y);

        // d = 1.0 / (_ZBufferParams.x * z + _ZBufferParams.y);
        // d * (_ZBufferParams.x * z + _ZBufferParams.y) = 1.0;
        // _ZBufferParams.x * z * d + _ZBufferParams.y * d = 1.0;
        // _ZBufferParams.x * z * d = 1.0 - _ZBufferParams.y * d;
        // z = (1.0 - _ZBufferParams.y * d) / (_ZBufferParams.x * d);

        return (1 - _ZBufferParams.y * d) / (_ZBufferParams.x * d);
    }

    float3x3 GetTBNMatrix(float3 viewNormal)
    {
        float3 tangent = float3(1, 0, 0);
        float3 bitangent = float3(0, 1, 0);
        float3 normal = viewNormal;
        float3x3 tbn = float3x3(tangent, bitangent, normal);
        return tbn;
    }

    float2x2 GetRotationMatrix(float rad)
    {
        float c = cos(rad);
        float s = sin(rad);
        return float2x2(c, -s, s, c);
    }

    float SampleRawDepthByViewPosition(float3 viewPosition, float3 offset)
    {
        // 1: world -> view -> clip
        // float4 offsetWorldPosition = float4(worldPosition, 1.) + offset * _OcclusionSampleLength;
        // float4 offsetViewPosition = mul(_ViewMatrix, offsetWorldPosition);
        // float4 offsetClipPosition = mul(_ViewProjectionMatrix, offsetWorldPosition);

        // 2: view -> clip
        float4 offsetViewPosition = float4(viewPosition + offset, 1.);
        float4 offsetClipPosition = mul(_ProjectionMatrix, offsetViewPosition);

        #if UNITY_UV_STARTS_AT_TOP
        offsetClipPosition.y = -offsetClipPosition.y;
        #endif

        // TODO: reverse zを考慮してあるべき？
        float2 samplingCoord = (offsetClipPosition.xy / offsetClipPosition.w) * 0.5 + 0.5;
        float samplingRawDepth = SampleRawDepth(samplingCoord);

        return samplingRawDepth;
    }

    float SampleRawDepthByWorldPosition(float3 worldPosition, float3 offset)
    {
        // 1: world -> clip
        float4 offsetWorldPosition = float4(worldPosition + offset, 1.);
        // float4 offsetViewPosition = mul(_ViewMatrix, offsetWorldPosition);
        float4 offsetClipPosition = mul(_ViewProjectionMatrix, offsetWorldPosition);

        // 2: view -> clip
        // float4 offsetViewPosition = float4(viewPosition + offset, 1.);
        // float4 offsetClipPosition = mul(_ProjectionMatrix, offsetViewPosition);

        #if UNITY_UV_STARTS_AT_TOP
        offsetClipPosition.y = -offsetClipPosition.y;
        #endif

        // TODO: reverse zを考慮してあるべき？
        float2 samplingCoord = (offsetClipPosition.xy / offsetClipPosition.w) * 0.5 + 0.5;
        float samplingRawDepth = SampleRawDepth(samplingCoord);

        return samplingRawDepth;
    }


    // ------------------------------------------------------------------------------------------------

    float4 Frag(VaryingsDefault i) : SV_Target
    {
        float eps = .0001;

        float4 color = float4(1, 1, 1, 1);

        float4 baseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
        float4 cachedBaseColor = baseColor;

        // 1. depth を depth texture から参照する場合
        // float rawDepth = SampleRawDepth(i.texcoord);
        // float depth = Linear01Depth(rawDepth);
        // return float4(depth, depth, depth, 1.);

        // 2. depth を depth normal texture から参照する場合
        float depth = 0;
        float3 viewNormal = float3(0, 0, 0);
        float4 cdn = SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture, i.texcoord);
        DecodeDepthNormal(cdn, depth, viewNormal);

        if (depth > 1. - eps)
        {
            return baseColor;
        }

        float rawDepth = InverseLinear01Depth(depth);

        float3 viewPosition = ReconstructViewPositionFromDepth(i.texcoord, rawDepth);
        // float4 worldPosition = mul(_InverseViewMatrix, float4(viewPosition, 1.));

        // float4x4 viewTranspose = transpose(_ViewMatrix);
        // float3 worldNormal = mul(viewTranspose, float4(viewNormal, 1.)).xyz;
        // test calc world normal
        // float3 worldNormal = mul((float3x3)_InverseViewMatrix, viewNormal);
        // return float4(worldNormal, 1.);

        float3 incidentViewDir = normalize(viewPosition);
        float3 reflectViewDir = reflect(incidentViewDir, viewNormal);
        float3 rayViewDir = reflectViewDir;
        // float3 incidentWorldDir = normalize(worldPosition - _WorldSpaceCameraPos);
        // float3 reflectWorldDir = reflect(incidentWorldDir, worldNormal);
        // float3 rayWorldDir = reflectWorldDir;

        float3 rayViewOrigin = viewPosition;
        // float3 rayWorldOrigin = worldPosition;

        // float cameraNearClip = _ProjectionParams.y;
        // float cameraFarClip = _ProjectionParams.y;

        float maxRayDistance = _RayMaxDistance;
        float rayLength = maxRayDistance;

        // float3 rayViewEnd = rayViewOrigin + rayViewDir * rayLength;
        // float3 rayWorldEnd = rayWorldOrigin + rayWorldDir * rayLength;

        float rayIterationNum = 20.;
        int maxIterationNum = 20;
        float rayDeltaStep = maxRayDistance / rayIterationNum;

        int binarySearchNum = 40;

        float3 currentRayInView = rayViewOrigin;
        // float3 currentRayInWorld = rayWorldOrigin;

        bool isHit = false;

        for (int j = 0; j < maxIterationNum; j++)
        {
            currentRayInView += rayViewDir * rayDeltaStep;
            // currentRayInWorld += rayWorldDir * rayDeltaStep;

            // 1. view
            float sampledRawDepth = SampleRawDepthByViewPosition(currentRayInView, float3(0, 0, 0));
            // 2. world
            // float sampledRawDepth = SampleRawDepthByWorldPosition(currentRayInWorld, float3(0, 0, 0));
            float3 sampledViewPosition = ReconstructViewPositionFromDepth(i.texcoord, sampledRawDepth);
            // float3 sampledWorldPosition = mul(_InverseViewMatrix, float4(sampledViewPosition, 1.)).xyz;

            // 1. view
            float dist = sampledViewPosition.z - currentRayInView.z;
            if (dist > _RayDepthBias && dist < _ReflectionRayThickness)
            // 2. world
            // float dist = currentRayInWorld.z - sampledWorldPosition.z;
            // if(dist > eps && dist < _ReflectionRayThickness)
            // if (sampledWorldPosition.z < currentRayInWorld.z)
            {
                isHit = true;
                break;
            }
        }

        if (isHit)
        {
            float halfStep = rayDeltaStep;
            float stepSign = -1;
            for (int j = 0; j < binarySearchNum; j++)
            {
                halfStep *= 0.5 * stepSign;
                float binaryStep = halfStep / (float)binarySearchNum;
                currentRayInView += halfStep;

                // 1. view
                float sampledRawDepth = SampleRawDepthByViewPosition(currentRayInView, float3(0, 0, 0));
                // 2. world
                // float sampledRawDepth = SampleRawDepthByWorldPosition(currentRayInWorld, float3(0, 0, 0));
                float3 sampledViewPosition = ReconstructViewPositionFromDepth(i.texcoord, sampledRawDepth);

                float dist = sampledViewPosition.z - currentRayInView.z;
                if (dist > _RayDepthBias && dist < _ReflectionRayThickness)
                // if (dist > _RayDepthBias)
                {
                    stepSign = -1;
                } else
                {
                    stepSign = 1;
                }
            }

            float4 currentRayInClip = mul(_ProjectionMatrix, float4(currentRayInView, 1.));
            // float4 currentRayInClip = mul(_ViewProjectionMatrix, float4(currentRayInWorld, 1.));
            float2 rayUV = (currentRayInClip.xy / currentRayInClip.w) * 0.5 + 0.5;
            #if UNITY_UV_STARTS_AT_TOP
            rayUV.y = 1. - rayUV.y;
            #endif
            baseColor += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, rayUV) * _ReflectionAdditionalRate;
        }

        // mask exists depth
        // if (depth > 1. - eps)
        // {
        //     return baseColor;
        // }

        // return float4(worldPosition.xyz, 1.);
        // return float4(worldPosition.y, 1, 1, 1.);
        // return float4(viewPosition, 1.);
        // return float4(rayViewOrigin.xy, 1, 1);
        // return float4(-rayViewOrigin.z, 0, 0, 1);

        // return float4(-viewPosition.z * .05, 0, 0, 1.);

        return lerp(cachedBaseColor, baseColor, _Blend);


        // -------------------------------------------------------------

        float occludedAcc = 0.;
        int samplingCount = 6;

        for (int j = 0; j < samplingCount; j++)
        {
            float2x2 rot = GetRotationMatrix(_SamplingRotations[j]);
            float offsetLen = _SamplingDistances[j] * _OcclusionSampleLength;
            float3 offsetA = float3(mul(rot, float2(1, 0)), 0.) * offsetLen;
            float3 offsetB = -offsetA;

            float rawDepthA = SampleRawDepthByViewPosition(viewPosition, offsetA);
            float rawDepthB = SampleRawDepthByViewPosition(viewPosition, offsetB);

            float depthA = Linear01Depth(rawDepthA);
            float depthB = Linear01Depth(rawDepthB);

            float3 viewPositionA = ReconstructViewPositionFromDepth(i.texcoord, rawDepthA);
            float3 viewPositionB = ReconstructViewPositionFromDepth(i.texcoord, rawDepthB);

            float distA = distance(viewPositionA, viewPosition);
            float distB = distance(viewPositionB, viewPosition);

            if (abs(depth - depthA) < _OcclusionBias)
            {
                continue;
            }
            if (abs(depth - depthB) < _OcclusionBias)
            {
                continue;
            }

            if (distA < _OcclusionMinDistance || _OcclusionMaxDistance < distA)
            {
                continue;
            }
            if (distB < _OcclusionMinDistance || _OcclusionMaxDistance < distB)
            {
                continue;
            }

            // pattern_1: calc angle by view z
            // float tanA = (viewPositionA.z - viewPosition.z) / distance(viewPositionA.xy, viewPosition.xy);
            // float tanB = (viewPositionB.z - viewPosition.z) / distance(viewPositionB.xy, viewPosition.xy);
            // float angleA = atan(tanA);
            // float angleB = atan(tanB);
            // float ao = min((angleA + angleB) / PI, 1.);

            // pattern_2: compare with surface to camera
            float3 surfaceToCameraDir = -normalize(viewPosition);
            float dotA = dot(normalize(viewPositionA - viewPosition), surfaceToCameraDir);
            float dotB = dot(normalize(viewPositionB - viewPosition), surfaceToCameraDir);
            float ao = (dotA + dotB) * .5;

            occludedAcc += ao;
        }

        float aoRate = occludedAcc / (float)samplingCount;

        // NOTE: 本当は環境光のみにAO項を考慮するのがよいが、forward x post process の場合は全体にかけちゃう
        color.rgb = lerp(
            baseColor,
            _OcclusionColor,
            saturate(pow(saturate(aoRate), _OcclusionPower) * _OcclusionStrength)
        );

        color.rgb = lerp(baseColor, color.rgb, _Blend);

        color.a = 1;
        return color;
    }
    ENDHLSL
    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            HLSLPROGRAM
            #pragma vertex VertDefault
            #pragma fragment Frag
            ENDHLSL
        }
    }
}