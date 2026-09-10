shader_type canvas_item;
varying vec4 tint;
void vertex() { tint = COLOR; }
// Reversible display treatment: the imported 128px master is untouched.
void fragment() {
	vec2 pixel_uv = (floor(UV * 32.0) + vec2(0.5)) / 32.0;
	vec4 ink = texture(TEXTURE, pixel_uv);
	float gray = dot(ink.rgb, vec3(0.2126, 0.7152, 0.0722));
	ink.rgb = mix(vec3(gray), ink.rgb, 0.85) * 0.97;
	COLOR = tint * ink;
}
