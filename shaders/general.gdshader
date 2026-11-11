shader_type spatial;
render_mode depth_test_disabled;

uniform vec3 base_color : source_color = vec3(1.0);
uniform vec3 emission_color : source_color = vec3(1.0);
uniform float alpha = 1.0;

// todo: do this and make arrow and chain use it
void fragment() {
  ALBEDO = arrow_color;
  EMISSION = emission_color;
  ALPHA = alpha;
}
