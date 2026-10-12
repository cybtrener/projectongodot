shader_type spatial;


#include "res://addons/zylann.hterrain/shaders/include/heightmap.gdshaderinc"

uniform sampler2D u_terrain_heightmap;
uniform sampler2D u_terrain_colormap;
uniform sampler2D u_terrain_splatmap;

uniform sampler2D u_terrain_normalmap;
uniform sampler2D u_terrain_globalmap : source_color;
uniform mat4 u_terrain_inverse_transform;
uniform mat3 u_terrain_normal_basis;

// the reason bump is preferred with albedo is, roughness looks better with normal maps.
// If we want no normal mapping, roughness would only give flat mirror surfaces,
// while bump still allows to do depth-blending for free.
uniform sampler2D u_ground_albedo_bump_0 : source_color;
uniform sampler2D u_ground_albedo_bump_1 : source_color;
uniform sampler2D u_ground_albedo_bump_2 : source_color;
uniform sampler2D u_ground_albedo_bump_3 : source_color;

uniform sampler2D u_ground_normal_roughness_0;
uniform sampler2D u_ground_normal_roughness_1;
uniform sampler2D u_ground_normal_roughness_2;
uniform sampler2D u_ground_normal_roughness_3;

// Had to give this uniform a suffix, because it's declared as a simple float
// in other shaders, and its type cannot be inferred by the plugin.
// See https://github.com/godotengine/godot/issues/24488
uniform vec4 u_ground_uv_scale_per_texture = vec4(20.0, 20.0, 20.0, 20.0);

uniform bool u_depth_blending = true;
uniform bool u_triplanar = false;
// Each component corresponds to a ground texture. Set greater than zero to enable.
uniform vec4 u_tile_reduction = vec4(0.0, 0.0, 0.0, 0.0);

uniform float u_globalmap_blend_start;
uniform float u_globalmap_blend_distance;

uniform vec4 u_colormap_opacity_per_texture = vec4(1.0, 1.0, 1.0, 1.0);

uniform float u_specular = 0.5;

#ifdef COLORMAP_PER_VERTEX
varying float v_hole;
varying vec3 v_tint0;
varying vec3 v_tint1;
varying vec3 v_tint2;
varying vec3 v_tint3;
#endif
#ifdef SPLATMAP_PER_VERTEX
varying vec4 v_splat;
#endif
varying vec2 v_ground_uv0;
varying vec2 v_ground_uv1;
varying vec2 v_ground_uv2;
varying vec3 v_ground_uv3;
varying float v_distance_to_camera;


vec3 unpack_normal(vec4 rgba) {
	vec3 n = rgba.xzy * 2.0 - vec3(1.0);
	// Had to negate Z because it comes from Y in the normal map,
	// and OpenGL-style normal maps are Y-up.
	n.z *= -1.0;
	return n;
}

vec4 pack_normal(vec3 n, float a) {
	n.z *= -1.0;
	return vec4((n.xzy + vec3(1.0)) * 0.5, a);
}

// Blends weights according to the bump of detail textures,
// so for example it allows to have sand fill the gaps between pebbles
vec4 get_depth_blended_weights(vec4 splat, vec4 bumps) {
	float dh = 0.2;

	vec4 h = bumps + splat;

	// TODO Keep improving multilayer blending, there are still some edge cases...
	// Mitigation: nullify layers with near-zero splat
	h *= smoothstep(0, 0.05, splat);

	vec4 d = h + dh;
	d.r -= max(h.g, max(h.b, h.a));
	d.g -= max(h.r, max(h.b, h.a));
	d.b -= max(h.g, max(h.r, h.a));
	d.a -= max(h.g, max(h.b, h.r));

	return clamp(d, 0, 1);
}

vec3 get_triplanar_blend(vec3 world_normal) {
	vec3 blending = abs(world_normal);
	blending = normalize(max(blending, vec3(0.00001))); // Force weights to sum to 1.0
	float b = blending.x + blending.y + blending.z;
	return blending / vec3(b, b, b);
}

vec4 texture_triplanar(sampler2D tex, vec3 world_pos, vec3 blend) {
	vec4 xaxis = texture(tex, world_pos.yz);
	vec4 yaxis = texture(tex, world_pos.xz);
	vec4 zaxis = texture(tex, world_pos.xy);
	// blend the results of the 3 planar projections.
	return xaxis * blend.x + yaxis * blend.y + zaxis * blend.z;
}

vec4 depth_blend2(vec4 a_value, float a_bump, vec4 b_value, float b_bump, float t) {
	// https://www.gamasutra.com
	// /blogs/AndreyMishkinis/20130716/196339/Advanced_Terrain_Texture_Splatting.php
	float d = 0.1;
	float ma = max(a_bump + (1.0 - t), b_bump + t) - d;
	float ba = max(a_bump + (1.0 - t) - ma, 0.0);
	float bb = max(b_bump + t - ma, 0.0);
	return (a_value * ba + b_value * bb) / (ba + bb);
}

vec2 rotate(vec2 v, float cosa, float sina) {
	return vec2(cosa * v.x - sina * v.y, sina * v.x + cosa * v.y);
}

vec4 texture_antitile(sampler2D albedo_tex, sampler2D normal_tex, vec2 uv, out vec4 out_normal) {
	float frequency = 2.0;
	float scale = 1.3;
	float sharpness = 0.7;

	// Rotate and scale UV
	float rot = 3.14 * 0.6;
	float cosa = cos(rot);
	float sina = sin(rot);
	vec2 uv2 = rotate(uv, cosa, sina) * scale;

	vec4 col0 = texture(albedo_tex, uv);
	vec4 col1 = texture(albedo_tex, uv2);
	vec4 nrm0 = texture(normal_tex, uv);
	vec4 nrm1 = texture(normal_tex, uv2);
	//col0 = vec4(0.0, 0.5, 0.5, 1.0); // Highlights variations

	// Normals have to be rotated too since we are rotating the texture...
	// TODO Probably not the most efficient but understandable for now
	vec3 n = unpack_normal(nrm1);
	// Had to negate the Y axis for some reason. I never remember the myriad of conventions around
	n.xz = rotate(n.xz, cosa, -sina);
	nrm1 = pack_normal(n, nrm1.a);

	// Periodically alternate between the two versions using a warped checker pattern
	float t = 1.2 +
		  sin(uv2.x * frequency + sin(uv.x) * 2.0)
		* cos(uv2.y * frequency + sin(uv.y) * 2.0); // Result in [0..2]
	t = smoothstep(sharpness, 2.0 - sharpness, t);

	// Using depth blend because classic alpha blending smoothes out details.
	out_normal = depth_blend2(nrm0, col0.a, nrm1, col1.a, t);
	return depth_blend2(col0, col0.a, col1, col1.a, t);
}

void vertex() {
	vec4 wpos = MODEL_MATRIX * vec4(VERTEX, 1);
	vec2 cell_coords = (u_terrain_inverse_transform * wpos).xz;
	// Must add a half-offset so that we sample the center of pixels,
	// otherwise bilinear filtering of the textures will give us mixed results (#183)
	cell_coords += vec2(0.5);

	// Normalized UV
	UV = cell_coords / vec2(textureSize(u_terrain_heightmap, 0));

	// Height displacement
	float h = sample_heightmap(u_terrain_heightmap, UV);
	VERTEX.y = h;
	wpos.y = h;

	vec3 base_ground_uv = vec3(cell_coords.x, h * MODEL_MATRIX[1][1], cell_coords.y);
	v_ground_uv0 = base_ground_uv.xz / u_ground_uv_scale_per_texture.x;
	v_ground_uv1 = base_ground_uv.xz / u_ground_uv_scale_per_texture.y;
	v_ground_uv2 = base_ground_uv.xz / u_ground_uv_scale_per_texture.z;
	v_ground_uv3 = base_ground_uv / u_ground_uv_scale_per_texture.w;

#ifdef COLORMAP_PER_VERTEX
	// Putting this in vertex saves 2 fetches from the fragment shader,
	// which is good for performance at a negligible quality cost,
	// provided that geometry is a regular grid that decimates with LOD.
	// (downside is LOD will also decimate tint and splat, but it's not bad overall)
	vec4 tint = texture(u_terrain_colormap, UV);
	v_hole = tint.a;
	v_tint0 = mix(vec3(1.0), tint.rgb, u_colormap_opacity_per_texture.x);
	v_tint1 = mix(vec3(1.0), tint.rgb, u_colormap_opacity_per_texture.y);
	v_tint2 = mix(vec3(1.0), tint.rgb, u_colormap_opacity_per_texture.z);
	v_tint3 = mix(vec3(1.0), tint.rgb, u_colormap_opacity_per_texture.w);
#endif
#ifdef SPLATMAP_PER_VERTEX
	v_splat = texture(u_terrain_splatmap, UV);
#endif

	// Need to use u_terrain_normal_basis to handle scaling.
	NORMAL = u_terrain_normal_basis * unpack_normal(texture(u_terrain_normalmap, UV));

	v_distance_to_camera = distance(wpos.xyz, CAMERA_POSITION_WORLD);
}

uniform sampler2D tile_texture;

uniform float tiletex_scale : hint_range(1.0, 512.0) = 50.0;

uniform vec3 tile_col_0 : source_color = vec3(1,1,1);
uniform vec3 tile_col_1 : source_color = vec3(1,1,1);
uniform vec3 tile_col_2 : source_color = vec3(1,1,1);
uniform vec3 tile_col_3 : source_color = vec3(1,1,1);

uniform vec2 color_map_size = vec2(2048);

uniform float detail_strength : hint_range(0.0, 2.5) = 1.015;
uniform float detail_contrast : hint_range(0.01, 4.0) = .45;
uniform float detail_smoothness : hint_range(0.0, 1.0) = 1;
uniform float color_variation : hint_range(0.0, 0.5) = 0;
uniform float brightness : hint_range(0.1, 3.0) = 1;
uniform float contrast : hint_range(0.1, 3.0) = 1;
uniform float mask_sharpness : hint_range(0.01, 8.0) = 1.0;

vec4 sampleSmoothRGB(sampler2D tex, vec2 uv, float scale, float smoothness) {
    vec2 scaled_uv = uv * scale;
    vec2 texel = vec2(1.0) / vec2(textureSize(tex, 0));
    vec4 c  = texture(tex, scaled_uv);
    vec4 x1 = texture(tex, scaled_uv + vec2(texel.x, 0.0));
    vec4 x2 = texture(tex, scaled_uv - vec2(texel.x, 0.0));
    vec4 y1 = texture(tex, scaled_uv + vec2(0.0, texel.y));
    vec4 y2 = texture(tex, scaled_uv - vec2(0.0, texel.y));
    return mix(c, (c + x1 + x2 + y1 + y2) / 5.0, smoothness);
}

void fragment() {
	vec2 uv = UV;
	vec3 base_color = texture(u_terrain_colormap, uv).rgb;

	// Mask RGBA (splatmap)
	vec4 mask = texture(u_terrain_splatmap, uv);
	mask = pow(mask, vec4(mask_sharpness));

	// Tiles
	vec4 tiletex = texture(tile_texture, uv * tiletex_scale);
	tiletex = pow(tiletex, vec4(1.0 / detail_contrast));


	vec3 detail_mix =
	    tiletex.r * mask.r * tile_col_0 +
	    tiletex.g * mask.g * tile_col_1 +
	    tiletex.b * mask.b * tile_col_2 +
	    tiletex.a * mask.a * tile_col_3;

	vec3 blended = base_color * detail_mix * 2.;
	vec3 final_color = mix(base_color, blended, clamp(detail_strength, 0.0, 2.5));


	// =====================
	// OUTPUT
	// =====================
	ALBEDO = clamp(final_color, 0.0, 1.0);
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
	SPECULAR = 0.;
	
	ALBEDO = pow(ALBEDO * brightness, vec3(contrast));


	//vec2 uv = UV;
	//vec4 tiletex = texture(tile_texture, uv*32.);
	//vec4 mask = texture(u_terrain_splatmap, uv);
	//vec4 color_map = texture(u_terrain_colormap, uv);
//
	//mask = pow(mask, vec4(mask_sharpness));
//
	//vec4 tiletex_final = tiletex;
	//vec3 color_final = pow(color_map.rgb, vec3(2.333));
//
	//vec3 out_color = (tiletex_final.r * mask.r * tile_col_0.rgb +
						//tiletex_final.g * mask.g * tile_col_1.rgb +
						//tiletex_final.b * mask.b * tile_col_2.rgb +
						//tiletex_final.a * mask.a * tile_col_3.rgb) * color_final * 2.0;
//
//
	//ALBEDO = out_color;
}
