
shader_type spatial;
render_mode unshaded;

//Glass
uniform sampler2D ScreenTexture : filter_linear;
uniform sampler2D GlassTexture : source_color, filter_linear;
uniform vec4 MirrorColor : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float GlassStrength : hint_range(0.0, 1.0) = 0.2;
uniform float DistortionStrength : hint_range(0.0, 0.1) = 0.015;
uniform float DistortionScale : hint_range(0.1, 10.0) = 1.0;

//Wave
uniform float WaveStrength : hint_range(0.0, 0.1) = 0.01;
uniform float WaveFrequency : hint_range(1.0, 50.0) = 15.0;
uniform float WaveSpeed : hint_range(0.0, 10.0) = 2.0;

//Rings
uniform float RingStrength : hint_range(0.0, 1.0) = 0.35;
uniform float RingFrequency : hint_range(1.0, 30.0) = 5.0;
uniform float RingWidth : hint_range(0.005, 0.1) = 0.025;
uniform vec4 RingColor : source_color = vec4(0.8, 0.95, 1.0, 1.0);
uniform vec2 RingCenter = vec2(0.5, 0.5);
uniform float RingProgress = 1.0;
uniform float RingRadius : hint_range(0.1, 1.0) = 0.8;
uniform float RingDuration : hint_range(0.1, 10.0) = 2.0;

void fragment() {
    vec2 GlassUV = UV * DistortionScale;
    vec2 GlassDistortion = texture(GlassTexture, GlassUV).rg - vec2(0.5);

    vec2 MirroredUV = vec2(1.0 - UV.x, UV.y);

    float WaveX = sin(UV.y * WaveFrequency + TIME * WaveSpeed);
    float WaveY = sin(UV.x * WaveFrequency + TIME * WaveSpeed);

    MirroredUV += GlassDistortion * DistortionStrength;
    MirroredUV += vec2(WaveX, WaveY) * WaveStrength;

    vec3 CapturedImage = texture(ScreenTexture, MirroredUV).rgb;
    vec4 Glass = texture(GlassTexture, UV);
    vec3 TintedImage = CapturedImage * MirrorColor.rgb;

    //Rings
    float RingDistance = distance(UV, RingCenter);
    float CurrentRadius = RingProgress * RingRadius;
    float RingPattern = abs(fract((RingDistance - CurrentRadius) * RingFrequency) - 0.5);
    float RingMask = 1.0 - smoothstep(0.0, RingWidth * RingFrequency, RingPattern);

    RingMask *= RingStrength * RingColor.a;
    RingMask *= 1.0 - smoothstep(0.9, 1.0, RingProgress);
    RingMask *= step(0.001, RingProgress);

    vec3 FinalColor = mix(TintedImage * mix(vec3(1.0), Glass.rgb, GlassStrength), RingColor.rgb, RingMask);
    ALBEDO = FinalColor;
}