// NOTE: Shader automatically converted from Godot Engine 4.5.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_emissive : source_color, filter_linear_mipmap, repeat_enable;
uniform ivec2 albedo_texture_size;
uniform float contrast = 1;
uniform bool emissive;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	
	if(!emissive){
		ALBEDO = albedo.rgb * albedo_tex.rgb;
	}else{
		vec4 emissive_tex = texture(texture_emissive, UV);
		ALBEDO = albedo.rgb * albedo_tex.rgb;
		EMISSION = albedo.rgb * emissive_tex.rgb;
	}
	
	ALBEDO = pow(ALBEDO, vec3(contrast));
	
	METALLIC = 0.;
	SPECULAR = 0.;
	
	ROUGHNESS = 1.;
}
