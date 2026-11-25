shader_type canvas_item;

uniform sampler2D ScreenTexture : hint_screen_texture, repeat_disable, filter_linear;
uniform sampler2D ColorRamp : source_color, repeat_disable;

uniform float EffectProgress : hint_range(0.0, 1.0) = 0.0;
uniform float FadeOut : hint_range(0.0, 1.0) = 0.3;

uniform float GlitchSize : hint_range(1.0, 100.0) = 20.0;
uniform float GlitchIntensity : hint_range(0.0, 1.0) = 0.5;
uniform float RGBSplit : hint_range(0.0, 0.1) = 0.015;
uniform float NoiseStrength : hint_range(0.0, 1.0) = 0.15;
uniform float BlockDensity : hint_range(1.0, 100.0) = 30.0;
uniform float Speed : hint_range(0.1, 20.0) = 8.0;

float Random(float Value) {
    return fract(sin(Value * 127.1) * 43758.5453);
}

void fragment() {
    vec2 ScreenUV = SCREEN_UV;

    float Fade = 1.0 - smoothstep(1.0 - FadeOut, 1.0, EffectProgress);

    float TimeStep = floor(EffectProgress * Speed * 100.0);

    float Block = floor(ScreenUV.y * BlockDensity);
    float RandomValue = Random(Block + TimeStep * 13.0);

    float Glitch = step(1.0 - GlitchIntensity, RandomValue) * Fade;

    float Offset = (RandomValue - 0.5) * GlitchSize * 0.001 * Glitch;

    vec2 DistortedUV = vec2(
        clamp(ScreenUV.x + Offset, 0.001, 0.999),
        ScreenUV.y
    );

    float RGBOffset = RGBSplit * Glitch;

    vec3 ScreenColor;

    ScreenColor.r = texture(ScreenTexture, DistortedUV + vec2(RGBOffset, 0.0)).r;
    ScreenColor.g = texture(ScreenTexture, DistortedUV).g;
    ScreenColor.b = texture(ScreenTexture, DistortedUV - vec2(RGBOffset, 0.0)).b;

    float Noise = Random(
        floor(DistortedUV.x * 1000.0) +
        floor(DistortedUV.y * 1000.0) +
        TimeStep
    );

    ScreenColor += (Noise - 0.5) * NoiseStrength * Glitch;

    // ColorRamp controla apenas as interferências.
    vec3 RampColor = texture(ColorRamp, vec2(Noise, 0.5)).rgb;

    float Interference = clamp(Glitch * NoiseStrength, 0.0, 1.0);

    ScreenColor = mix(ScreenColor, RampColor, Interference);

    COLOR = vec4(ScreenColor, 1.0);
}