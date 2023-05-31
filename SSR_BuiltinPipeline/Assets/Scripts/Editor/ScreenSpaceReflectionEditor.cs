using UnityEditor.Rendering.PostProcessing;

[PostProcessEditor(typeof(ScreenSpaceReflection))]
public sealed class ScreenSpaceReflectionEditor : PostProcessEffectEditor<ScreenSpaceReflection>
{
    SerializedParameterOverride m_Blend;
    SerializedParameterOverride m_RayDepthBias;
    SerializedParameterOverride m_RayMaxDistance;
    SerializedParameterOverride m_ReflectionAdditionalRate;
    SerializedParameterOverride m_ReflectionRayThickness;

    SerializedParameterOverride m_OcclusionSampleLength;
    SerializedParameterOverride m_OcclusionMinDistance;
    SerializedParameterOverride m_OcclusionMaxDistance;
    SerializedParameterOverride m_OcclusionBias;
    SerializedParameterOverride m_OcclusionStrength;
    SerializedParameterOverride m_OcclusionPower;
    SerializedParameterOverride m_OcclusionColor;

    public override void OnEnable()
    {
        m_Blend = FindParameterOverride(x => x.Blend);
        m_RayDepthBias = FindParameterOverride(x => x.RayDepthBias);
        m_RayMaxDistance = FindParameterOverride(x => x.RayMaxDistance);
        m_ReflectionAdditionalRate = FindParameterOverride(x => x.ReflectionAdditionalRate);
        m_ReflectionRayThickness = FindParameterOverride(x => x.ReflectionRayThickness);
        
        m_OcclusionSampleLength = FindParameterOverride(x => x.OcclusionSampleLength);
        m_OcclusionMinDistance = FindParameterOverride(x => x.OcclusionMinDistance);
        m_OcclusionMaxDistance = FindParameterOverride(x => x.OcclusionMaxDistance);
        m_OcclusionBias = FindParameterOverride(x => x.OcclusionBias);
        m_OcclusionStrength = FindParameterOverride(x => x.OcclusionStrength);
        m_OcclusionPower = FindParameterOverride(x => x.OcclusionPower);
        m_OcclusionColor = FindParameterOverride(x => x.OcclusionColor);
    }

    public override void OnInspectorGUI()
    {
        PropertyField(m_Blend);
        PropertyField(m_RayDepthBias);
        PropertyField(m_RayMaxDistance);
        PropertyField(m_ReflectionAdditionalRate);
        PropertyField(m_ReflectionRayThickness);
        
        PropertyField(m_OcclusionSampleLength);
        PropertyField(m_OcclusionMinDistance);
        PropertyField(m_OcclusionMaxDistance);
        PropertyField(m_OcclusionBias);
        PropertyField(m_OcclusionStrength);
        PropertyField(m_OcclusionPower);
        PropertyField(m_OcclusionColor);
    }
}
