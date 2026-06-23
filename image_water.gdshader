shader_type canvas_item;

uniform float water_level = 0.45;
uniform float ripple_speed = 2.0;
uniform float ripple_strength = 0.015;

uniform float fade_top : hint_range(0.0, 1.0) = 0.0;
uniform float fade_bottom : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 uv = UV;
    if (uv.y > water_level) {
        float wave = sin(uv.y * 40.0 + TIME * ripple_speed) * cos(uv.x * 20.0 + TIME * ripple_speed * 0.8);
        float fade = smoothstep(water_level, water_level + 0.1, uv.y);
        uv.x += wave * ripple_strength * fade;
    }
    vec4 tex_color = texture(TEXTURE, uv);
    
    float alpha_fade = 1.0;
    if (uv.y < fade_top && fade_top > 0.0) {
        alpha_fade = smoothstep(0.0, fade_top, uv.y);
    }
    if (uv.y > 1.0 - fade_bottom && fade_bottom > 0.0) {
        alpha_fade = smoothstep(1.0, 1.0 - fade_bottom, uv.y);
    }
    
    COLOR = vec4(tex_color.rgb, tex_color.a * alpha_fade);
}
