shader_type spatial;

uniform sampler2D noise;

uniform vec4 color: source_color = vec4(1.0 ,1.0 ,1.0 ,1.0 );

void fragment() {
	ALBEDO = COLOR.rgb;
	float max_uv = 1.0 - 2.0 * max(abs(0.5 - UV.x), abs(0.5 - UV.y));
	float a = texture(noise, UV).r;
	if (max_uv > 0.3){
		ALPHA = max_uv;
	}
	else{
		ALPHA = 0.0;
	}
	
	//ALBEDO = color.rgb;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
