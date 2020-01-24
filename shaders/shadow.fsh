#version 430 compatibility

uniform sampler2D texture;

uniform mat4 shadowProjectionInverse;
uniform mat4 shadowProjection;

in vec4 color;
in vec4 texpos;
in vec4 originpos;
in vec4 projpos;
in vec3 camnormal;

#define REALTIMESHADOW
#define SHADOWMAPSIZE 4096 // [2048 4096 8192 16384]

#ifndef REALTIMESHADOW
const int shadowMapResolution = 1;
#elif SHADOWMAPSIZE==2048
const int shadowMapResolution = 2048;
#elif SHADOWMAPSIZE==4096
const int shadowMapResolution = 4096;
#elif SHADOWMAPSIZE==8192
const int shadowMapResolution = 8192;
#elif SHADOWMAPSIZE==16384
const int shadowMapResolution = 16384;
#endif

#define SUNROTATE 3 // [1 2 3 4 5 6 7 8 9]
#if SUNROTATE==1
const float sunPathRotation = -60.0f;
#elif SUNROTATE==2
const float sunPathRotation = -45.0f;
#elif SUNROTATE==3
const float sunPathRotation = -30.0f;
#elif SUNROTATE==4
const float sunPathRotation = -15.0f;
#elif SUNROTATE==5
const float sunPathRotation = 0.0f;
#elif SUNROTATE==6
const float sunPathRotation = 15.0f;
#elif SUNROTATE==7
const float sunPathRotation = 30.0f;
#elif SUNROTATE==8
const float sunPathRotation = 45.0f;
#elif SUNROTATE==9
const float sunPathRotation = 60.0f;
#endif


const float shadowIntervalSize = 0.001f;

#define SHADOW_MAP_BIAS 0.9

void main()
{
// 反求原坐标
    float dist = length(projpos.xy);
    float originDist = (1.0 - SHADOW_MAP_BIAS) / (1.0 / dist - SHADOW_MAP_BIAS);
    float distortFactor = mix(1.0, originDist, SHADOW_MAP_BIAS);
    vec4 realProjPos = vec4(projpos.xy * distortFactor, projpos.zw);

// z深度修正
    vec4 originView = shadowProjectionInverse * originpos;
    originView /= originView.w;
    vec4 currentView = shadowProjectionInverse * realProjPos;
    currentView /= currentView.w;
    vec2 diff = currentView.xy - originView.xy;
    float diffz = diff.x / camnormal.z * -camnormal.x + diff.y / camnormal.z * -camnormal.y;
    if (isnan(diffz))
        diffz = 0.0;
    currentView.z += diffz;
    vec4 rightProj = shadowProjection * currentView;

    gl_FragColor = texture2D(texture, texpos.xy) * color;
    gl_FragDepth = rightProj.z * 0.5 + 0.5;
}