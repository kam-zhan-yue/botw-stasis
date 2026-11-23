// Toon Shader
// Cel shading for 3D meshes: light in hard bands, a rim light and a hard-edged
// highlight, all worked out per light in light().
// Godot 4.7 · CC0 1.0 · godotlearning.com/shaders/toon-shader
shader_type spatial;
// cull_back: back faces are not drawn, as with a StandardMaterial3D. The
// diffuse_* and specular_* render modes only pick Godot's own lighting models,
// and this shader replaces those with its own light() function.
render_mode cull_back;

// Base colour. Multiplied with albedo_texture.
uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// Optional colour texture, read with the mesh's UV. White when left empty.
uniform sampler2D albedo_texture : source_color, hint_default_white, filter_linear_mipmap, repeat_enable;
// Number of light levels from unlit to fully lit, the unlit one included.
// 2 is the classic two-tone look.
uniform int bands : hint_range(2, 6) = 3;
// Width of the blend at each band edge, in the same units as the light amount
// that band() cuts up. Small values keep the edges hard without stair steps
// along them. 0 gives the hardest edge, which shows stair steps.
uniform float band_softness : hint_range(0.0, 0.2, 0.005) = 0.02;
// Brightness of the rim light on the lit side of the silhouette. 0 turns it off.
uniform float rim_strength : hint_range(0.0, 1.0) = 0.5;
// How far the rim reaches in from the silhouette. 0 is none, 1 the whole face.
uniform float rim_width : hint_range(0.0, 1.0) = 0.3;
// Hard-edged highlight. Off gives a matte look.
uniform bool specular = true;
// Size of the highlight: higher is smaller and tighter.
uniform float glossiness : hint_range(1.0, 256.0) = 40.0;

void fragment() {
	ALBEDO = albedo_color.rgb * texture(albedo_texture, UV).rgb;
	// No reflections of the sky or of reflection probes. Ambient light still
	// arrives and lifts every band, the unlit one included.
	SPECULAR = 0.0;
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

	if (specular) {
		// Blinn-Phong half vector, cut at 0.5 into a highlight with a hard edge.
		// SPECULAR_LIGHT is not multiplied by ALBEDO, so the highlight takes the
		// light's tint, not the surface colour.
		vec3 half_vector = normalize(LIGHT + VIEW);
		float blinn = pow(clamp(dot(NORMAL, half_vector), 0.0, 1.0), glossiness);
		float half_soft = max(band_softness, 0.0001) * 0.5;
		float highlight = smoothstep(0.5 - half_soft, 0.5 + half_soft, blinn);
		SPECULAR_LIGHT += tint * highlight * level * SPECULAR_AMOUNT;
	}
}
