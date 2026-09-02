shader_type canvas_item;

uniform float chromatic_aberration : hint_range(0.0, 0.1) = 0.02;
uniform float wave_frequency : hint_range(0.0, 50.0) = 10.0;
uniform float wave_amplitude : hint_range(0.0, 0.05) = 0.005;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Wave distortion
    uv.x += sin(uv.y * wave_frequency + TIME * 2.0) * wave_amplitude;
    uv.y += cos(uv.x * wave_frequency + TIME * 1.5) * wave_amplitude;
    
    // Chromatic Aberration
    float r = texture(SCREEN_TEXTURE, uv + vec2(chromatic_aberration, 0.0)).r;
    float g = texture(SCREEN_TEXTURE, uv).g;
    float b = texture(SCREEN_TEXTURE, uv - vec2(chromatic_aberration, 0.0)).b;
    
    COLOR = vec4(r, g, b, 1.0);
}
