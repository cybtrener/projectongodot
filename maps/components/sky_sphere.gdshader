shader_type spatial;

render_mode unshaded, fog_disabled;

uniform float range = 4000;
uniform sampler2D sky_texture : source_color;

void vertex() {
	vec3 cam_pos = CAMERA_POSITION_WORLD;
	vec3 scaled_vertex = VERTEX * range;

	VERTEX = scaled_vertex + cam_pos;
}

void fragment() {
	ALBEDO = texture(sky_texture, UV).rgb;
}