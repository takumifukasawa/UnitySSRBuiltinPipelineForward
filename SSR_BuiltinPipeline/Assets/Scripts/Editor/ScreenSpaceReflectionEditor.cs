using UnityEditor.Rendering.PostProcessing;

[PostProcessEditor(typeof(ScreenSpaceReflection))]
public sealed class ScreenSpaceReflectionEditor : PostProcessEffectEditor<ScreenSpaceReflection>
{
    SerializedParameterOverride m_Blend;
    SerializedParameterOverride m_RayDepthBias;
    SerializedParameterOverride m_RayMaxDistance;
    SerializedParameterOverride m_ReflectionAdditionalRate;
    SerializedParameterOverride m_ReflectionRayThickness;

    public override void OnEnable()
    {
        m_Blend = FindParameterOverride(x => x.Blend);
        m_RayDepthBias = FindParameterOverride(x => x.RayDepthBias);
        m_RayMaxDistance = FindParameterOverride(x => x.RayMaxDistance);
        m_ReflectionAdditionalRate = FindParameterOverride(x => x.ReflectionAdditionalRate);
        m_ReflectionRayThickness = FindParameterOverride(x => x.ReflectionRayThickness);
    }

    public override void OnInspectorGUI()
    {
        PropertyField(m_Blend);
        PropertyField(m_RayDepthBias);
        PropertyField(m_RayMaxDistance);
        PropertyField(m_ReflectionAdditionalRate);
        PropertyField(m_ReflectionRayThickness);
    }
}
