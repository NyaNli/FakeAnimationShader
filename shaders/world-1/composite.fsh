#version 430 compatibility
#include "common.inc"

uniform sampler2D colortex0; // 基础色
uniform sampler2D colortex1; // 法线
uniform sampler2D colortex2; // 光照
uniform sampler2D colortex3; // 半透明方块
uniform sampler2D colortex4; // 半透明方块光照

const int RGBA32F = 1;
const int colortex1Format = RGBA32F;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform float nightVision;
uniform float viewWidth;
uniform float viewHeight;

in vec4 pos;

#define LINESTYLE_N 7 // [0 6 7 8 10]
#define LUMPLIGHT_N

// 黑到炸裂的影子
vec3 darkShadow(vec3 light)
{
    if (light.r < 0.3)
        return vec3(0.0);
    return light;
}

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

vec3 linecolor(vec3 color)
{
    // return vec3(0);
    vec3 hsvcolor = rgb2hsv(color);
    // if (hsvcolor.p > 0.1)
    //     hsvcolor.p *= 1.2;
    // else
    //     hsvcolor.p = 0;
    // hsvcolor.t += 0.1;
    hsvcolor.p *= 0.1 * LINESTYLE_N;
    return hsv2rgb(hsvcolor);
}

// 按深度描边（遍历）
vec3 edgelineZTestFor(vec3 color)
{
    float dx = 1.0 / viewWidth;
    float dy = 1.0 / viewHeight;
    float depth0 = linearizeDepth(texture2D(depthtex1, pos.xy).z);
    // float maxx = 0.0;
    // float maxy = 0.0;
    float maxz = 0.0;
    for (float i = -1.0; i < 1.1; i += 1.0)
        for (float j = -1.0; j < 1.1; j += 1.0)
        {
            float depth = linearizeDepth(texture2D(depthtex1, vec2(clamp(pos.x - dx * i, 0.0, 1.0), clamp(pos.y - dy * j, 0.0, 1.0))).z);
            float sub;
            if ((sub = abs(depth - depth0) / depth0) > maxz)
            {
                // maxx = i * dx;
                // maxy = j * dy;
                maxz = sub;
            }
        }
    // return vec3(maxz);
    if (maxz < 0.05)
        return color;
    else
        return linecolor(color);
}

// 按深度描边（遍历）
vec3 edgelineZTestForWater(vec3 color)
{
    float dx = 1.0 / viewWidth;
    float dy = 1.0 / viewHeight;
    float depth0 = linearizeDepth(texture2D(depthtex0, pos.xy).z);
    // float maxx = 0.0;
    // float maxy = 0.0;
    float maxz = 0.0;
    for (float i = -1.0; i < 1.1; i += 1.0)
        for (float j = -1.0; j < 1.1; j += 1.0)
        {
            float depth = linearizeDepth(texture2D(depthtex0, vec2(clamp(pos.x - dx * i, 0.0, 1.0), clamp(pos.y - dy * j, 0.0, 1.0))).z);
            float sub;
            if ((sub = abs(depth - depth0)) > maxz)
            {
                // maxx = i * dx;
                // maxy = j * dy;
                maxz = sub;
            }
        }
    // return vec3(sqrt(maxx * maxx + maxy * maxy) - 0.002 * maxz);
    // if (sqrt(maxx * maxx + maxy * maxy) * 6.0 >= maxz)
    if (maxz < 0.05)
        return color;
    else
        return linecolor(color);
}

// 按深度描边
vec3 edgelineZTest(vec3 color)
{
    float dx = 1.0 / viewWidth;
    float dy = 1.0 / viewHeight;
    float depth0 = linearizeDepth(texture2D(depthtex1, pos.xy).z);
    // float size = max(5.0 * (0.01 - depth0) / 0.01, 1.0);
    // float size = max(3.0 * pow(1.8 * (far - near), -0.5 * depth0), 1.0);
    float size = 1.0;
    float depth1 = linearizeDepth(texture2D(depthtex1, vec2(clamp(pos.x - dx * size, 0.0, 1.0), clamp(pos.y - dy * size, 0.0, 1.0))).z);
    float depth2 = linearizeDepth(texture2D(depthtex1, vec2(clamp(pos.x - dx * size, 0.0, 1.0), clamp(pos.y + dy * size, 0.0, 1.0))).z);
    float depth3 = linearizeDepth(texture2D(depthtex1, vec2(clamp(pos.x + dx * size, 0.0, 1.0), clamp(pos.y - dy * size, 0.0, 1.0))).z);
    float depth4 = linearizeDepth(texture2D(depthtex1, vec2(clamp(pos.x + dx * size, 0.0, 1.0), clamp(pos.y + dy * size, 0.0, 1.0))).z);
    float maxdepth = max(max(abs(depth0-depth1)/depth0, abs(depth0-depth2)/depth0), max(abs(depth0-depth3)/depth0, abs(depth0-depth4)/depth0));
    // if (maxdepth > min(pow(depth0, 1.4), 0.039))
    // if (maxdepth > 0.001)
    if (maxdepth > 0.05)
        return linecolor(color);
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
    // float size = max(3.0 * pow(1.8 * (far - near), -0.5 * depth0), 1.0);
    float size = 1.0;
    float depth1 = linearizeDepth(texture2D(depthtex0, vec2(clamp(pos.x - dx * size, 0.0, 1.0), clamp(pos.y - dy * size, 0.0, 1.0))).z);
    float depth2 = linearizeDepth(texture2D(depthtex0, vec2(clamp(pos.x - dx * size, 0.0, 1.0), clamp(pos.y + dy * size, 0.0, 1.0))).z);
    float depth3 = linearizeDepth(texture2D(depthtex0, vec2(clamp(pos.x + dx * size, 0.0, 1.0), clamp(pos.y - dy * size, 0.0, 1.0))).z);
    float depth4 = linearizeDepth(texture2D(depthtex0, vec2(clamp(pos.x + dx * size, 0.0, 1.0), clamp(pos.y + dy * size, 0.0, 1.0))).z);
    float maxdepth = max(max(abs(depth0-depth1)/depth0, abs(depth0-depth2)/depth0), max(abs(depth0-depth3)/depth0, abs(depth0-depth4)/depth0));
    // if (maxdepth > min(pow(depth0, 1.4), 0.039))
    if (maxdepth > 0.05)
        return linecolor(color);
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
        return linecolor(color);
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
        return mix(linecolor(color), color, nightVision);
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
        return mix(linecolor(color), color, nightVision);
    else
        return color;
}

void main()
{
    vec4 lightcolor = texture2D(colortex2, pos.xy);
#ifdef LUMPLIGHT_N
    lightcolor.rgb = effectVisionLight(lightcolor.rgb);
    lightcolor.rgb = darkShadow(lightcolor.rgb);
#endif

    vec4 color = texture2D(colortex0, pos.xy) * lightcolor;
    // color.rgb = effectVisionColor(color.rgb);
    if (LINESTYLE_N < 9)
    {
        color.rgb = edgelineZTest(color.rgb);
        color.rgb = edgelineLight(color.rgb);
    }

    vec4 waterlight = texture2D(colortex4, pos.xy);
#ifdef LUMPLIGHT_N
    waterlight.rgb = effectVisionLight(waterlight.rgb);
    waterlight.rgb = darkShadow(waterlight.rgb);
#endif

    vec4 watercolor = texture2D(colortex3, pos.xy) * waterlight;
    if (LINESTYLE_N < 9)
    {
        watercolor.rgb = edgelineZTestWater(watercolor.rgb);
        watercolor.rgb = edgelineLightWater(watercolor.rgb);
    }

    color.rgb = mixWater(color.rgb, watercolor);
    if (LINESTYLE_N < 9)
        color.rgb = edgelineNormalTest(color.rgb);

    // gl_FragData[0] = vec4(vec3(linearizeDepth(texture2D(depthtex1, pos.xy).z)), 1.0);
    gl_FragData[0] = color;
    // gl_FragData[0] = vec4(vec3(texture2D(gnormal, pos.xy).xyz * 0.5 + 0.5), 1.0);
    // gl_FragData[0] = vec4(texture2D(colortex7, pos.xy).xyz * 0.5 + 0.5, 1.0);
}
/* DRAWBUFFERS:0 */