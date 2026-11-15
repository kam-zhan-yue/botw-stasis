shader_type spatial;

uniform int state : hint_enum("Idle", "Active", "Highlight", "Stasis") = 0;

// Flashing
uniform bool flashing = false;

// Colors
uniform vec3 base_color : source_color = vec3(1.0);
uniform vec3 active_color : source_color = vec3(1.0);
uniform vec3 highlight_color : source_color = vec3(1.0);
uniform vec3 border_color : source_color = vec3(1.0);
uniform vec3 flashing_color : source_color = vec3(1.0);

// Stasis
uniform vec3 stasis_start_color : source_color = vec3(1.0);
uniform vec3 stasis_end_color : source_color = vec3(1.0);
uniform float stasis_weight = 0.0;
uniform float stasis_elapsed_time = 0.0;

// Inner Fresnel
uniform float fresnel_power = 2.0;
uniform float emission = 1.0;

// Outer Fresnel (Border)
uniform float border_fresnel_power = 7.0;
uniform float border_emission = 7.0;

// Noise Effect
uniform float noise_emission = 1.0;
uniform vec3 noise_start_color : source_color = vec3(1.0);
uniform vec3 noise_end_color : source_color = vec3(1.0);
uniform sampler2D noise_texture : repeat_enable;

float saturate(float value) {
  return clamp(value, 0.0, 1.0);
}

float fresnel(vec3 normal, vec3 view, float power) {
  return pow((1.0 - saturate(dot(normalize(normal), normalize(view)))), power);
}

vec3 get_noise_color(float x, vec2 uv) {
  float pulse = fract(x);
  float pulse_delayed = clamp(fract(x) - 0.1, 0.0, 1.0);
  float noise = texture(noise_texture, uv).r;
  float stepped_noise = step(pulse, noise);
  float stepped_noise_delayed = step(pulse_delayed, noise);
  float final_noise = stepped_noise_delayed - stepped_noise;
  vec3 noise_color = mix(noise_start_color, noise_end_color, stasis_weight);
  return noise_color * final_noise * noise_emission;
}

void fragment() {
  vec3 target_color;
  if (state == 0) {
	target_color = vec3(0.0);
  } else if (state == 1) {
	target_color = active_color;
  } else if (state == 2) {
	target_color = highlight_color;
  } else {
	target_color = mix(stasis_start_color, stasis_end_color, stasis_weight);
  }

  if (state != 0) {
	float fresnel_amount = fresnel(NORMAL,  VIEW, fresnel_power);
	target_color *= fresnel_amount * emission;

	float border_fresnel_amount = fresnel(NORMAL, VIEW, border_fresnel_power);
	target_color += border_color * border_fresnel_amount * border_emission;
  }

  if (state == 3) {
	target_color += get_noise_color(stasis_elapsed_time, UV);
  }

  if (flashing) {
	target_color += flashing_color;
  }

  ALBEDO = base_color.rgb;
  EMISSION = target_color.rgb;
}
