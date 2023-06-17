using UnityEditor.Rendering.PostProcessing;

[PostProcessEditor(typeof(ScreenSpaceReflection))]
public sealed class ScreenSpaceReflectionEditor : PostProcessEffectEditor<ScreenSpaceReflection>
{
    SerializedParameterOverride m_Blend;
    SerializedParameterOverride m_RayDepthBias;
    private SerializedParameterOverride m_RayNearestDistance;
    SerializedParameterOverride m_RayMaxDistance;
    SerializedParameterOverride m_ReflectionAdditionalRate;
    SerializedParameterOverride m_ReflectionRayThickness;
    SerializedParameterOverride m_ReflectionRayJitterSizeX;
    SerializedParameterOverride m_ReflectionRayJitterSizeY;
    SerializedParameterOverride m_ReflectionFadeMinDistance;
    SerializedParameterOverride m_ReflectionFadeMaxDistance;
    SerializedParameterOverride m_ReflectionScreenEdgeFadeFactorMinX;
    SerializedParameterOverride m_ReflectionScreenEdgeFadeFactorMaxX;
    SerializedParameterOverride m_ReflectionScreenEdgeFadeFactorMinY;
    SerializedParameterOverride m_ReflectionScreenEdgeFadeFactorMaxY;

    public override void OnEnable()
    {
        m_Blend = FindParameterOverride(x => x.Blend);
        m_RayDepthBias = FindParameterOverride(x => x.RayDepthBias);
        m_RayNearestDistance = FindParameterOverride(x => x.RayNearestDistance);
        m_RayMaxDistance = FindParameterOverride(x => x.RayMaxDistance);
        m_ReflectionAdditionalRate = FindParameterOverride(x => x.ReflectionAdditionalRate);
        m_ReflectionRayThickness = FindParameterOverride(x => x.ReflectionRayThickness);
        m_ReflectionRayJitterSizeX = FindParameterOverride(x => x.ReflectionRayJitterSizeX);
        m_ReflectionRayJitterSizeY = FindParameterOverride(x => x.ReflectionRayJitterSizeY);
        m_ReflectionFadeMinDistance = FindParameterOverride(x => x.ReflectionFadeMinDistance);
        m_ReflectionFadeMaxDistance = FindParameterOverride(x => x.ReflectionFadeMaxDistance);
        m_ReflectionScreenEdgeFadeFactorMinX = FindParameterOverride(x => x.ReflectionScreenEdgeFadeFactorMinX);
        m_ReflectionScreenEdgeFadeFactorMaxX = FindParameterOverride(x => x.ReflectionScreenEdgeFadeFactorMaxX);
        m_ReflectionScreenEdgeFadeFactorMinY = FindParameterOverride(x => x.ReflectionScreenEdgeFadeFactorMinY);
        m_ReflectionScreenEdgeFadeFactorMaxY = FindParameterOverride(x => x.ReflectionScreenEdgeFadeFactorMaxY);
    }

    public override void OnInspectorGUI()
    {
        PropertyField(m_Blend);
        PropertyField(m_RayDepthBias);
        PropertyField(m_RayNearestDistance);
        PropertyField(m_RayMaxDistance);
        PropertyField(m_ReflectionAdditionalRate);
        PropertyField(m_ReflectionRayThickness);
        PropertyField(m_ReflectionRayJitterSizeX);
        PropertyField(m_ReflectionRayJitterSizeY);
        PropertyField(m_ReflectionFadeMinDistance);
        PropertyField(m_ReflectionFadeMaxDistance);
        PropertyField(m_ReflectionScreenEdgeFadeFactorMinX);
        PropertyField(m_ReflectionScreenEdgeFadeFactorMaxX);
        PropertyField(m_ReflectionScreenEdgeFadeFactorMinY);
        PropertyField(m_ReflectionScreenEdgeFadeFactorMaxY);
    }
}
