shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float amount : hint_range(0.0, 1.0) = 1.0;

void fragment() {vec4 col = texture(screen_texture, SCREEN_UV);float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));COLOR = vec4(mix(col.rgb, vec3(gray), amount), 1.0);}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
