#version 430 compatibility
#include "common.inc"

uniform mat4 gbufferModelViewInverse;

uniform sampler2D colortex0; // 基础色
uniform sampler2D colortex1; // 法线
uniform sampler2D colortex2; // 光照
uniform sampler2D colortex3; // 半透明方块
uniform sampler2D colortex4; // 半透明方块光照
uniform sampler2D colortex7; // test

const int RGBA32F = 1;
const int colortex1Format = RGBA32F;
const int colortex7Format = RGBA32F;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform float nightVision;
uniform float viewWidth;
uniform float viewHeight;

in vec4 pos;

// 黑到炸裂的影子（废弃）
// vec3 darkShadow(vec3 light)
// {
//     float n;
//     if (isEyeInWater != 2)
//         n = 0.15;
//     else
//         n = 0;
//     if (rgb2hsv(light).p < n)
//         return vec3(0.0);
//     return light;
// }

// 夜视光照
vec3 effectVisionLight(vec3 light)
{
    float n = max(nightVision * 2.0 - 1.0, 0.0);
    return mix(light, vec3(1.0), n);
    // vec3 hsvlight = rgb2hsv(light);
    // hsvlight.p += (1.0 - hsvlight.p) * n;
    // return hsv2rgb(hsvlight);
    // if (nightVision > 0.99)
    //     return vec3(1.0);
    // return light;
}

// 混合半透明与不透明
vec3 mixWater(vec3 color, vec4 watercolor)
{
    return mix(color, watercolor.rgb, pow(watercolor.a, 0.7));
}

// 按深度描边
vec3 edgelineZTest(vec3 color)
{
    float dx = 1.0 / viewWidth;
    float dy = 1.0 / viewHeight;
    float depth0 = linearizeDepth(texture2D(depthtex1, pos.xy).z);
    // float size = max(10.0 * (0.01 - depth0) / 0.01, 0.5);
    float size = max(3.0 * pow(1.8 * (far - near), -0.5 * depth0), 1.0);
    // float size = 1.0;
    float depth1 = linearizeDepth(texture2D(depthtex1, vec2(clamp(pos.x - dx * size, 0.0, 1.0), clamp(pos.y - dy * size, 0.0, 1.0))).z);
    float depth2 = linearizeDepth(texture2D(depthtex1, vec2(clamp(pos.x - dx * size, 0.0, 1.0), clamp(pos.y + dy * size, 0.0, 1.0))).z);
    float depth3 = linearizeDepth(texture2D(depthtex1, vec2(clamp(pos.x + dx * size, 0.0, 1.0), clamp(pos.y - dy * size, 0.0, 1.0))).z);
    float depth4 = linearizeDepth(texture2D(depthtex1, vec2(clamp(pos.x + dx * size, 0.0, 1.0), clamp(pos.y + dy * size, 0.0, 1.0))).z);
    float maxdepth = max(max(abs(depth0-depth1), abs(depth0-depth2)), max(abs(depth0-depth3), abs(depth0-depth4)));
    if (maxdepth > min(pow(depth0, 1.4), 0.039))
        return vec3(0);
    else
        return color;
        // return vec3(1);
}

// 按深度描边
vec3 edgelineZTestWater(vec3 color)
{
    float dx = 1.0 / viewWidth;
    float dy = 1.0 / viewHeight;
    float depth0 = linearizeDepth(texture2D(depthtex0, pos.xy).z);
    // float size = max(10.0 * (0.01 - depth0) / 0.01, 0.5);
    float size = max(3.0 * pow(1.8 * (far - near), -0.5 * depth0), 1.0);
    // float size = 1.0;
    float depth1 = linearizeDepth(texture2D(depthtex0, vec2(clamp(pos.x - dx * size, 0.0, 1.0), clamp(pos.y - dy * size, 0.0, 1.0))).z);
    float depth2 = linearizeDepth(texture2D(depthtex0, vec2(clamp(pos.x - dx * size, 0.0, 1.0), clamp(pos.y + dy * size, 0.0, 1.0))).z);
    float depth3 = linearizeDepth(texture2D(depthtex0, vec2(clamp(pos.x + dx * size, 0.0, 1.0), clamp(pos.y - dy * size, 0.0, 1.0))).z);
    float depth4 = linearizeDepth(texture2D(depthtex0, vec2(clamp(pos.x + dx * size, 0.0, 1.0), clamp(pos.y + dy * size, 0.0, 1.0))).z);
    float maxdepth = max(max(abs(depth0-depth1), abs(depth0-depth2)), max(abs(depth0-depth3), abs(depth0-depth4)));
    if (maxdepth > min(pow(depth0, 1.4), 0.039))
        return vec3(0);
    else
        return color;
        // return vec3(1);
}

// 按法线描边
vec3 edgelineNormalTest(vec3 color)
{
    float dx = 1.0 / viewWidth;
    float dy = 1.0 / viewHeight;
    vec3 normal0 = texture2D(colortex1, pos.xy).xyz;
    float depth0 = linearizeDepth(texture2D(depthtex0, pos.xy).z);
    // float size = max(2.5 * (0.5 - depth0) / 0.5, 1.0);
    float size = 2.0 * pow(2.0 * (far - near), -depth0);
    vec3 normal1 = texture2D(colortex1, vec2(clamp(pos.x - dx * size, 0.0, 1.0), clamp(pos.y - dy * size, 0.0, 1.0))).xyz;
    vec3 normal2 = texture2D(colortex1, vec2(clamp(pos.x - dx * size, 0.0, 1.0), clamp(pos.y + dy * size, 0.0, 1.0))).xyz;
    vec3 normal3 = texture2D(colortex1, vec2(clamp(pos.x + dx * size, 0.0, 1.0), clamp(pos.y - dy * size, 0.0, 1.0))).xyz;
    vec3 normal4 = texture2D(colortex1, vec2(clamp(pos.x + dx * size, 0.0, 1.0), clamp(pos.y + dy * size, 0.0, 1.0))).xyz;
    float minnormal = min(min(abs(dot(normal0,normal1)), abs(dot(normal0,normal2))), min(abs(dot(normal0,normal3)), abs(dot(normal0,normal4))));
    // return vec3(minnormal);
    if (minnormal < 0.90)
        return vec3(0);
    else
        return color;
}

// 光线描边
vec3 edgelineLight(vec3 color)
{
    float dx = 1.0 / viewWidth;
    float dy = 1.0 / viewHeight;
    float b0 = rgb2hsv(texture2D(colortex2, pos.xy).rgb).p;
    float depth0 = linearizeDepth(texture2D(depthtex1, pos.xy).z);
    // float size = max(2.5 * (0.5 - depth0) / 0.5, 1.0);
    float size = 1.0 * pow(2.0 * (far - near), -depth0);
    float b1 = rgb2hsv(texture2D(colortex2, vec2(clamp(pos.x - dx * size, 0.0, 1.0), clamp(pos.y - dy * size, 0.0, 1.0))).rgb).p;
    float b2 = rgb2hsv(texture2D(colortex2, vec2(clamp(pos.x - dx * size, 0.0, 1.0), clamp(pos.y + dy * size, 0.0, 1.0))).rgb).p;
    float b3 = rgb2hsv(texture2D(colortex2, vec2(clamp(pos.x + dx * size, 0.0, 1.0), clamp(pos.y - dy * size, 0.0, 1.0))).rgb).p;
    float b4 = rgb2hsv(texture2D(colortex2, vec2(clamp(pos.x + dx * size, 0.0, 1.0), clamp(pos.y + dy * size, 0.0, 1.0))).rgb).p;
    if (abs(b0 - b1) > 0.01 || abs(b0 - b2) > 0.01 || abs(b0 - b3) > 0.01 || abs(b0 - b4) > 0.01)
        return mix(vec3(0.0), color, nightVision);
    else
        return color;
}

// 光线描边
vec3 edgelineLightWater(vec3 color)
{
    float dx = 1.0 / viewWidth;
    float dy = 1.0 / viewHeight;
    float b0 = rgb2hsv(texture2D(colortex4, pos.xy).rgb).p;
    float depth0 = linearizeDepth(texture2D(depthtex0, pos.xy).z);
    // float size = max(2.5 * (0.5 - depth0) / 0.5, 1.0);
    float size = 1.0 * pow(2.0 * (far - near), -depth0);
    float b1 = rgb2hsv(texture2D(colortex4, vec2(clamp(pos.x - dx * size, 0.0, 1.0), clamp(pos.y - dy * size, 0.0, 1.0))).rgb).p;
    float b2 = rgb2hsv(texture2D(colortex4, vec2(clamp(pos.x - dx * size, 0.0, 1.0), clamp(pos.y + dy * size, 0.0, 1.0))).rgb).p;
    float b3 = rgb2hsv(texture2D(colortex4, vec2(clamp(pos.x + dx * size, 0.0, 1.0), clamp(pos.y - dy * size, 0.0, 1.0))).rgb).p;
    float b4 = rgb2hsv(texture2D(colortex4, vec2(clamp(pos.x + dx * size, 0.0, 1.0), clamp(pos.y + dy * size, 0.0, 1.0))).rgb).p;
    if (abs(b0 - b1) > 0.01 || abs(b0 - b2) > 0.01 || abs(b0 - b3) > 0.01 || abs(b0 - b4) > 0.01)
        return mix(vec3(0.0), color, nightVision);
    else
        return color;
}

void main()
{
    vec4 lightcolor = texture2D(colortex2, pos.xy);
    lightcolor.rgb = effectVisionLight(lightcolor.rgb);
    // lightcolor.rgb = darkShadow(lightcolor.rgb);

    vec4 color = texture2D(colortex0, pos.xy) * lightcolor;
    // color.rgb = effectVisionColor(color.rgb);
    color.rgb = edgelineZTest(color.rgb);
    color.rgb = edgelineLight(color.rgb);

    vec4 waterlight = texture2D(colortex4, pos.xy);
    waterlight.rgb = effectVisionLight(waterlight.rgb);

    vec4 watercolor = texture2D(colortex3, pos.xy) * waterlight;
    watercolor.rgb = edgelineZTestWater(watercolor.rgb);
    watercolor.rgb = edgelineLightWater(watercolor.rgb);


    color.rgb = mixWater(color.rgb, watercolor);
    color.rgb = edgelineNormalTest(color.rgb);

    // gl_FragData[0] = vec4(vec3(linearizeDepth(texture2D(depthtex1, pos.xy).z)), 1.0);
    // gl_FragData[0] = texture2D(colortex2, pos.xy);
    gl_FragData[0] = color;
    // gl_FragData[0] = vec4(vec3(texture2D(gnormal, pos.xy).xyz * 0.5 + 0.5), 1.0);
    // vec3 n = normalize((gbufferModelViewInverse * texture2D(colortex1, pos.xy)).xyz);
    // gl_FragData[0] = vec4(n * 0.5 + 0.5, 1.0);
}
/* DRAWBUFFERS:0 */