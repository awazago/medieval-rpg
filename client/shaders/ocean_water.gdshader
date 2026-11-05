shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, diffuse_burley, specular_schlick_ggx;

// ========================================================
// SHADER DE ÁGUA OCEÂNICA DINÂMICA - ILHA DO ALVORECER (AETHELGARD)
// Ondas Gerstner, espuma de crista, espuma de contato e gradiente de profundidade
// ========================================================

group_uniforms Cores_Agua;
uniform vec4 shallow_color : source_color = vec4(0.08, 0.52, 0.62, 0.85);
uniform vec4 deep_color : source_color = vec4(0.03, 0.12, 0.28, 0.96);
uniform vec4 foam_color : source_color = vec4(0.92, 0.96, 1.0, 0.95);

group_uniforms Ondulacao;
uniform float wave_amplitude : hint_range(0.0, 2.0) = 0.35;
uniform float wave_frequency : hint_range(0.05, 1.0) = 0.25;
uniform float wave_speed : hint_range(0.1, 5.0) = 1.2;
uniform vec2 wave_dir_1 = vec2(1.0, 0.3);
uniform vec2 wave_dir_2 = vec2(0.3, 1.0);

group_uniforms Espuma_Profundidade;
uniform float foam_crest_threshold : hint_range(0.0, 1.0) = 0.65;
uniform float foam_edge_distance : hint_range(0.05, 3.0) = 0.6;
uniform float depth_fade_distance : hint_range(0.5, 30.0) = 6.0;

group_uniforms PropriedadesPBR;
uniform float roughness : hint_range(0.0, 1.0) = 0.08;
uniform float metallic : hint_range(0.0, 1.0) = 0.15;
uniform float fresnel_power : hint_range(1.0, 8.0) = 4.0;

uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;

varying vec3 v_world_pos;
varying float v_wave_height;

// Cálculo de onda direcional tipo Gerstner simplificada
vec3 calculate_wave(vec2 dir, float steepness, float wavelength, inout vec3 vertex, float time) {
	dir = normalize(dir);
	float k = 2.0 * 3.14159265 / wavelength;
	float c = sqrt(9.8 / k);
	float f = k * (dot(dir, vertex.xz) - c * time * wave_speed * 0.3);
	float a = steepness / k;
	
	// Deslocamento horizontal e vertical
	vertex.x += dir.x * (a * cos(f));
	vertex.y += a * sin(f);
	vertex.z += dir.y * (a * cos(f));
	
	// Retorna derivadas para normais
	float wa = a * k;
	return vec3(
		-dir.x * wa * cos(f),
		1.0 - wa * sin(f),
		-dir.y * wa * cos(f)
	);
}

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 local_v = VERTEX;
	
	// Aplica duas ondas cruzadas com direções e frequências diferentes
	calculate_wave(wave_dir_1, wave_amplitude * 0.6, 12.0 / wave_frequency, local_v, TIME);
	calculate_wave(wave_dir_2, wave_amplitude * 0.4, 7.0 / wave_frequency, local_v, TIME * 1.2);
	
	v_wave_height = local_v.y - VERTEX.y;
	VERTEX = local_v;
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// 1. Textura de profundidade para detecção de costa / píer
	float depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth, 1.0);
	vec3 surface_pos = upos.xyz / upos.w;
	float water_depth = VERTEX.z - surface_pos.z;
	
	// 2. Gradiente entre águas rasas e oceano profundo
	float depth_factor = clamp(water_depth / depth_fade_distance, 0.0, 1.0);
	vec4 water_color = mix(shallow_color, deep_color, depth_factor);
	
	// 3. Efeito de espuma em bordas e contato com objetos (píer, praia, casco)
	float shore_foam = 0.0;
	if (water_depth > 0.0 && water_depth < foam_edge_distance) {
		float foam_noise = sin(v_world_pos.x * 3.0 + TIME * 2.0) * cos(v_world_pos.z * 3.0 + TIME * 1.5) * 0.5 + 0.5;
		shore_foam = (1.0 - (water_depth / foam_edge_distance)) * foam_noise;
	}
	
	// 4. Espuma no topo / crista das ondas
	float crest_foam = smoothstep(wave_amplitude * (foam_crest_threshold - 0.2), wave_amplitude * foam_crest_threshold, v_wave_height);
	float total_foam = clamp(shore_foam + crest_foam * 0.75, 0.0, 1.0);
	
	// 5. Fresnel para brilho solar rasante
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);
	
	// Cor final da água com espuma
	vec3 final_rgb = mix(water_color.rgb, foam_color.rgb, total_foam);
	final_rgb = mix(final_rgb, vec3(1.0), fresnel * 0.25);
	
	ALBEDO = final_rgb;
	ALPHA = mix(water_color.a, foam_color.a, total_foam);
	ROUGHNESS = mix(roughness, 0.4, total_foam);
	METALLIC = metallic;
	SPECULAR = 0.45;
}
