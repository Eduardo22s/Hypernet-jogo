
shader_type spatial;
render_mode unshaded, blend_add,
    depth_draw_never, cull_disabled;

uniform sampler2D color_ramp : source_color;

// Quantidade de linhas
uniform float line_count = 4.0;

// Espessura das fitas
uniform float line_width = 0.025;

// Velocidade de subida
uniform float wind_speed = 0.52;

// Intensidade das curvas
uniform float wave_strength = 0.08;

// Quantidade de ondulações
uniform float wave_frequency = 3.0;

// Intensidade do brilho
uniform float brightness = 30.0;

// Transparência geral
uniform float opacity = 0.5;

// Variação entre azul e branco
uniform float color_variation = 0.5;

// Normal local da superfície
varying vec3 local_normal;

void vertex() {
    local_normal = NORMAL;
}

void fragment() {

    // Descarta as faces superior e inferior
    if (abs(normalize(local_normal).y) > 0.9) {
        discard;
    }

    vec2 uv = UV;

    // Movimento vertical contínuo
    float flow = uv.y + TIME * wind_speed;

    // Cria várias linhas distribuídas
    float line_id = floor(uv.x * line_count);

    float random_offset =
        fract(sin(line_id * 127.1) * 43758.5453);

    // Posição central de cada fita
    float base_x =
        (line_id + 0.5) / line_count;

    // Movimento sinuoso
    float wave =
        sin(flow * wave_frequency * 6.28318
        + line_id * 2.1
        + random_offset * 6.28);

    float wave2 =
        sin(flow * wave_frequency * 3.1
        - line_id * 1.7);

    float center_x =
        base_x
        + wave * wave_strength
        + wave2 * wave_strength * 0.35;

    // Distância da linha
    float distance_line =
        abs(uv.x - center_x);

    // Espessura suave
    float ribbon =
        1.0 - smoothstep(
            line_width * 0.35,
            line_width,
            distance_line
        );

    // Variação de intensidade ao longo da altura
    float pulse =
        0.65 + 0.35 *
        sin(flow * 18.0 + line_id);

    // Desvanecimento nas extremidades
    float fade =
        smoothstep(0.0, 0.12, uv.y)
        * (1.0 - smoothstep(0.82, 1.0, uv.y));

	// Amostra as cores do Color Ramp
	vec3 wind_color =
    texture(color_ramp, vec2(random_offset, 0.5)).rgb;

    // Brilho
    float glow = ribbon * pulse;

    ALBEDO = wind_color * glow * brightness;

    // Transparência
    ALPHA =
        glow
        * fade
        * opacity;
}