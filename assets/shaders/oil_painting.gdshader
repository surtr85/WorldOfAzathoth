shader_type canvas_item;
// Oil Painting Post-Processing Shader (Kuwahara Filter approach)

uniform float radius : hint_range(1.0, 10.0) = 4.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 src_size = vec2(textureSize(SCREEN_TEXTURE, 0));
    vec2 uv = SCREEN_UV;
    float n = float((int(radius) + 1) * (int(radius) + 1));

    vec3 m[4];
    vec3 s[4];
    for (int i = 0; i < 4; ++i) {
        m[i] = vec3(0.0);
        s[i] = vec3(0.0);
    }

    struct Bounds {
        int r_start; int r_end;
        int c_start; int c_end;
    } bounds[4];

    int rad = int(radius);
    bounds[0] = Bounds(-rad, 0, -rad, 0);
    bounds[1] = Bounds(0, rad, -rad, 0);
    bounds[2] = Bounds(0, rad, 0, rad);
    bounds[3] = Bounds(-rad, 0, 0, rad);

    for (int k = 0; k < 4; ++k) {
        for (int i = bounds[k].r_start; i <= bounds[k].r_end; ++i) {
            for (int j = bounds[k].c_start; j <= bounds[k].c_end; ++j) {
                vec3 c = texture(SCREEN_TEXTURE, uv + vec2(float(i), float(j)) / src_size).rgb;
                m[k] += c;
                s[k] += c * c;
            }
        }
    }

    float min_sigma2 = 1e2;
    vec3 final_color = vec3(0.0);

    for (int k = 0; k < 4; ++k) {
        m[k] /= n;
        s[k] = abs(s[k] / n - m[k] * m[k]);
        float sigma2 = s[k].r + s[k].g + s[k].b;
        if (sigma2 < min_sigma2) {
            min_sigma2 = sigma2;
            final_color = m[k];
        }
    }

    COLOR = vec4(final_color, 1.0);
}
