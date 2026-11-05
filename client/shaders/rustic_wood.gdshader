shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// ========================================================
// SHADER DE MADEIRA RÚSTICA MEDIEVAL - VILA DE HIGHSTONE
// Vigas, paliçadas, caixotes e suportes de carpintaria
// ========================================================

group_uniforms Madeira;
uniform vec4 wood_color_base : source_color = vec4(0.34, 0.23, 0.14, 1.0);
uniform vec4 wood_color_dark : source_color = vec4(0.20, 0.13, 0.08, 1.0);
uniform vec4 wood_color_highlight : source_color = vec4(0.44, 0.30, 0.18, 1.0);
uniform float grain_scale_x = 24.0;
uniform float grain_scale_y = 1.8;
uniform float wood_roughness : hint_range(0.0, 1.0) = 0.82;

varying vec3 v_world_pos;
varying vec3 v_world_normal;

float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
	           mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec2 uv_p = (abs(v_world_normal.y) > 0.5) ? v_world_pos.xz : vec2(v_world_pos.x + v_world_pos.z, v_world_pos.y);
	
	// Ondulação de veios de madeira
	float grain_pattern = sin(uv_p.x * grain_scale_x + noise(uv_p * 3.0) * 4.0);
	grain_pattern = smoothstep(-0.3, 0.7, grain_pattern);
	
	// Micro-linhas de corte de machado / serra
	float plank_noise = noise(vec2(uv_p.x * 2.0, uv_p.y * grain_scale_y));
	
	vec3 col = mix(wood_color_dark.rgb, wood_color_base.rgb, grain_pattern);
	col = mix(col, wood_color_highlight.rgb, plank_noise * 0.35);
	
	ALBEDO = col;
	ROUGHNESS = wood_roughness;
	SPECULAR = 0.18;
	METALLIC = 0.0;
}
