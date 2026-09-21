shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);

    // CanvasGroup's buffer is premultiplied.
    if (c.a > 0.0001) {
        c.rgb /= c.a;
    }

    c.rgb = mix(c.rgb, vec3(1.0), flash_amount);

    COLOR *= c;
}