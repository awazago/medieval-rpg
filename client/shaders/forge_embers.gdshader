shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// ========================================================
// SHADER DE BRASAS INCANDESCENTES DA FORJA - MESTRE TORVALD
// Pulso térmico, veios de carvão em brasa e emissão dinâmica
// ========================================================

group_uniforms Cores_Brasa;
uniform vec4 color_coal : source_color = vec4(0.12, 0.08, 0.06, 1.0);
uniform vec4 color_ember_deep : source_color = vec4(0.95, 0.22, 0.04, 1.0);
uniform vec4 color_ember_hot : source_color = vec4(1.0, 0.72, 0.15, 1.0);
uniform vec4 color_ember_white : source_color = vec4(1.0, 0.98, 0.85, 1.0);

group_uniforms AnimacaoCalor;
uniform float pulse_speed : hint_range(0.2, 5.0) = 1.8;
uniform float ember_scale = 8.0;
uniform float base_emission_energy : hint_range(1.0, 10.0) = 4.5;
uniform float pulse_amplitude : hint_range(0.1, 4.0) = 1.8;

varying vec3 v_world_pos;

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
}

void fragment() {
	vec2 uv_p = v_world_pos.xz * ember_scale;
	
	// Ruído turbulento de fendas incandescentes no carvão
	float n1 = noise(uv_p + vec2(TIME * 0.15, TIME * 0.1));
	float n2 = noise(uv_p * 2.2 - vec2(TIME * 0.2, -TIME * 0.15));
	float heat_map = n1 * 0.6 + n2 * 0.4;
	
	// Pulso de respiração do fogo da forja
	float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
	float heat_intensity = clamp(heat_map + pulse * 0.35, 0.0, 1.0);
	
	// Gradiente térmico: Carvão escuro -> Vermelho brasa -> Amarelo incandescente -> Branco solar
	vec3 ember_col = color_coal.rgb;
	if (heat_intensity > 0.35) {
		float t1 = smoothstep(0.35, 0.65, heat_intensity);
		ember_col = mix(color_coal.rgb, color_ember_deep.rgb, t1);
	}
	if (heat_intensity > 0.65) {
		float t2 = smoothstep(0.65, 0.88, heat_intensity);
		ember_col = mix(ember_col, color_ember_hot.rgb, t2);
	}
	if (heat_intensity > 0.88) {
		float t3 = smoothstep(0.88, 1.0, heat_intensity);
		ember_col = mix(ember_col, color_ember_white.rgb, t3);
	}
	
	ALBEDO = ember_col;
	ROUGHNESS = 0.75 - heat_intensity * 0.4;
	
	// Emissão de luz radiante baseada na intensidade térmica
	float emissive_factor = smoothstep(0.4, 0.95, heat_intensity);
	float cur_energy = base_emission_energy + pulse * pulse_amplitude;
	EMISSION = ember_col * emissive_factor * cur_energy;
}
