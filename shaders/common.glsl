// Общее для переходов «Обоев». Подключается сборщиком build.sh перед телом шейдера.
// Свой код, без заимствований из gl-transitions.
#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;   // 0 старые обои, 1 новые
    float aspect;     // ширина / высота экрана
    float seed;       // случайное число на каждый переход
    vec4 glow;        // цвет кромки (золото like_dali)
};
layout(binding = 1) uniform sampler2D fromTex;
layout(binding = 2) uniform sampler2D toTex;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1, 0)), u.x),
               mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), u.x), u.y);
}

float fbm(vec2 p) {
    float v = 0.0, a = 0.5;
    for (int k = 0; k < 5; k++) { v += a * noise(p); p *= 2.03; a *= 0.5; }
    return v;
}

// Яркая кромка шириной w вокруг границы d = 0, гаснет к концу перехода
float rim(float d, float w) {
    return exp(-(d * d) / (w * w)) * smoothstep(0.0, 0.08, progress) * (1.0 - smoothstep(0.85, 1.0, progress));
}
