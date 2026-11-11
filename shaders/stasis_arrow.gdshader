shader_type spatial;
render_mode depth_test_disabled;

uniform vec3 base_color : source_color = vec3(1.0);
uniform float alpha = 1.0;

void fragment() {
  ALBEDO = base_color;
  ALPHA = alpha;
}
