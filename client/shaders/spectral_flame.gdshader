shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_disabled;

// ========================================================
// SHADER DE FOGO ESPECTRAL NECROMÂNTICO - CRIPTA ANCESTRAL
// Chamas verdes esmeralda com turbulência vertical e emissão
// ========================================================

group_uniforms CoresChama;
uniform vec4 flame_color_base : source_color = vec4(0.08, 0.45, 0.32, 0.9);
uniform vec4 flame_color_hot : source_color = vec4(0.25, 0.98, 0.68, 1.0);
uniform vec4 flame_color_core : source_color = vec4(0.85, 1.0, 0.92, 1.0);
uniform float emission_energy : hint_range(1.0, 10.0) = 4.8;

group_uniforms AnimacaoFogo;
uniform float flame_speed : hint_range(0.5, 6.0) = 2.8;
uniform float flame_turbulence : hint_range(0.0, 1.0) = 0.35;

varying vec3 v_world_pos;
varying float v_flame_height;

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
	float h = clamp(VERTEX.y, 0.0, 1.5);
	v_flame_height = h;
	
	// Oscilação de turbulência no topo da labareda
	float curl = sin(TIME * flame_speed + VERTEX.y * 4.0) * cos(TIME * (flame_speed * 1.3) + VERTEX.x * 3.0);
	VERTEX.x += curl * flame_turbulence * h;
	VERTEX.z += cos(TIME * flame_speed + VERTEX.z * 4.0) * flame_turbulence * h;
}

void fragment() {
	// Deslocamento vertical de ruído simulando labaredas subindo
	vec2 uv_scroll = vec2(UV.x, UV.y - TIME * flame_speed * 0.4);
	float n = noise(uv_scroll * 4.0) * 0.7 + noise(uv_scroll * 8.0) * 0.3;
	
	// Gradiente de temperatura: Base verde escuro -> Meio verde esmeralda -> Núcleo esbranquiçado
	vec3 col = mix(flame_color_base.rgb, flame_color_hot.rgb, n);
	if (n > 0.65) {
		col = mix(col, flame_color_core.rgb, smoothstep(0.65, 0.95, n));
	}
	
	ALBEDO = col;
	ROUGHNESS = 0.4;
	
	// Emissão espectral vívida
	EMISSION = col * emission_energy * (0.6 + 0.4 * n);
}
