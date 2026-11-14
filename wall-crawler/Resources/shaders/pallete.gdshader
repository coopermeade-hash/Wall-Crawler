shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;


uniform vec3 primary[16] : source_color;

void fragment() {
	vec3 current_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	
	vec3 closest_color = primary[0];
	float min_distance = distance(current_color, primary[0]);
	
	for(int i = 1; i < primary.length(); i++) {
		float test_distance = distance(current_color, primary[i]);
		if(test_distance < min_distance) {
			closest_color = primary[i];
			min_distance = test_distance;
		}
	}
	
	
	COLOR.rgb = closest_color * COLOR.rgb;
	
	
}