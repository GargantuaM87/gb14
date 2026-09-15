shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

uniform vec4 darkest  : source_color = vec4(0.137, 0.224, 0.200, 1.0);
uniform vec4 dark     : source_color = vec4(0.639, 0.341, 0.306, 1.0);
uniform vec4 light    : source_color = vec4(0.902, 0.725, 0.353, 1.0);
uniform vec4 lightest : source_color = vec4(0.835, 0.847, 0.820, 1.0);

uniform float threshold_1 : hint_range(0.0, 1.0) = 0.25;
uniform float threshold_2 : hint_range(0.0, 1.0) = 0.50;
uniform float threshold_3 : hint_range(0.0, 1.0) = 0.75;

void fragment() {
    vec4 source = texture(screen_texture, SCREEN_UV);

    float brightness = dot(
        source.rgb,
        vec3(0.333, 0.333, 0.333)
    );

    vec3 result;

    if (brightness < threshold_1) {
        result = darkest.rgb;
    } else if (brightness < threshold_2) {
        result = dark.rgb;
    } else if (brightness < threshold_3) {
        result = light.rgb;
    } else {
        result = lightest.rgb;
    }

    COLOR = vec4(result, source.a);
}