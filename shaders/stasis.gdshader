shader_type spatial;

uniform int state : hint_enum("Idle", "Active", "Highlight", "Stasis") = 0;

// Colors
uniform vec4 base_color : source_color = vec4(1.0);
uniform vec4 active_color : source_color = vec4(1.0);
uniform vec4 highlight_color : source_color = vec4(1.0);
uniform vec4 border_color : source_color = vec4(1.0);

// Stasis
uniform vec4 stasis_start_color : source_color = vec4(1.0);
uniform vec4 stasis_end_color : source_color = vec4(1.0);
uniform float stasis_weight = 0.0;

// Inner Fresnel
uniform float fresnel_power = 2.0;
uniform float emission = 1.0;

// Outer Fresnel (Border)
uniform float border_fresnel_power = 7.0;
uniform float border_emission = 7.0;

float saturate(float value) {
  return clamp(value, 0.0, 1.0);
}

float fresnel(vec3 normal, vec3 view, float power) {
  return pow((1.0 - saturate(dot(normalize(normal), normalize(view)))), power);
}

void fragment() {
  vec4 target_color;
  if (state == 0) {
    target_color = vec4(0.0);
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

  ALBEDO = base_color.rgb;
  ALPHA = base_color.a;
  EMISSION = target_color.rgb;
}
