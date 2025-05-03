shader_type canvas_item;

uniform float wobble_intensity: hint_range(0.0, 3.0, 0.05) = 0.7;
uniform float refresh_interval: hint_range(0.01, 0.5, 0.01) = 0.12;

vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

void vertex() {
	float time = TIME - mod(TIME, refresh_interval);
	vec2 offset = random(mod(UV + time/10.0, refresh_interval));
	VERTEX += offset * wobble_intensity;
}

