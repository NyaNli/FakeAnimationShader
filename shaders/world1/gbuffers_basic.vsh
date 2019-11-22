#version 430 compatibility

out vec4 color;
out vec4 normal;

void main()
{
    vec4 viewpos = gl_ModelViewMatrix * gl_Vertex;
    gl_Position = gl_ProjectionMatrix * viewpos;
    gl_FogFragCoord = length(viewpos.xyz);
    color = gl_Color;
    normal = vec4(normalize(gl_NormalMatrix * gl_Normal), 1.0);
}