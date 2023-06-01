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
    [Range(0f, 100f), Tooltip("ray max distance")]
    public FloatParameter RayMaxDistance = new FloatParameter { value = 100f };

    [FormerlySerializedAs("reflection additional rate")]
    [Range(0f, 1f), Tooltip("reflection additional rate")]
    public FloatParameter ReflectionAdditionalRate = new FloatParameter { value = 0.5f };

    [FormerlySerializedAs("reflection ray thickness")]
    [Range(0f, 10f), Tooltip("reflection ray thickness")]
    public FloatParameter ReflectionRayThickness = new FloatParameter { value = 1f };
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

        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}