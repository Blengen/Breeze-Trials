shader_type spatial;
render_mode cull_front, unshaded;

//uniform vec3 color : source_color = vec3(1,1,1);
uniform float thickness : hint_range(0.0, 1.0, 0.01) = 0.02;

void vertex() {
	VERTEX += thickness*NORMAL;
}

//void fragment() {
//	 ALBEDO = color;
//}