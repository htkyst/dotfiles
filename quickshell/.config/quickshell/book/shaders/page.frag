#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    float direction;
    float bendY;
};
layout(binding = 1) uniform sampler2D rightPage;
layout(binding = 2) uniform sampler2D leftPage;

const float PI = 3.14159265359;
const float PAGE_WIDTH = 611.0;
const vec2 IMAGE_SIZE = vec2(1536.0, 1024.0);

// The PNGs contain transparent margins. Sample in ORIGINAL image coordinates,
// never stretch the entire PNG into the bounds of a single page.
vec4 paper(float u, float y, float normal, float wave) {
    if (u < 0.0 || u > 1.0 || y < 0.0 || y > IMAGE_SIZE.y)
        return vec4(0.0);
    float side = normal >= 0.0 ? direction : -direction;
    vec2 uv = vec2(768.0 + side * PAGE_WIDTH * u, y) / IMAGE_SIZE;
    vec4 texel = side > 0.0 ? texture(rightPage, uv) : texture(leftPage, uv);
    // Qt textures are premultiplied; preserve alpha and shade RGB only.
    float shade = 1.0 - 0.30 * wave * (1.0 - abs(normal));
    texel.rgb *= shade;
    return texel;
}

vec4 intersection(vec2 pixel, float theta, float start, float curl, float wave) {
    float u = (theta - start) / curl;
    float z = PAGE_WIDTH * (cos(start) - cos(theta)) / curl;
    float originalY = pixel.y + 0.12 * z - bendY * u * wave;
    return paper(u, originalY, cos(theta), wave);
}

// Invert the cylindrical cross section per pixel. Two intersections may
// project to the same x; composite the near one over the far one explicitly.
// This avoids both strip seams and Qt Quick's lack of a 3D depth buffer.
vec4 sheetAt(vec2 pixel, float p, float wave) {
    float curl = 1.45 * wave;
    float start = PI * p - curl * 0.5;
    float x = direction * (pixel.x - 768.0) / PAGE_WIDTH;
    if (curl < 0.0001) {
        float normal = p < 0.5 ? 1.0 : -1.0;
        return paper(x * normal, pixel.y, normal, 0.0);
    }
    float sine = sin(start) + curl * x;
    if (sine < 0.0 || sine > 1.0) return vec4(0.0);
    float first = asin(clamp(sine, 0.0, 1.0));
    float second = PI - first;
    vec4 farColor = intersection(pixel, first, start, curl, wave);
    vec4 nearColor = intersection(pixel, second, start, curl, wave);
    return nearColor + farColor * (1.0 - nearColor.a);
}

void main() {
    float p = clamp(progress, 0.0, 1.0);
    float wave = max(0.0, sin(PI * p));
    vec2 pixel = qt_TexCoord0 * vec2(1536.0, 1280.0) - vec2(0.0, 160.0);
    vec4 page = sheetAt(pixel, p, wave);
    // A small three-tap shadow stays on the book beneath the raised paper.
    vec2 shadowPixel = pixel - vec2(direction * 18.0, 30.0) * wave;
    float shadow = (sheetAt(shadowPixel, p, wave).a * 0.5
                  + sheetAt(shadowPixel + vec2(5.0, 3.0), p, wave).a * 0.25
                  + sheetAt(shadowPixel - vec2(5.0, 3.0), p, wave).a * 0.25)
                  * 0.15 * wave;
    vec4 shade = vec4(vec3(0.075, 0.04, 0.015) * shadow, shadow);
    fragColor = (page + shade * (1.0 - page.a)) * qt_Opacity;
}
