#version 430 compatibility

out vec4 color;
out vec4 texpos;
out vec4 lmpos; // x 方块亮度, y 天空亮度
out vec4 normal;

void main()
{
    vec4 viewpos = gl_ModelViewMatrix * gl_Vertex;
    gl_Position = gl_ProjectionMatrix * viewpos;
    gl_FogFragCoord = length(viewpos.xyz);
    color = gl_Color;
    texpos = gl_TextureMatrix[0] * gl_MultiTexCoord0;
    lmpos = gl_TextureMatrix[1] * gl_MultiTexCoord1;
    normal = vec4(normalize(gl_NormalMatrix * gl_Normal), 1.0);
}