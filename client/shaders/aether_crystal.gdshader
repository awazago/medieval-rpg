shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, diffuse_burley, specular_schlick_ggx;

// ========================================================
// SHADER DO CRISTAL DE AETHERSTONE - MONÓLITO DE HIGHSTONE
// Brilho arcano pulsante, runas internas e reflexão facetada
// ========================================================

group_uniforms Cristal;
uniform vec4 crystal_color_core : source_color = vec4(0.12, 0.38, 0.85, 0.92);
uniform vec4 crystal_color_rim : source_color = vec4(0.40, 0.82, 1.0, 1.0);
uniform vec4 rune_glow_color : source_color = vec4(0.65, 0.90, 1.0, 1.0);
uniform float pulse_speed : hint_range(0.2, 5.0) = 2.2;
uniform float base_emission : hint_range(0.5, 8.0) = 3.2;

varying vec3 v_world_pos;
varying vec3 v_normal;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	// Efeito Fresnel para bordas etéreas
	float fresnel = pow(1.0 - clamp(dot(v_normal, VIEW), 0.0, 1.0), 3.0);
	
	// Pulsação rítmica da energia arcana
	float pulse = sin(TIME * pulse_speed + v_world_pos.y * 2.0) * 0.5 + 0.5;
	
	// Padrão de runas e ondas de energia mística
	float rune_wave = sin(v_world_pos.y * 6.0 + TIME * 1.5) * cos(v_world_pos.x * 6.0) * 0.5 + 0.5;
	rune_wave = smoothstep(0.45, 0.8, rune_wave);
	
	vec3 base_col = mix(crystal_color_core.rgb, crystal_color_rim.rgb, fresnel * 0.7);
	base_col = mix(base_col, rune_glow_color.rgb, rune_wave * 0.5);
	
	ALBEDO = base_col;
	ROUGHNESS = 0.15;
	METALLIC = 0.2;
	SPECULAR = 0.85;
	
	// Emissão arcana combinada com fresnel e pulso
	float total_energy = base_emission * (0.8 + 0.6 * pulse);
	EMISSION = mix(crystal_color_rim.rgb, rune_glow_color.rgb, rune_wave) * (fresnel * 0.8 + rune_wave * 0.6) * total_energy;
}
