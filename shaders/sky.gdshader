shader_type sky;

uniform vec4 sky_color : source_color = vec4(1.0);
uniform vec4 horizon_color : source_color = vec4(1.0);

uniform vec4 sun_color : source_color = vec4(1.0, 0.85, 0.65, 1.0);
uniform float sun_size = 0.04;
uniform float sun_intensity = 0.5;

//float sun_dot = max(dot(EYEDIR, LIGHT0_DIRECTION), 0.0);
//
//float sun_glow = pow(sun_dot, 1.0 / sun_size);
//
//color += sun_color.rgb * sun_glow * sun_intensity;

void sky() {
	// Horizon Color
	float height = max(EYEDIR.y, 0.0);
	float gradient = smoothstep(0.0, 0.6, height);
	vec3 horizon = mix(horizon_color.rgb, sky_color.rgb, gradient);
	
	// Sun
	float sun_dot = max(dot(EYEDIR, LIGHT0_DIRECTION), 0.0);
	float sun_glow = pow(sun_dot, 1.0 / sun_size);
	vec3 sun = sun_color.rgb * sun_glow * sun_intensity;
	
	COLOR += horizon + sun;
}
