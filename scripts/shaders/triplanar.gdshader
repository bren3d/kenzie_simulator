shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color = vec4(1.0f);
uniform sampler2D texture_albedo : source_color, hint_default_white;

uniform float metallic : hint_range(0, 1) = 0.0f;
uniform float roughness : hint_range(0, 1) = 1.0f;
uniform sampler2D texture_roughness_metallic : hint_default_white;

uniform vec3 uv1_scale = vec3(1.0f, 1.0f, 1.0f);
uniform vec3 uv1_offset = vec3(0.0f, 0.0f, 0.0f);

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

vec4 texture_point_smooth(sampler2D smp, vec2 uv, vec2 pixel_size) {
	vec2 ddx = dFdx(uv);
	vec2 ddy = dFdy(uv);
	vec2 lxy = sqrt(ddx * ddx + ddy * ddy);
	
	vec2 uv_pixels = uv / pixel_size;
	
	vec2 uv_pixels_floor = round(uv_pixels) - vec2(0.5f);
	vec2 uv_dxy_pixels = uv_pixels - uv_pixels_floor;
	
	uv_dxy_pixels = clamp((uv_dxy_pixels - vec2(0.5f)) * pixel_size / lxy + vec2(0.5f), 0.0f, 1.0f);
	
	uv = uv_pixels_floor * pixel_size;
	
	return textureGrad(smp, uv + uv_dxy_pixels * pixel_size, ddx, ddy);
}

void fragment() {
	vec2 base_uv = UV;
	vec2 tex_size = 1.0f / vec2(textureSize(texture_albedo, 0)); // size of one pixel of the texture
	
	vec4 albedo_tex = texture_point_smooth(texture_albedo, base_uv, tex_size);
	
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA = albedo.a * albedo_tex.a;
	
	vec2 roughness_metallic_tex = texture_point_smooth(texture_roughness_metallic, base_uv, tex_size).rg;
	ROUGHNESS = roughness_metallic_tex.r * roughness;
	METALLIC = roughness_metallic_tex.g * metallic;
	SPECULAR = 0.5f;
}