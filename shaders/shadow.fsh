#version 430 compatibility

uniform sampler2D texture;

in vec4 color;
in vec4 texpos;

#define REALTIMESHADOW
#define SHADOWMAPSIZE 4096 // [512 1024 2048 4096 8192 16384]

#ifndef REALTIMESHADOW
const int shadowMapResolution = 1;
#elif SHADOWMAPSIZE==512
const int shadowMapResolution = 512;
#elif SHADOWMAPSIZE==1024
const int shadowMapResolution = 1024;
#elif SHADOWMAPSIZE==2048
const int shadowMapResolution = 2048;
#elif SHADOWMAPSIZE==4096
const int shadowMapResolution = 4096;
#elif SHADOWMAPSIZE==8192
const int shadowMapResolution = 8192;
#elif SHADOWMAPSIZE==16384
const int shadowMapResolution = 16384;
#endif

const float sunPathRotation = -30.0f;

void main()
{
    gl_FragData[0] = texture2D(texture, texpos.xy) * color;
}
/* DRAWBUFFERS:0 */