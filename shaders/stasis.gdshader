shader_type spatial;

uniform vec4 original_color : source_color = vec4(1.0);
uniform vec4 highlight_color : source_color = vec4(1.0);
uniform vec4 stasis_color : source_color = vec4(1.0);
uniform bool highlight = false;
uniform bool stasis = false;

void fragment() {
  vec4 target_color;
  if (stasis) {
    target_color = stasis_color;
  } else if (highlight) {
    target_color = highlight_color;
  } else {
    target_color = original_color;
  }

  ALBEDO = target_color.rgb;
  ALPHA = target_color.a;
}
