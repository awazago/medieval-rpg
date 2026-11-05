shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled, diffuse_burley, specular_disabled;

// ========================================================
// SHADER DE NÉVOA ESPECTRAL RASTEIRA - CRIPTA ANCESTRAL
// Neblina baixa translúcida com desvanecimento suave de profundidade
// ========================================================

group_uniforms CoresNevoa;
uniform vec4 mist_color : source_color = vec4(0.25, 0.75, 0.55, 0.45);
uniform vec4 mist_glow : source_color = vec4(0.35, 0.95, 0.75, 0.3);
uniform float mist_speed : hint_range(0.05, 2.0) = 0.25;
uniform float mist_density : hint_range(0.1, 3.0) = 1.0;
uniform float fade_distance : hint_range(0.1, 5.0) = 1.2;

uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;

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
	vec2 uv_p = v_world_pos.xz * 0.12;
	
	// Ruído duplo de névoa em movimento cruzado
	float n1 = noise(uv_p + vec2(TIME * mist_speed * 0.3, TIME * mist_speed * 0.2));
	float n2 = noise(uv_p * 1.8 - vec2(TIME * mist_speed * 0.2, -TIME * mist_speed * 0.15));
	float mist_factor = (n1 * 0.6 + n2 * 0.4) * mist_density;
	
	// Desvanecimento suave de contato com o chão e sarcófagos
	float depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth, 1.0);
	vec3 surface_pos = upos.xyz / upos.w;
	float contact_fade = clamp((VERTEX.z - surface_pos.z) / fade_distance, 0.0, 1.0);
	
	vec3 col = mix(mist_color.rgb, mist_glow.rgb, mist_factor);
	
	ALBEDO = col;
	ALPHA = clamp(mist_factor * mist_color.a * contact_fade, 0.0, 0.85);
	EMISSION = mist_glow.rgb * mist_factor * 0.35;
	ROUGHNESS = 1.0;
}
