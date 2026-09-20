shader_type spatial;

render_mode unshaded, blend_mix, depth_draw_never;

uniform float WaveStartTime;
uniform float WaveRadius = 5.0;

uniform float ExpansionSpeed = 1.0;
uniform float MaxExpansion = 2.0;
uniform float FadeSpeed = 1.0;

uniform float ExpansionOffset = 0.7;

// Cor da linha
uniform vec4 LineColor : source_color = vec4(1.0, 1.0, 1.0, 1.0);

varying float ColorPosition;

void vertex()
{
	float Age = max(
		TIME - WaveStartTime + ExpansionOffset,
		0.0
	);

	float ExpansionProgress = clamp(
		Age * ExpansionSpeed,
		0.0,
		1.0
	);

	float Expansion = mix(
		1.0,
		MaxExpansion,
		ExpansionProgress
	);

	VERTEX.x *= Expansion;
	VERTEX.z *= Expansion;

	// Calcula a posição da linha em relação ao centro
	ColorPosition = length(VERTEX.xz) / (WaveRadius * MaxExpansion);
}

void fragment()
{
	float Age = max(
		TIME - WaveStartTime,
		0.0
	);

	float Fade = 1.0 - clamp(
		Age * FadeSpeed,
		0.0,
		1.0
	);

	// Posição normalizada para determinar a cor
	float RGBPosition = clamp(
		ColorPosition,
		0.0,
		1.0
	);

	// RGB completo baseado na posição
	vec3 RGBColor = vec3(
		sin(RGBPosition * TAU) * 0.5 + 0.5,
		sin(RGBPosition * TAU + 2.094) * 0.5 + 0.5,
		sin(RGBPosition * TAU + 4.188) * 0.5 + 0.5
	);

	ALBEDO = RGBColor;
	ALPHA = LineColor.a * Fade;
}