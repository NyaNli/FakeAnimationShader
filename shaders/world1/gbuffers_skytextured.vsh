#version 430 compatibility

out vec4 color;
out vec4 texpos;

void main()
{
    vec4 viewpos = gl_ModelViewMatrix * gl_Vertex;
    gl_Position = gl_ProjectionMatrix * viewpos;
    gl_FogFragCoord = length(viewpos.xyz);
    color = gl_Color;
    texpos = gl_TextureMatrix[0] * gl_MultiTexCoord0;
}