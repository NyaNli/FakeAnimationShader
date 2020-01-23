#version 430 compatibility

#define SHADOW_MAP_BIAS 0.9

out vec4 color;
out vec4 texpos;
out vec4 originpos;
out vec4 projpos;
out vec3 camnormal;

void main()
{
    vec4 viewpos = gl_ModelViewMatrix * gl_Vertex;
    gl_Position = gl_ProjectionMatrix * viewpos;
    float dist = length(gl_Position.xy);
    float distortFactor = mix(1.0, dist, SHADOW_MAP_BIAS);
    originpos = gl_Position;
    gl_Position.xy /= distortFactor;
    projpos = gl_Position;

    color = gl_Color;
    texpos = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    camnormal = normalize(gl_NormalMatrix * gl_Normal);
}