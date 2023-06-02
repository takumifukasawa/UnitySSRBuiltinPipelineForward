Shader "Hidden/Custom/ScreenSpaceReflection"
{
    HLSLINCLUDE
    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    // depth texture を使う場合
    // TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);
    TEXTURE2D_SAMPLER2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture);

    float _Blend;
    float _RayDepthBias;
    float _RayMaxDistance;
    float _ReflectionAdditionalRate;
    float _ReflectionRayThickness;
    float _ReflectionRayJitterSize;

    float4x4 _ViewMatrix;
    float4x4 _ViewProjectionMatrix;
    float4x4 _ProjectionMatrix;
    float4x4 _InverseViewMatrix;
    float4x4 _InverseViewProjectionMatrix;
    float4x4 _InverseProjectionMatrix;

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

    float noise(float2 seed)
    {
        return frac(sin(dot(seed, float2(12.9898, 78.233))) * 43758.5453);
    }

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

    float SampleRawDepth(float2 uv)
    {
        // 1. use depth texture
        // float rawDepth = SAMPLE_DEPTH_TEXTURE_LOD(
        //     _CameraDepthTexture,
        //     sampler_CameraDepthTexture,
        //     UnityStereoTransformScreenSpaceTex(uv),
        //     0
        // );

        // 2. use depth normal texture
        float4 cdn = SAMPLE_TEXTURE2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture, uv);
        float depth = DecodeFloatRG(cdn.zw);
        float rawDepth = InverseLinear01Depth(depth);

        return rawDepth;
    }

    float SampleRawDepthByViewPosition(float3 viewPosition, float3 offset)
    {
        // view -> clip
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

    // ------------------------------------------------------------------------------------------------

    float4 Frag(VaryingsDefault i) : SV_Target
    {
        float eps = .0001;

        float4 baseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
        float4 cachedBaseColor = baseColor;

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
        float3 incidentViewDir = normalize(viewPosition);
        float3 reflectViewDir = reflect(incidentViewDir, viewNormal);
        float3 rayViewDir = reflectViewDir;

        float3 rayViewOrigin = viewPosition;

        int maxIterationNum = 10;
        int binarySearchNum = 4;

        float rayDeltaStep = _RayMaxDistance / (float)maxIterationNum;

        float3 currentRayInView = rayViewOrigin;

        bool isHit = false;

        float jitter = noise(i.texcoord + _Time.x);

        for (int j = 0; j < maxIterationNum; j++)
        {
            currentRayInView = rayViewOrigin + rayViewDir * rayDeltaStep * (j + 1 + jitter * _ReflectionRayJitterSize);
            float sampledRawDepth = SampleRawDepthByViewPosition(currentRayInView, float3(0, 0, 0));
            float3 sampledViewPosition = ReconstructViewPositionFromDepth(i.texcoord, sampledRawDepth);

            float dist = sampledViewPosition.z - currentRayInView.z;
            if (dist > _RayDepthBias && dist < _ReflectionRayThickness)
            {
                isHit = true;
                break;
            }
        }

        if (isHit)
        {
            // stepを一回分戻す
            currentRayInView -= rayViewDir * rayDeltaStep;

            float rayBinaryStep = rayDeltaStep;
            float stepSign = 1.;

            for (int j = 0; j < binarySearchNum; j++)
            {
                // 衝突したら半分戻る。衝突していなかったら半分進む
                // 最初は stepSign が正なので半分進む
                rayBinaryStep *= 0.5 * stepSign;
                currentRayInView += rayViewDir * rayBinaryStep;

                float sampledRawDepth = SampleRawDepthByViewPosition(currentRayInView, float3(0, 0, 0));
                float3 sampledViewPosition = ReconstructViewPositionFromDepth(i.texcoord, sampledRawDepth);

                float dist = sampledViewPosition.z - currentRayInView.z;
                stepSign = dist > _RayDepthBias ? -1 : 1;
            }

            float4 currentRayInClip = mul(_ProjectionMatrix, float4(currentRayInView, 1.));
            float2 rayUV = (currentRayInClip.xy / currentRayInClip.w) * 0.5 + 0.5;
            #if UNITY_UV_STARTS_AT_TOP
            rayUV.y = 1. - rayUV.y;
            #endif
            baseColor += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, rayUV) * _ReflectionAdditionalRate;
        }

        return lerp(cachedBaseColor, baseColor, _Blend);
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
