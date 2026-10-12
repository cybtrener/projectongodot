shader_type spatial;
//render_mode blend_add;

uniform sampler2D mainTexture;
uniform vec2 shift1 = vec2(.007, .007);
uniform vec2 shift2 = vec2(.04,.04);
uniform vec3 albedo_color : source_color = vec3(1,1,1);
//uniform float alpha = .5;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv1 = UV + shift1 * TIME;
	vec2 uv2 = vec2(uv1.x + uv1.y, uv1.x - uv1.y) + shift2 * TIME;
	
	//varTexCoord0 = inTexCoord0 * normal0Scale + normal0ShiftPerSecond * globalTime;
    //varTexCoord1 = vec2(inTexCoord0.x+inTexCoord0.y, inTexCoord0.x-inTexCoord0.y) * normal1Scale + normal1ShiftPerSecond * globalTime;
	
	vec4 tex1 = texture(mainTexture, uv1);
	vec4 tex2 = texture(mainTexture, uv2);
	
	ALBEDO = tex1.rgb * tex2.rgb * albedo_color;
	//ALPHA = alpha;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
