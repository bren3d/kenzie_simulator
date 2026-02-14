shader_type spatial;

uniform sampler2D noise;
uniform float fade_end : hint_range(0.0, 1.0, 0.01) = 0.2;
uniform float fade_size : hint_range(0.0, 1.0, 0.01) = 0.2;

float get_uv_value(vec2 uv){
	float x = abs(0.5 - uv.x);
	float y = abs(0.5 - uv.y);
	return sqrt(x*x + y*y); 
}

void fragment() {
	float uv = get_uv_value(UV);
	float fade_start = 1.0 - (fade_end + fade_size);
	vec4 tex = texture(noise, UV);
	ALPHA = tex.a;
	ALBEDO = tex.rgb;
	if (uv > fade_start){
		ALPHA = min(tex.a, 1.0 - ((uv - fade_start)) / max(fade_size, 0.01))  ;
	}
}
