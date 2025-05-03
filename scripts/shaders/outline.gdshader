shader_type spatial;
render_mode unshaded, cull_back;

uniform sampler2D depth_texture : source_color, hint_depth_texture;
uniform vec3 highlight_color: source_color = vec3(.95, .85, .01);
uniform float speed: hint_range(0.0, 5.0, 0.1) = 2.0;

uniform float fresnel_sharpness: hint_range(0.0, 8.0, 0.05) = 3.0;
uniform float fade_intensity: hint_range(1.0, 5.0, 0.1) = 4.0;

uniform sampler2D noise_texture : source_color, repeat_enable;
uniform float noise_intensity: hint_range(0.0, 1.0, 0.02) = 0.2;
uniform float noise_speed: hint_range(0.0, 1.0, 0.01) = 0.04;

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	
	float object_depth = FRAGCOORD.z;
	vec3 object_ndc = vec3(SCREEN_UV, object_depth) * 2.0 - 1.0;
	vec4 object_view = INV_PROJECTION_MATRIX * vec4(object_ndc, 1.0);
	object_view.xyz /= object_view.w;
	
	float fresnel = pow(1.0 - dot(VIEW, NORMAL), fresnel_sharpness);
	float noise_alpha = 1.0 - texture(noise_texture, UV + vec2(1.0, -1.0) * TIME * noise_speed).r * noise_intensity;
	float alpha_time_mod = (cos(TIME * speed))/4.0/fade_intensity;
	ALBEDO = highlight_color;
	//EMISSION = highlight_color;
	ALPHA = (fresnel + alpha_time_mod ) * noise_alpha;
}