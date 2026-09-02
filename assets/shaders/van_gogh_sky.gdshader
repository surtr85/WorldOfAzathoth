shader_type canvas_item;

uniform vec4 sky_color : source_color = vec4(0.05, 0.05, 0.2, 1.0);
uniform vec4 swirl_color1 : source_color = vec4(0.2, 0.4, 0.8, 1.0);
uniform vec4 swirl_color2 : source_color = vec4(0.9, 0.8, 0.3, 1.0);
uniform float swirl_speed : hint_range(0.0, 5.0) = 0.5;
uniform float swirl_scale : hint_range(1.0, 50.0) = 15.0;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    mat2 rot = mat2(vec2(cos(0.5), sin(0.5)), vec2(-sin(0.5), cos(0.5)));
    for (int i = 0; i < 4; ++i) {
        v += a * noise(p);
        p = rot * p * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void fragment() {
    vec2 uv = UV * swirl_scale;
    float t = TIME * swirl_speed;
    
    // Swirling vector field (Van Gogh style flow)
    vec2 q = vec2(0.0);
    q.x = fbm(uv + 0.1 * t);
    q.y = fbm(uv + vec2(1.0));
    
    vec2 r = vec2(0.0);
    r.x = fbm(uv + 1.0 * q + vec2(1.7, 9.2) + 0.15 * t);
    r.y = fbm(uv + 1.0 * q + vec2(8.3, 2.8) + 0.126 * t);
    
    float f = fbm(uv + r);
    
    vec4 col = mix(sky_color, swirl_color1, clamp(f * f * 4.0, 0.0, 1.0));
    col = mix(col, swirl_color2, clamp(length(q), 0.0, 1.0));
    
    COLOR = col;
}
