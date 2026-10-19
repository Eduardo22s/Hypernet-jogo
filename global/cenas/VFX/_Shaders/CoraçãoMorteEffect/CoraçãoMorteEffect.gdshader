
shader_type canvas_item;
render_mode unshaded;

uniform float FlashAmount : hint_range(0.0, 1.0) = 0.0; //Intensidade do Flash Branco
uniform float MeltProgress : hint_range(0.0, 1.0) = 0.0; //Progresso da morte

uniform vec4 FlashColor : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float FlashColorMix : hint_range(0.0, 1.0) = 0.7;//Quanto o branco vai se misturar às cores

//Definem o padrão de faixas e blocos
uniform float StripCount : hint_range(4.0, 128.0, 1.0) = 32.0; //Maior = mais faixas
uniform float BlockSize : hint_range(0.005, 0.1) = 0.025; //Menor = faixas mais finas

uniform float GlitchStrength : hint_range(0.0, 0.2) = 0.035; //Distorção horizontal
uniform float MeltVariation : hint_range(0.0, 1.0) = 0.8; //Faz diferentes faixas terem diferentes velocidades
uniform float MeltDistance : hint_range(0.0, 2000.0) = 700.0;
uniform float DissolveStrength : hint_range(0.0, 1.0) = 0.65; //Irregularidade do desaparecimento

varying vec2 OriginalUV;

float RandomValue(float Value) {
    return fract(sin(Value * 127.1 + 311.7) * 43758.5453);
}

void vertex() {
    OriginalUV = UV;
}

void fragment() {
    vec2 SampleUV = OriginalUV;

    float Column = floor(OriginalUV.x * StripCount);
    float BlockRow = floor(OriginalUV.y / BlockSize);

    float ColumnRandom = RandomValue(Column);
    float BlockRandom = RandomValue(Column * 17.0 + BlockRow);

    float LocalDrop = MeltProgress * (1.0 - MeltVariation + ColumnRandom * MeltVariation);

    float GlitchActive = step(0.65, BlockRandom) * (1.0 - MeltProgress);

    SampleUV.x += (BlockRandom - 0.5) * GlitchStrength * GlitchActive;
    SampleUV.y -= LocalDrop;

    bool OutsideTexture = SampleUV.x < 0.0 || SampleUV.x > 1.0 || SampleUV.y < 0.0 || SampleUV.y > 1.0;

    vec4 OriginalColor = texture(TEXTURE, clamp(SampleUV, vec2(0.0), vec2(1.0)));

    if (OutsideTexture) {
        OriginalColor.a = 0.0;
    }

    OriginalColor.rgb = mix(OriginalColor.rgb, FlashColor.rgb, FlashAmount * FlashColorMix);



    float DissolveRandom = RandomValue(Column * 31.0 + BlockRow * 7.0);
    float DissolveThreshold = MeltProgress * DissolveStrength;
    float DissolveValue = DissolveRandom + OriginalUV.y * 0.25;

    float DissolveMask = smoothstep(
        DissolveThreshold - 0.12,
        DissolveThreshold + 0.12,
        DissolveValue
    );

    float GradualFade = 1.0 - smoothstep(0.65, 1.0, MeltProgress);

    OriginalColor.a *= DissolveMask * GradualFade;

    COLOR = OriginalColor;
}