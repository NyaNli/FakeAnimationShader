#version 430 compatibility

uniform int fogMode;
uniform sampler2D texture;

in vec4 color;
in vec4 texpos;
in vec4 normal;

void main()
{
    gl_FragData[0] = texture2D(texture, texpos.xy) * color;
    gl_FragData[1] = normal;
    gl_FragData[2] = vec4(1.0);
    gl_FragData[3] = normal;
    // if(fogMode == 9729)
    //     gl_FragData[0].rgb = mix(gl_Fog.color.rgb, gl_FragData[0].rgb, clamp((gl_Fog.end - gl_FogFragCoord) / (gl_Fog.end - gl_Fog.start), 0.0, 1.0));
    // else if(fogMode == 2048)
    //     gl_FragData[0].rgb = mix(gl_Fog.color.rgb, gl_FragData[0].rgb, clamp(exp(-gl_FogFragCoord * gl_Fog.density), 0.0, 1.0));
}
/* DRAWBUFFERS:0125 */