#version 430 compatibility

out vec4 pos;

void main()
{
    pos = gl_MultiTexCoord0;
    gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
}