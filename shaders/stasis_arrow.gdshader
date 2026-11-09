shader_type spatial;
render_mode depth_test_disabled;

uniform vec3 arrow_color : source_color = vec3(1.0);
uniform float alpha = 1.0;

void fragment() {
  ALBEDO = arrow_color;
  ALPHA = alpha;
}
