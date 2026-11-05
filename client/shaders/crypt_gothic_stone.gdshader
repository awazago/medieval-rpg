shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// ========================================================
// SHADER DE PEDRA GÓTICA DA CRIPTA COM RUNAS NECROMÂNTICAS
// Arquitetura sepulcral escura, fendas antigas e runas verdes espectrais
// ========================================================

group_uniforms PedraSepulcral;
uniform vec4 stone_color_dark : source_color = vec4(0.14, 0.16, 0.18, 1.0);
uniform vec4 stone_color_light : source_color = vec4(0.26, 0.29, 0.31, 1.0);
uniform float stone_roughness : hint_range(0.0, 1.0) = 0.92;
uniform float stone_scale = 5.0;

group_uniforms RunasNecromanticas;
uniform bool enable_runes = true;
uniform vec4 rune_color : source_color = vec4(0.18, 0.95, 0.62, 1.0);
uniform float rune_pulse_speed : hint_range(0.2, 5.0) = 1.6;
uniform float rune_emission_energy : hint_range(0.5, 8.0) = 3.5;

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
	
	// Fendas e textura de rocha gótica desgastada
	float n = noise(uv_p * stone_scale) * 0.7 + noise(uv_p * stone_scale * 2.5) * 0.3;
	vec3 base_col = mix(stone_color_dark.rgb, stone_color_light.rgb, n);
	
	// Padrão de runas necromânticas incisas
	float rune_pattern = 0.0;
	if (enable_runes) {
		float r_wave = sin(uv_p.y * 8.0 + sin(uv_p.x * 6.0)) * cos(uv_p.x * 7.0);
		float pulse = sin(TIME * rune_pulse_speed + v_world_pos.y * 1.5) * 0.5 + 0.5;
		rune_pattern = smoothstep(0.72, 0.92, r_wave) * (0.6 + 0.4 * pulse);
	}
	
	ALBEDO = mix(base_col, rune_color.rgb, rune_pattern * 0.4);
	ROUGHNESS = stone_roughness;
	SPECULAR = 0.2;
	METALLIC = 0.05;
	
	// Emissão espectral pulsante das runas
	EMISSION = rune_color.rgb * rune_pattern * rune_emission_energy;
}
