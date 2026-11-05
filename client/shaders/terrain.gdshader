shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// ========================================================
// SHADER DE TERRENO ESTILIZADO - ILHA DO ALVORECER (AETHELGARD)
// Mesclagem tri-camada: Grama Vibrante, Terra Batida e Pedra/Caminhos
// ========================================================

group_uniforms Grama;
uniform vec4 grass_color_base : source_color = vec4(0.22, 0.45, 0.16, 1.0);
uniform vec4 grass_color_accent : source_color = vec4(0.35, 0.58, 0.22, 1.0);
uniform float grass_roughness : hint_range(0.0, 1.0) = 0.85;
uniform float grass_noise_scale = 12.0;

group_uniforms Terra;
uniform vec4 dirt_color : source_color = vec4(0.42, 0.32, 0.22, 1.0);
uniform float dirt_roughness : hint_range(0.0, 1.0) = 0.95;

group_uniforms Pedra_Caminho;
uniform vec4 rock_color : source_color = vec4(0.38, 0.37, 0.35, 1.0);
uniform float rock_roughness : hint_range(0.0, 1.0) = 0.7;
uniform float slope_threshold : hint_range(0.0, 1.0) = 0.65;
uniform float slope_blend : hint_range(0.01, 0.5) = 0.15;

group_uniforms ConfiguracaoGeral;
uniform vec2 world_uv_scale = vec2(0.08, 0.08);
uniform float path_width = 3.5;
uniform bool enable_path = true;

varying vec3 v_world_pos;
varying vec3 v_world_normal;

// Funções de ruído procedural 2D para quebra orgânica de repetição
float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float value = 0.0;
	float amplitude = 0.5;
	for (int i = 0; i < 3; i++) {
		value += amplitude * noise(p);
		p *= 2.1;
		amplitude *= 0.5;
	}
	return value;
}

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec2 world_uv = v_world_pos.xz * world_uv_scale;
	
	// 1. Variação orgânica da grama (dois tons de verde medieval)
	float grass_n = fbm(world_uv * grass_noise_scale);
	vec3 col_grass = mix(grass_color_base.rgb, grass_color_accent.rgb, grass_n);
	
	// 2. Ruído de transição entre terra e grama
	float dirt_noise = fbm(world_uv * 4.0);
	float dirt_mask = smoothstep(0.40, 0.65, dirt_noise);
	
	// 3. Caminho natural (centralizado em X com curvatura por ruído)
	float path_dist = abs(v_world_pos.x + sin(v_world_pos.z * 0.05) * 2.0);
	float path_mask = 0.0;
	if (enable_path && v_world_pos.z > -30.0 && v_world_pos.z < 25.0) {
		path_mask = 1.0 - smoothstep(path_width * 0.5, path_width * 1.1, path_dist + dirt_noise * 1.5);
	}
	
	// Mescla Grama + Terra
	vec3 base_terrain = mix(col_grass, dirt_color.rgb, dirt_mask * 0.45);
	float cur_roughness = mix(grass_roughness, dirt_roughness, dirt_mask * 0.45);
	
	// Aplica Caminho de Pedra/Terra batida
	vec3 path_col = mix(dirt_color.rgb, rock_color.rgb, 0.65);
	base_terrain = mix(base_terrain, path_col, path_mask);
	cur_roughness = mix(cur_roughness, rock_roughness, path_mask);
	
	// 4. Detecção de declive/inclinação (rocha em paredes íngremes)
	float slope = 1.0 - v_world_normal.y;
	float slope_factor = smoothstep(slope_threshold - slope_blend, slope_threshold + slope_blend, slope);
	
	vec3 final_albedo = mix(base_terrain, rock_color.rgb, slope_factor);
	final_albedo += (fbm(world_uv * 18.0) - 0.5) * 0.04; // Micro-textura de grão
	
	ALBEDO = clamp(final_albedo, vec3(0.0), vec3(1.0));
	ROUGHNESS = mix(cur_roughness, rock_roughness, slope_factor);
	SPECULAR = 0.2;
	METALLIC = 0.0;
}
