shader_type spatial;
//render_mode blend_mix;

uniform float fade_end : hint_range(0.0, 1.0, 0.01) = 0.2;
uniform float fade_size : hint_range(0.0, 1.0, 0.01) = 0.2;

float get_uv_value(vec2 uv){
	//return max(uv.x *2.0, uv.y*2.0);
	float x = abs(0.5 - uv.x);
	float y = abs(0.5 - uv.y);
	//return 1.0 - sqrt(x*y);
	return max(x, y) * 2.0;
}

void fragment() {
	float uv = get_uv_value(UV);
	float fade_start = 1.0 - (fade_end + fade_size);
	//ALPHA = 0.0;
	if (uv > fade_start){
		ALPHA = 1.0 - uv;//((uv - fade_start)) / max(fade_size, 0.01)  ;
	}
}
