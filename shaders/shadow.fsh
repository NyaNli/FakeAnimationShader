#version 430 compatibility

uniform sampler2D texture;

in vec4 color;
in vec4 texpos;

const int shadowMapResolution = 4096;
const float sunPathRotation = -30.0f;

void main()
{
    gl_FragData[0] = texture2D(texture, texpos.xy) * color;
}
/* DRAWBUFFERS:0 */