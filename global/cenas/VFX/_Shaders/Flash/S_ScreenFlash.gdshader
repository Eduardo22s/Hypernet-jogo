
shader_type canvas_item;
render_mode unshaded;

uniform vec4 FlashColor : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float Progress : hint_range(0.0, 1.0) = 0.0;
uniform float Softness : hint_range(0.001, 0.5) = 0.04;
uniform float MaxRadius : hint_range(0.1, 2.0) = 1.2;

uniform float PixelSize : hint_range(2.0, 64.0) = 10.0;
uniform float Fragmentation : hint_range(0.0, 1.0) = 0.7;

float Hash(float Value) {
    return fract(sin(Value * 127.1 + 311.7) * 43758.5453123);
}

void fragment() {
    vec2 PixelCount = 1.0 / (SCREEN_PIXEL_SIZE * PixelSize);
    vec2 PixelUV = (floor(UV * PixelCount) + vec2(0.5)) / PixelCount;

    vec2 CenteredUV = PixelUV - vec2(0.5);
    CenteredUV.x *= SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;

    float DistanceFromCenter = length(CenteredUV);
    float Angle = atan(CenteredUV.y, CenteredUV.x);

    float AngleSteps = 48.0;
    float AngleIndex = floor((Angle + PI) * AngleSteps / (2.0 * PI));
    float Jaggedness = (Hash(AngleIndex) - 0.5) * Fragmentation;

    float Radius = Progress * MaxRadius;
    float JaggedRadius = Radius * (1.0 + Jaggedness);

    float FlashMask = 1.0 - smoothstep(JaggedRadius - Softness, JaggedRadius + Softness, DistanceFromCenter);

    if (Progress <= 0.0) {
        FlashMask = 0.0;
    }

    COLOR = vec4(FlashColor.rgb, FlashColor.a * FlashMask);
}