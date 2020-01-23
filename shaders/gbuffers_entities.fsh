#version 430 compatibility
#include "common.inc"

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform int fogMode;
uniform sampler2D texture;
uniform sampler2D lightmap;

uniform float rainStrength;
uniform float nightVision;
// uniform int worldTime;

in vec4 color;
in vec4 texpos;
in vec4 lmpos;
in vec4 normal;

#define LUMPLIGHT
#define REALTIMESHADOW

void main()
{
    vec2 lights;
    lights.x = pow(lm2n(lmpos.x), 1.4);

#ifdef REALTIMESHADOW
    if (rainStrength > 0.99)
        if (rgb2hsv(texture2D(lightmap, n2lm(vec2(0.0, 1.0))).rgb).p > 0.985211)
            lights.y = max(lm2n(lmpos.y) - 0.9, 0.0) * 10.0;
    else
        lights.y = max(lm2n(lmpos.y) - (0.8 - 0.1 * sunHeight()) - rainStrength * 0.05, 0.0);
#else
    lights.y = lm2n(lmpos.y);
#endif

    float dark = lm2n(lmpos.y) < 0.7 - 0.2 * sunHeight() + rainStrength * (0.05 + sunHeight() * 0.095 + 0.095) ? 1.0 : 0.0;

#ifdef LUMPLIGHT
#ifdef REALTIMESHADOW
    // 天空 0.5 0.1 0.05
    if (lights.y > 0.5)
        lights.y = 1.0;
    else if (lights.y > 0.08)
        lights.y = 0.1;
    else if (lights.y > 0.02)
        lights.y = 0.05;
    else
        lights.y = 0;
#else
    if (lights.y > 0.6)
        lights.y = 1.0;
    else if (lights.y > 0.3)
        lights.y = 0.6;
    else if (lights.y > 0.1)
        lights.y = 0.3;
    else
        lights.y = 0;
#endif

    // 方块 0.6 0.3 0.1 
    if (lights.x > 0.6)
        lights.x = 1.0;
    else if (lights.x > 0.3)
        lights.x = 0.6;
    else if (lights.x > 0.1)
        lights.x = 0.3;
    else
        lights.x = 0;
#else
    dark = 0;
#endif

    vec4 lightcolor;
    if (dark > 0 && lights.x < 0.3)
        lightcolor = vec4(vec3(0.0), 1.0);
#ifdef LUMPLIGHT
    else if (nightVision > 0)
        lightcolor = vec4(vec3(length(lights.xy) * 5.0), 1.0);
#endif
    else
        lightcolor = texture2D(lightmap, n2lm(lights.xy));

    gl_FragData[0] = texture2D(texture, texpos.xy) * color;
    gl_FragData[1] = normal;
    gl_FragData[2] = lightcolor;
    gl_FragData[3] = normal;
    gl_FragData[4] = vec4(1.0, 0.0, 0.0, 1.0);

    // if(fogMode == 9729)
    //     gl_FragData[0].rgb = mix(gl_Fog.color.rgb, gl_FragData[0].rgb, clamp((gl_Fog.end - gl_FogFragCoord) / (gl_Fog.end - gl_Fog.start), 0.0, 1.0));
    // else if(fogMode == 2048)
    //     gl_FragData[0].rgb = mix(gl_Fog.color.rgb, gl_FragData[0].rgb, clamp(exp(-gl_FogFragCoord * gl_Fog.density), 0.0, 1.0));
}
/* DRAWBUFFERS:01257 */