shader_type canvas_item;

uniform vec4 water_color : source_color = vec4(0.0, 0.45, 0.75, 1.0);
uniform vec4 wave_color : source_color = vec4(0.1, 0.6, 0.85, 1.0);
uniform float speed = 0.5;

void fragment() {
	vec2 uv = UV * 100.0;
	// Sóng nước trôi ngược lại để tạo cảm giác thuyền đang tiến lên
	uv.y -= TIME * speed; 
	float wave = sin(uv.x * 10.0 + TIME) * cos(uv.y * 10.0 + TIME);
	COLOR = mix(water_color, wave_color, wave * 0.5 + 0.5);
}
