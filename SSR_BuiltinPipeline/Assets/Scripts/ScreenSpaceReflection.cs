using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using UnityEngine.Serialization;

[Serializable]
[PostProcess(typeof(ScreenSpaceReflectionRenderer), PostProcessEvent.AfterStack, "Custom/ScreenSpaceReflection")]
public sealed class ScreenSpaceReflection : PostProcessEffectSettings
{
    [FormerlySerializedAs("blend")]
    [Range(0f, 1f), Tooltip("SSAO effect intensity.")]
    public FloatParameter Blend = new FloatParameter { value = 0.5f };

    [FormerlySerializedAs("ray depth bias")]
    [Range(0f, 0.1f), Tooltip("ray depth bias")]
    public FloatParameter RayDepthBias = new FloatParameter { value = 0.001f };

    [FormerlySerializedAs("ray max distance")]
    [Range(0f, 20f), Tooltip("ray max distance")]
    public FloatParameter RayMaxDistance = new FloatParameter { value = 100f };

    [FormerlySerializedAs("reflection additional rate")]
    [Range(0f, 1f), Tooltip("reflection additional rate")]
    public FloatParameter ReflectionAdditionalRate = new FloatParameter { value = 0.5f };

    [FormerlySerializedAs("reflection ray thickness")]
    [Range(0f, 50f), Tooltip("reflection ray thickness")]
    public FloatParameter ReflectionRayThickness = new FloatParameter { value = 1f };
    
    [FormerlySerializedAs("reflection ray jitter size")]
    [Range(0f, 10f), Tooltip("reflection ray jitter size")]
    public FloatParameter ReflectionRayJitterSize = new FloatParameter { value = 1f };
    
    [FormerlySerializedAs("reflection fade min distance")]
    [Range(0f, 50f), Tooltip("reflection fade min distance")]
    public FloatParameter ReflectionFadeMinDistance = new FloatParameter { value = 1f };
    
    [FormerlySerializedAs("reflection fade max distance")]
    [Range(0f, 50f), Tooltip("reflection fade max distance")]
    public FloatParameter ReflectionFadeMaxDistance = new FloatParameter { value = 2f };
    
    [FormerlySerializedAs("reflection screen edge fade factor min x")]
    [Range(0f, 1f), Tooltip("reflection screen edge fade factor min x")]
    public FloatParameter ReflectionScreenEdgeFadeFactorMinX = new FloatParameter { value = 0.9f };
    
    [FormerlySerializedAs("reflection screen edge fade factor max x")]
    [Range(0f, 1f), Tooltip("reflection screen edge fade factor max x")]
    public FloatParameter ReflectionScreenEdgeFadeFactorMaxX = new FloatParameter { value = 1f };
    
    [FormerlySerializedAs("reflection screen edge fade factor min y")]
    [Range(0f, 1f), Tooltip("reflection screen edge fade factor min y")]
    public FloatParameter ReflectionScreenEdgeFadeFactorMinY = new FloatParameter { value = 0.9f };
    
    [FormerlySerializedAs("reflection screen edge fade factor max y")]
    [Range(0f, 1f), Tooltip("reflection screen edge fade factor max y")]
    public FloatParameter ReflectionScreenEdgeFadeFactorMaxY = new FloatParameter { value = 1f };
}

public sealed class ScreenSpaceReflectionRenderer : PostProcessEffectRenderer<ScreenSpaceReflection>
{
    /// <summary>
    /// 
    /// </summary>
    /// <param name="context"></param>
    public override void Render(PostProcessRenderContext context)
    {
        var viewMatrix = Camera.main.worldToCameraMatrix;
        var inverseViewMatrix = Camera.main.cameraToWorldMatrix;
        var projectionMatrix = GL.GetGPUProjectionMatrix(Camera.main.projectionMatrix, true);
        var viewProjectionMatrix = projectionMatrix * viewMatrix;
        var inverseViewProjectionMatrix = viewProjectionMatrix.inverse;
        var inverseProjectionMatrix = projectionMatrix.inverse;

        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/ScreenSpaceReflection"));
        sheet.properties.SetFloat("_Blend", settings.Blend);

        sheet.properties.SetMatrix("_ViewMatrix", viewMatrix);
        sheet.properties.SetMatrix("_ViewProjectionMatrix", viewProjectionMatrix);
        sheet.properties.SetMatrix("_ProjectionMatrix", projectionMatrix);
        sheet.properties.SetMatrix("_InverseProjectionMatrix", inverseProjectionMatrix);
        sheet.properties.SetMatrix("_InverseViewProjectionMatrix", inverseViewProjectionMatrix);
        sheet.properties.SetMatrix("_InverseViewMatrix", inverseViewMatrix);

        sheet.properties.SetFloat("_RayDepthBias", settings.RayDepthBias);
        sheet.properties.SetFloat("_RayMaxDistance", settings.RayMaxDistance);
        sheet.properties.SetFloat("_ReflectionAdditionalRate", settings.ReflectionAdditionalRate);
        sheet.properties.SetFloat("_ReflectionRayThickness", settings.ReflectionRayThickness);
        sheet.properties.SetFloat("_ReflectionRayJitterSize", settings.ReflectionRayJitterSize);
        sheet.properties.SetFloat("_ReflectionFadeMinDistance", settings.ReflectionFadeMinDistance);
        sheet.properties.SetFloat("_ReflectionFadeMaxDistance", settings.ReflectionFadeMaxDistance);
        sheet.properties.SetFloat("_ReflectionScreenEdgeFadeFactorMinX", settings.ReflectionScreenEdgeFadeFactorMinX);
        sheet.properties.SetFloat("_ReflectionScreenEdgeFadeFactorMaxX", settings.ReflectionScreenEdgeFadeFactorMaxX);
        sheet.properties.SetFloat("_ReflectionScreenEdgeFadeFactorMinY", settings.ReflectionScreenEdgeFadeFactorMinY);
        sheet.properties.SetFloat("_ReflectionScreenEdgeFadeFactorMaxY", settings.ReflectionScreenEdgeFadeFactorMaxY);

        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}
