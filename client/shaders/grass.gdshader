shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

// ========================================================
// SHADER DE GRAMA DINÂMICA COM VENTO - ILHA DO ALVORECER
// Animação de vértice com atenuação de raiz e gradiente vertical
// ========================================================

group_uniforms Cores_Gradiente;
uniform vec4 color_root : source_color = vec4(0.12, 0.28, 0.08, 1.0);
uniform vec4 color_tip : source_color = vec4(0.38, 0.68, 0.22, 1.0);
uniform vec4 color_highlight : source_color = vec4(0.65, 0.78, 0.30, 1.0);

group_uniforms Vento;
uniform vec2 wind_direction = vec2(1.0, 0.5);
uniform float wind_speed : hint_range(0.1, 5.0) = 1.6;
uniform float wind_strength : hint_range(0.0, 1.5) = 0.28;
uniform float wind_gust_frequency : hint_range(0.1, 4.0) = 0.8;

group_uniforms PropriedadesPBR;
uniform float roughness : hint_range(0.0, 1.0) = 0.65;
uniform float specular : hint_range(0.0, 1.0) = 0.25;
uniform vec3 transmission_color : source_color = vec3(0.25, 0.45, 0.12);

varying vec3 v_world_pos;
varying float v_height_factor;

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_world_pos = world_pos;
	
	// Fator de altura normalizado: raízes (VERTEX.y perto de 0) ficam fixas, topos balançam
	float height_weight = clamp(VERTEX.y, 0.0, 1.0);
	v_height_factor = height_weight;
	
	vec2 norm_wind = normalize(wind_direction);
	
	// Onda principal de vento com defasagem espacial
	float wave_main = sin(TIME * wind_speed + (world_pos.x * norm_wind.x + world_pos.z * norm_wind.y) * wind_gust_frequency);
	
	// Micro-turbulência de rajada (frequência maior)
	float wave_gust = sin(TIME * (wind_speed * 2.2) + (world_pos.x * 2.0 - world_pos.z * 1.5)) * 0.4;
	
	float total_sway = (wave_main + wave_gust) * wind_strength * height_weight;
	
	// Desloca vértice no plano XZ de acordo com a direção do vento
	VERTEX.x += norm_wind.x * total_sway;
	VERTEX.z += norm_wind.y * total_sway;
	
	// Pequeno rebaixamento em Y para manter comprimento da lâmina de grama
	VERTEX.y -= abs(total_sway) * 0.15;
}

void fragment() {
	// Gradiente vertical orgânico da base até a ponta
	vec3 col = mix(color_root.rgb, color_tip.rgb, v_height_factor);
	
	// Destaque dourado/âmbar de iluminação solar na ponta extrema
	float tip_highlight = smoothstep(0.75, 1.0, v_height_factor);
	col = mix(col, color_highlight.rgb, tip_highlight * 0.5);
	
	ALBEDO = col;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	
	// Iluminação translúcida traseira (efeito de luz solar passando através da lâmina)
	BACKLIGHT = transmission_color * (0.4 + 0.6 * v_height_factor);
}
