shader_type spatial;
render_mode diffuse_toon, specular_toon;

uniform sampler2D texture_albedo;
uniform sampler2D color_gradient;
uniform sampler2D fresnel_gradient;
uniform float fresnel_amount;

float saturate(float value) {
  return clamp(value, 0.0, 1.0);
}

float fresnel(vec3 normal, vec3 view, float power) {
  return pow((1.0 - saturate(dot(normalize(normal), normalize(view)))), power);
}

void fragment() {
	float basic_fresnel = fresnel(NORMAL, VIEW, fresnel_amount);
	vec3 gradient = texture(fresnel_gradient, vec2(basic_fresnel, 0.0)).rgb;
	vec3 texture_color = texture(texture_albedo, UV).rgb;
	ALBEDO = texture_color + basic_fresnel * gradient;
  SPECULAR = 0.0;
}

void light() {
	float dotproduct = max(dot(NORMAL, LIGHT), 0.0);
	float sample = clamp(dotproduct * ATTENUATION , 0.05, 0.95);
	vec4 shaded = texture(color_gradient, vec2(sample, 0.0));
	DIFFUSE_LIGHT = clamp((shaded.rgb * LIGHT_COLOR), 0.0, 1.0);
}
