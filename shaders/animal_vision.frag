#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 resolution;
uniform float visionMode;
uniform sampler2D inputTexture;

out vec4 fragColor;

vec4 catVision(vec4 color) {
    // 调整色彩敏感度，增强蓝绿色
    color.r *= 0.7;
    color.g *= 1.2;
    color.b *= 1.1;

    // 提高亮度以模拟夜视能力
    float brightness = (color.r + color.g + color.b) / 3.0;
    color.rgb = mix(color.rgb, vec3(brightness), 0.2);

    // 添加轻微的模糊效果以模拟较低的视觉清晰度
    vec2 pixelSize = 1.0 / resolution.xy;
    vec4 blur = vec4(0.0);
    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            vec2 offset = vec2(float(i), float(j)) * pixelSize;
            blur += texture(inputTexture, FlutterFragCoord().xy / resolution.xy + offset);
        }
    }
    blur /= 9.0;

    return mix(color, blur, 0.2);
}

vec4 dogVision(vec4 color) {
    // 将颜色转换为二色视觉（主要是蓝色和黄色）
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    float blue = (color.b * 0.7 + gray * 0.3);
    float yellow = (color.r * 0.4 + color.g * 0.6) * 0.7 + gray * 0.3;
    color.rgb = vec3(yellow, yellow, blue);

    // 增强边缘检测以模拟对运动的敏感性
    vec2 pixelSize = 1.0 / resolution.xy;
    vec2 uv = FlutterFragCoord().xy / resolution.xy;
    vec4 h = texture(inputTexture, uv + vec2(pixelSize.x, 0.0)) - texture(inputTexture, uv - vec2(pixelSize.x, 0.0));
    vec4 v = texture(inputTexture, uv + vec2(0.0, pixelSize.y)) - texture(inputTexture, uv - vec2(0.0, pixelSize.y));
    float edge = length(h) + length(v);

    color.rgb = mix(color.rgb, vec3(1.0), edge * 2.0);

    // 降低中心视力清晰度
    vec2 center = uv - 0.5;
    float dist = length(center);
    float blur = smoothstep(0.0, 0.5, dist);
    color.rgb = mix(color.rgb, vec3(gray), blur * 0.5);

    return color;
}

vec4 parrotVision(vec4 color) {
    // 增强色彩饱和度
    vec3 luminance = vec3(0.299, 0.587, 0.114);
    float lum = dot(color.rgb, luminance);
    color.rgb = mix(vec3(lum), color.rgb, 1.5);

    // 添加模拟的紫外线通道
    float uv_intensity = (color.r * 0.3 + color.g * 0.4 + color.b * 0.3);
    vec3 uv_color = vec3(0.8, 0.0, 1.0); // 用紫色代表紫外线
    color.rgb = mix(color.rgb, uv_color, uv_intensity * 0.3);

    // 扩展色域以模拟四色视觉
    color.r = pow(color.r, 0.8);
    color.g = pow(color.g, 0.9);
    color.b = pow(color.b, 0.7);

    // 增加对比度以模拟更宽的色域
    color.rgb = (color.rgb - 0.5) * 1.2 + 0.5;

    return color;
}

void main() {
    vec2 uv = FlutterFragCoord().xy / resolution.xy;
    vec4 color = texture(inputTexture, uv);
    vec4 finalColor = color;

    if (visionMode < 0.5) {
        finalColor = catVision(color);
    } else if (visionMode < 1.5) {
        finalColor = dogVision(color);
    } else {
        finalColor = parrotVision(color);
    }

    fragColor = finalColor;
}