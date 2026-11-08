shader_type spatial;

uniform vec4 base_color : source_color = vec4(1.0);
uniform vec4 active_color : source_color = vec4(1.0);
uniform vec4 highlight_color : source_color = vec4(1.0);
uniform vec4 stasis_color : source_color = vec4(1.0);
uniform int state : hint_enum("Idle", "Active", "Highlight", "Stasis") = 0;
uniform float emission = 5.0;

void fragment() {
  vec4 target_color;
  float target_emission;
  if (state == 0) {
    target_color = base_color;
    target_emission = 0.0;
  } else if (state == 1) {
    target_color = active_color;
    target_emission = emission;
  } else if (state == 2) {
    target_color = highlight_color;
    target_emission = emission;
  } else {
    target_color = stasis_color;
    target_emission = emission;
  }

  ALBEDO = base_color.rgb;
  ALPHA = base_color.a;
  EMISSION = target_color.rgb * target_emission;
}
