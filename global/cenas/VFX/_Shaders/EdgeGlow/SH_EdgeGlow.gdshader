shader_type canvas_item;

uniform sampler2D ColorRamp : source_color;

uniform float Opacity : hint_range(0.0, 1.0) = 0.5;
uniform float Emission : hint_range(0.0, 5.0) = 2.0;
uniform float Size : hint_range(0.01, 0.5) = 0.2;
uniform float Softness : hint_range(0.01, 1.0) = 0.5;

void fragment() {
    vec2 UVCentered = UV - 0.5;

    float DistanceX = abs(UVCentered.x) * 2.0;
    float DistanceY = abs(UVCentered.y) * 2.0;

    float EdgeDistance = min(1.0 - DistanceX, 1.0 - DistanceY);

    float RampPosition = clamp(EdgeDistance / Size, 0.0, 1.0);
    vec4 RampColor = texture(ColorRamp, vec2(RampPosition, 0.5));

    float FadeStart = Size * (1.0 - Softness);
    float Glow = 1.0 - smoothstep(FadeStart, Size, EdgeDistance);

    float FinalAlpha = Glow * Opacity * RampColor.a;
    vec3 FinalColor = RampColor.rgb * Emission;

    COLOR = vec4(FinalColor, FinalAlpha);
}