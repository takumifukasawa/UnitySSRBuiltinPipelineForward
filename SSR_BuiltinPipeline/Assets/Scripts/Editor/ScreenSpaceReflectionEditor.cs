using UnityEditor.Rendering.PostProcessing;

[PostProcessEditor(typeof(ScreenSpaceReflection))]
public sealed class ScreenSpaceReflectionEditor : PostProcessEffectEditor<ScreenSpaceReflection>
{
    SerializedParameterOverride m_Blend;
    SerializedParameterOverride m_RayDepthBias;
    SerializedParameterOverride m_RayMaxDistance;
    SerializedParameterOverride m_ReflectionAdditionalRate;
    SerializedParameterOverride m_ReflectionRayThickness;
    SerializedParameterOverride m_ReflectionRayJitterSize;
    SerializedParameterOverride m_ReflectionFadeMinDistance;
    SerializedParameterOverride m_ReflectionFadeMaxDistance;

    public override void OnEnable()
    {
        m_Blend = FindParameterOverride(x => x.Blend);
        m_RayDepthBias = FindParameterOverride(x => x.RayDepthBias);
        m_RayMaxDistance = FindParameterOverride(x => x.RayMaxDistance);
        m_ReflectionAdditionalRate = FindParameterOverride(x => x.ReflectionAdditionalRate);
        m_ReflectionRayThickness = FindParameterOverride(x => x.ReflectionRayThickness);
        m_ReflectionRayJitterSize = FindParameterOverride(x => x.ReflectionRayJitterSize);
        m_ReflectionFadeMinDistance = FindParameterOverride(x => x.ReflectionFadeMinDistance);
        m_ReflectionFadeMaxDistance = FindParameterOverride(x => x.ReflectionFadeMaxDistance);
    }

    public override void OnInspectorGUI()
    {
        PropertyField(m_Blend);
        PropertyField(m_RayDepthBias);
        PropertyField(m_RayMaxDistance);
        PropertyField(m_ReflectionAdditionalRate);
        PropertyField(m_ReflectionRayThickness);
        PropertyField(m_ReflectionRayJitterSize);
        PropertyField(m_ReflectionFadeMinDistance);
        PropertyField(m_ReflectionFadeMaxDistance);
    }
}
