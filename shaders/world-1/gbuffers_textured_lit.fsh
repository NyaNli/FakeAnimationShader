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

#define LUMPLIGHT_N
#define REDONLY

void main()
{
    float light;
    light = pow(lm2n(lmpos.x), 1.4);

#ifdef LUMPLIGHT_N
    // 方块 0.6 0.3 0.1 
    if (light > 0.6)
        light = 1.0;
    else if (light > 0.3)
        light = 0.6;
    else if (light > 0.1)
        light = 0.3;
    else
        light = 0;
#endif

#ifdef REDONLY
    vec3 maincolor = vec3(1.0, 0.0, 0.0);
#else
    vec3 maincolor = vec3(1.0, 1.0, 1.0);
#endif

    vec4 lightcolor = vec4(texture2D(lightmap, n2lm(vec2(light, 0))).rgb * maincolor, 1.0);

    gl_FragData[0] = texture2D(texture, texpos.xy) * color;
    gl_FragData[1] = normal;
    gl_FragData[2] = lightcolor;
    gl_FragData[3] = normal;

    // if(fogMode == 9729)
    //     gl_FragData[0].rgb = mix(vec3(1.0, 0.0, 0.0), gl_FragData[0].rgb, clamp((gl_Fog.end - gl_FogFragCoord) / (gl_Fog.end - gl_Fog.start), 0.0, 1.0));
    // else if(fogMode == 2048)
    //     gl_FragData[0].rgb = mix(vec3(1.0, 0.0, 0.0), gl_FragData[0].rgb, clamp(exp(-gl_FogFragCoord * gl_Fog.density), 0.0, 1.0));
}
/* DRAWBUFFERS:0125 */