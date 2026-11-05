shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// ========================================================
// SHADER DE PEDRA MEDIEVAL COM MUSGO - VILA DE HIGHSTONE
// Pedras de alvenaria antiga com crescimento orgânico de musgo
// ========================================================

group_uniforms Pedra;
uniform vec4 stone_color_base : source_color = vec4(0.44, 0.43, 0.40, 1.0);
uniform vec4 stone_color_dark : source_color = vec4(0.28, 0.27, 0.25, 1.0);
uniform float stone_roughness : hint_range(0.0, 1.0) = 0.88;
uniform float stone_scale = 4.0;

group_uniforms Musgo;
uniform vec4 moss_color_base : source_color = vec4(0.18, 0.35, 0.12, 1.0);
uniform vec4 moss_color_bright : source_color = vec4(0.32, 0.52, 0.18, 1.0);
uniform float moss_amount : hint_range(0.0, 1.0) = 0.45;
uniform float moss_height_bias : hint_range(0.0, 10.0) = 2.5;
uniform float moss_roughness : hint_range(0.0, 1.0) = 0.95;

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
	// Projeção tri-planar simplificada para paredes e superfícies
	vec2 uv_proj = (abs(v_world_normal.y) > 0.5) ? v_world_pos.xz : (abs(v_world_normal.x) > 0.5 ? v_world_pos.zy : v_world_pos.xy);
	
	// Ruído de blocos de pedra e rachaduras
	float n_stone = noise(uv_proj * stone_scale) * 0.6 + noise(uv_proj * stone_scale * 3.0) * 0.4;
	vec3 col_stone = mix(stone_color_dark.rgb, stone_color_base.rgb, n_stone);
	
	// Crescimento de musgo nas frestas e superfícies superiores voltadas para o céu
	float up_facing = clamp(v_world_normal.y, 0.0, 1.0);
	float height_fade = clamp(1.0 - (v_world_pos.y / moss_height_bias), 0.0, 1.0);
	float n_moss = noise(uv_proj * 6.0);
	
	float moss_factor = (up_facing * 0.6 + height_fade * 0.7) * (n_moss * 1.3) * moss_amount;
	moss_factor = smoothstep(0.25, 0.65, moss_factor);
	
	vec3 col_moss = mix(moss_color_base.rgb, moss_color_bright.rgb, n_moss);
	
	ALBEDO = mix(col_stone, col_moss, moss_factor);
	ROUGHNESS = mix(stone_roughness, moss_roughness, moss_factor);
	SPECULAR = 0.15;
	METALLIC = 0.0;
}
