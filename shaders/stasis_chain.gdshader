shader_type spatial;

uniform vec3 base_color : source_color = vec3(1.0);
uniform vec3 emission_color : source_color = vec3(1.0);
uniform float emission_amount = 1.0;
uniform float alpha = 1.0;

void fragment() {
  ALBEDO = base_color;
  EMISSION = emission_color * emission_amount;
  ALPHA = alpha;
}
