#version 430 compatibility

uniform int fogMode;
uniform sampler2D texture;

in vec4 color;
in vec4 texpos;
in vec4 normal;

#define REDONLY 0 // [0 2 4 6 8 10]
#define LUMPLIGHT_N

void main()
{
    vec4 color0 = color * vec4(1.0, REDONLY * 0.1, REDONLY * 0.1, 1.0);
    float light = texture2D(texture, texpos.xy).r;
#ifdef LUMPLIGHT_N
    if (light > 0.5)
    {
        light = 1.5;
    }
    else
    {
        light = 0.0;
    }
#endif

    gl_FragData[0] = vec4(color0.rgb * light, 1.0);

    // if(fogMode == 9729)
    //     gl_FragData[0].rgb = mix(gl_Fog.color.rgb, gl_FragData[0].rgb, clamp((gl_Fog.end - gl_FogFragCoord) / (gl_Fog.end - gl_Fog.start), 0.0, 1.0));
    // else if(fogMode == 2048)
    //     gl_FragData[0].rgb = mix(gl_Fog.color.rgb, gl_FragData[0].rgb, clamp(exp(-gl_FogFragCoord * gl_Fog.density), 0.0, 1.0));
}
/* DRAWBUFFERS:2 */