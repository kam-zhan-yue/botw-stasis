shader_type spatial;
render_mode diffuse_toon, specular_toon;

uniform int state : hint_enum("Idle", "Active", "Highlight", "Stasis") = 0;

uniform sampler2D base_texture : source_color, filter_linear_mipmap;

// Cel Shading
uniform int bands : hint_range(2, 6) = 3;
uniform float band_softness : hint_range(0.0, 0.2, 0.005) = 0.02;
uniform float rim_strength : hint_range(0.0, 1.0) = 0.5;
uniform float rim_width : hint_range(0.0, 1.0) = 0.3;

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

  vec4 tex = texture(base_texture, UV);
  ALBEDO = tex.rgb * base_color.rgb;
  EMISSION = target_color.rgb;
}


// Turns an amount of light into one of `bands` flat levels. 0 to 1 is cut
// into `bands` equal slices: with 3 bands, below 1/3 is unlit, 1/3 to 2/3 is
// half lit and 2/3 or more is fully lit. Anything above 1 is fully lit too.
float band(float amount) {
	float slices = float(bands);
	float half_soft = max(band_softness, 0.0001) * 0.5;
	float level = 0.0;
	for (int i = 1; i < bands; i++) {
		float edge = float(i) / slices;
		level += smoothstep(edge - half_soft, edge + half_soft, amount);
	}
	// max() keeps a script that sets bands to 1 from dividing by zero.
	return level / max(slices - 1.0, 1.0);
}

void light() {
	// LIGHT_COLOR is the light's colour × energy × PI. Split it into a
	// strength (its brightest channel) and a tint whose brightest channel is 1.
	vec3 light_rgb = LIGHT_COLOR / PI;
	float strength = max(max(light_rgb.r, light_rgb.g), light_rgb.b);
	vec3 tint = light_rgb / max(strength, 0.0001);

	// How much of this light reaches the pixel: the Lambert term (N·L) times
	// ATTENUATION, which holds the shadow and, for omni and spot lights, the
	// distance falloff, times the strength. Banding the whole product puts
	// shadow edges and the edge of an omni light's pool on band edges too.
	// A strength above 1 goes into the product, so the lit area grows. A
	// strength below 1 scales the banded result instead, so a weak light keeps
	// the same band shapes and is only dimmer.
	float n_dot_l = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	float level = band(n_dot_l * ATTENUATION * max(strength, 1.0)) * min(strength, 1.0);

	// Rim: 1 - N·V grows towards the silhouette. It only shows where this light
	// reaches, and as bright as the band under it.
	float n_dot_v = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	float rim = smoothstep(1.0 - rim_width, 1.0 - rim_width + max(band_softness, 0.0001), 1.0 - n_dot_v);

	// Godot multiplies DIFFUSE_LIGHT by ALBEDO afterwards, so a fully lit pixel
	// shows the surface colour times the light's tint.
	DIFFUSE_LIGHT += tint * level * (1.0 + rim * rim_strength);
}
