shader_type spatial;
uniform sampler2D diffuse: source_color, filter_nearest;
uniform sampler2D normal_map: source_color, hint_normal;

uniform uint frame = 0;
uniform uint h_frames = 1;
uniform uint v_frames = 1;


uniform bool enable_Ybillboard = false;
uniform bool enable_billboard = false;

void vertex() {
	vec2 uv_mod = 1.0 / vec2(float(h_frames), float(v_frames));
	float uv_off_x = uv_mod.x * float(frame % h_frames);
	float uv_off_y = uv_mod.y * float(frame / h_frames);
	UV = UV * uv_mod + vec2(uv_off_x, uv_off_y);
	
	//y-billboard code
	if (enable_Ybillboard && !enable_billboard) {
        MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			vec4(normalize(cross(vec3(0.0, 1.0, 0.0), MAIN_CAM_INV_VIEW_MATRIX[2].xyz)), 0.0),
			vec4(0.0, 1.0, 0.0, 0.0),
			vec4(normalize(cross(MAIN_CAM_INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0),
			MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
    }
	//billboard code
	else if (enable_billboard && !enable_Ybillboard) {
        MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			MAIN_CAM_INV_VIEW_MATRIX[0],
			MAIN_CAM_INV_VIEW_MATRIX[1],
			MAIN_CAM_INV_VIEW_MATRIX[2],
			MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
    }
}

void fragment() {
	vec4 color = texture(diffuse, UV);
	if (color.a <= 0.0f) { // alpha scissor
		discard;
	}
	
	ALBEDO = color.rgb;
	ALPHA = color.a; // regular alpha
	NORMAL = texture(normal_map, UV).rbg;
}