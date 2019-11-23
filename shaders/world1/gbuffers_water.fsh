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

void main()
{
    float light;
    light = pow(lm2n(lmpos.x), 1.4);

#ifdef LUMPLIGHT_E
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

    vec4 lightcolor = texture2D(lightmap, vec2(light, n2lm(0)));

    gl_FragData[0] = normal;
    gl_FragData[1] = texture2D(texture, texpos.xy) * color;
    gl_FragData[2] = lightcolor;
    // if(fogMode == 9729)
    //     gl_FragData[0].rgb = mix(gl_Fog.color.rgb, gl_FragData[0].rgb, clamp((gl_Fog.end - gl_FogFragCoord) / (gl_Fog.end - gl_Fog.start), 0.0, 1.0));
    // else if(fogMode == 2048)
    //     gl_FragData[0].rgb = mix(gl_Fog.color.rgb, gl_FragData[0].rgb, clamp(exp(-gl_FogFragCoord * gl_Fog.density), 0.0, 1.0));
}
/* DRAWBUFFERS:134 */