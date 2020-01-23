#version 430 compatibility
#include "common.inc"

uniform sampler2D colortex0;

uniform sampler2D depthtex0;

uniform float nightVision;
uniform float blindness;
// uniform int isEyeInWater;
// uniform int worldTime;
// uniform float rainStrength;

in vec4 pos;

// vec3 dayColor = vec3(1.2, 1.0, 0.9);
// vec3 nightColor = vec3(0.7, 0.7, 1.0);

#define AFTEREFFECT_N
#define REDONLY

vec3 UnderWater(vec3 color)
{
    vec3 hsvcolor = rgb2hsv(color);
    hsvcolor.t *= 1.32;
    hsvcolor.p *= 0.8;
    vec3 color2 = hsv2rgb(hsvcolor);
    // color2 *= vec3(0.8, 0.8, 1.0);
    return color2;
}

// 颜色层处理夜视、致盲效果
vec3 effectVisionColor(vec3 color)
{
    vec3 hsvcolor = rgb2hsv(color);
    if (nightVision > 0.0)
    {
        hsvcolor.t *= 1.0 + nightVision * 0.2;
        hsvcolor.p *= 1.0 + nightVision * 0.4;
        color = hsv2rgb(hsvcolor);
    }
    float depth = texture2D(depthtex0, pos.xy).z;
    vec4 viewPosition = gbufferProjectionInverse * vec4(pos.x * 2.0 - 1.0, pos.y * 2.0 - 1.0, 2.0 * depth - 1.0, 1.0f);
    viewPosition /= viewPosition.w;
    vec4 camPosition = gbufferModelViewInverse * viewPosition;
    float dis = length(camPosition.xyz);
    if (hsvcolor.p < blindness * 1.2 && (dis > 10.0 || hsvcolor.p < 0.1 * dis))
        color = vec3(0.0);
    return color;
}

// 调色
vec3 aftereffect(vec3 color)
{
    vec3 hsvcolor = rgb2hsv(color);
    hsvcolor.t *= 1.8;
    hsvcolor.p = pow(hsvcolor.p * 2, 1.2);// * 0.5;
    // color *= mix(mix(nightColor, dayColor, n), vec3(1.0), rainStrength);
    color = hsv2rgb(hsvcolor);
    float depth = linearizeDepth(texture2D(depthtex0, pos.xy).z);
#ifdef REDONLY
    vec3 fogcolor = vec3(1,0,0);
#else
    vec3 fogcolor = gl_Fog.color.rgb;
#endif
    if (depth > 0.25)
        color = mix(color, fogcolor, clamp(depth * 2.0 - 0.5, 0.0, 1.0));
    return color;
}

void main()
{
    vec4 color = texture2D(colortex0, pos.xy);
    // if (isEyeInWater == 1)
    //     color.rgb = UnderWater(color.rgb);
#ifdef AFTEREFFECT_N
    color.rgb = effectVisionColor(color.rgb);
    color.rgb = aftereffect(color.rgb);
#endif

    gl_FragColor = color;
}