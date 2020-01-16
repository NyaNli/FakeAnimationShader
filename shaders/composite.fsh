#version 430 compatibility
#include "common.inc"

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferPreviousProjection;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;

const int RGBA32F = 1;
const int R8 = 1;
const int colortex1Format = RGBA32F;
const int colortex5Format = RGBA32F;
const int colortex6Format = R8;

uniform sampler2D colortex0; // 基础色
uniform sampler2D colortex1; // 法线
uniform sampler2D colortex2; // 光照
uniform sampler2D colortex3; // 半透明方块
uniform sampler2D colortex4; // 半透明方块光照
uniform sampler2D colortex5; // 法线（不带透明）
uniform sampler2D colortex6; // 是否手臂

uniform sampler2D depthtex0; // 带透明
uniform sampler2D depthtex1; // 不带透明
uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;

uniform vec3 shadowLightPosition;
uniform float rainStrength;
uniform int IsEyeInWater;

#define SHADOW_MAP_BIAS 0.9

#define LUMPLIGHT
#define REALTIMESHADOW

vec3 suncolor = vec3(1.0);
vec3 mooncolor = vec3(0.2, 0.2, 0.35);

in vec4 pos;

vec3 sunlightSolid(vec3 light)
{
    float n = sunHeight() * 0.5 + 0.5;
    float n2 = shadowlightHeight();
    float depth = texture2D(depthtex1, pos.xy).z;
    float isHand = texture2D(colortex6, pos.xy).r;
    vec3 normal = texture2D(colortex5, pos.xy).xyz;
    float maxlight = clamp(dot(normalize(shadowLightPosition),normal) * 2.0, 0.0, 1.0);
    vec4 viewPosition = gbufferProjectionInverse * vec4(pos.s * 2.0 - 1.0, pos.t * 2.0 - 1.0, 2.0 * depth - 1.0, 1.0f);
    viewPosition /= viewPosition.w;
    vec4 camPosition = gbufferModelViewInverse * viewPosition;
    // camPosition /= camPosition.w;
    if (isHand < 1.0)
        camPosition = camPosition + vec4(depth * 0.06 * normalize((gbufferModelViewInverse * vec4(normal, 1.0)).xyz), 0.0);
    vec4 shadowPosition0 = shadowProjection * shadowModelView * camPosition;
    vec4 shadowPosition = shadowPosition0;
    float distb = length(shadowPosition.xy);
    float distortFactor = (1.0 - SHADOW_MAP_BIAS) + distb * SHADOW_MAP_BIAS;
    shadowPosition.xy /= distortFactor;
    shadowPosition /= shadowPosition.w;
    shadowPosition0 = shadowPosition0 * 0.5 + 0.5;
    shadowPosition = shadowPosition * 0.5 + 0.5;
    float shadowDepth = texture2D(shadowtex1, shadowPosition.xy).z;
    if (isHand > 0.0)
        shadowDepth += 0.0018;
    vec3 sunlight = vec3(0.0);
    vec3 suncolor = mix(mooncolor, suncolor, n) * n2;
    if (shadowDepth >= shadowPosition.z)
    {
        sunlight = suncolor;
        float waterDepth = texture2D(shadowtex0, shadowPosition.xy).z;
        if (isHand > 0.0)
            waterDepth += 0.0018;
        if (waterDepth < shadowPosition.z)
        {
            vec4 shadowcolor = texture2D(shadowcolor0, shadowPosition.xy);
            sunlight = mix(sunlight, shadowcolor.rgb * sunlight, shadowcolor.a);// * (shadowPosition.z - waterDepth) * 30.0);
            sunlight = mix(sunlight, light, (shadowPosition.z - waterDepth) * (12.0 - sunHeight() * 6.0));
        }
    }
    sunlight = mix(light, sunlight, maxlight);
    sunlight = mix(sunlight, light, rainStrength);
#ifdef LUMPLIGHT
    if (rgb2hsv(sunlight).p > rgb2hsv(light).p)
        return sunlight;
    else if (rgb2hsv(light).p > 0.15)
        return mix(sunlight, light, clamp(3.0*(rgb2hsv(light).p - rgb2hsv(sunlight).p), 0.0, 1.0));
    else
        return light;
#else
    // return mix(sunlight, light, clamp(3.0*(rgb2hsv(light).p - rgb2hsv(sunlight).p), 0.0, 1.0));
    return sunlight + light;
#endif
}

vec3 sunlightWater(vec3 light)
{
    float n = sunHeight() * 0.5 + 0.5;
    float n2 = shadowlightHeight();
    float depth = texture2D(depthtex0, pos.xy).z;
    float isHand = texture2D(colortex6, pos.xy).r;
    vec3 normal = texture2D(colortex1, pos.xy).xyz;
    float maxlight = clamp(dot(normalize(shadowLightPosition),normal) * 2.0, 0.0, 1.0);
    vec4 viewPosition = gbufferProjectionInverse * vec4(pos.s * 2.0 - 1.0, pos.t * 2.0 - 1.0, 2.0 * depth - 1.0, 1.0f);
    viewPosition /= viewPosition.w;
    vec4 camPosition = gbufferModelViewInverse * viewPosition;
    if (isHand < 1.0)
        camPosition = camPosition + vec4(depth * 0.06 * normalize((gbufferModelViewInverse * vec4(normal, 1.0)).xyz), 0.0);
    vec4 shadowPosition0 = shadowProjection * shadowModelView * camPosition;
    vec4 shadowPosition = shadowPosition0;
    float distb = length(shadowPosition.xy);
    float distortFactor = (1.0 - SHADOW_MAP_BIAS) + distb * SHADOW_MAP_BIAS;
    shadowPosition.xy /= distortFactor;
    shadowPosition /= shadowPosition.w;
    shadowPosition0 = shadowPosition0 * 0.5 + 0.5;
    shadowPosition = shadowPosition * 0.5 + 0.5;
    float shadowDepth = texture2D(shadowtex0, shadowPosition.xy).z;
    if (isHand > 0.0)
        shadowDepth += 0.0018;
    vec3 sunlight = vec3(0.0);
    if (shadowDepth > shadowPosition.z)
    {
        sunlight = mix(mooncolor, suncolor, n) * n2;
    }
    sunlight = mix(light, sunlight, maxlight);
    sunlight = mix(sunlight, light, rainStrength);
#ifdef LUMPLIGHT
    if (rgb2hsv(sunlight).p > rgb2hsv(light).p)
        return sunlight;
    else if (rgb2hsv(light).p > 0.15)
        return mix(sunlight, light, clamp(3.0*(rgb2hsv(light).p - rgb2hsv(sunlight).p), 0.0, 1.0));
    else
        return light;
#else
    // return mix(sunlight, light, clamp(3.0*(rgb2hsv(light).p - rgb2hsv(sunlight).p), 0.0, 1.0));
    return sunlight + light;
#endif
}

void main()
{
    vec4 solidlight = texture2D(colortex2, pos.xy);
#ifdef REALTIMESHADOW
    solidlight.rgb = sunlightSolid(solidlight.rgb);
#endif

    gl_FragData[0] = texture2D(colortex0, pos.xy);
    gl_FragData[1] = texture2D(colortex1, pos.xy);
    gl_FragData[2] = solidlight;
    gl_FragData[3] = texture2D(colortex3, pos.xy);

    if (texture2D(colortex3, pos.xy).a > 0)
    {
        vec4 waterlight = texture2D(colortex4, pos.xy);
#ifdef REALTIMESHADOW
        waterlight.rgb = sunlightWater(waterlight.rgb);
#endif
        // gl_FragData[3] = waterlight;
        gl_FragData[4] = waterlight;
    }
    else
    {
        // gl_FragData[3] = texture2D(colortex3, pos.xy);
        gl_FragData[4] = texture2D(colortex4, pos.xy);
    }
}
/* DRAWBUFFERS:01234 */
