#define LMRATIO 0.93359375



float lm2n(float lmpos)
{
    return clamp((lmpos - 0.5) / LMRATIO + 0.5, 0, 1);
}

float n2lm(float pos)
{
    return clamp((pos - 0.5) * LMRATIO + 0.5, 0.031372549, 0.968627451);
}

vec2 n2lm(vec2 pos)
{
    vec2 lm;
    lm.x = clamp((pos.x - 0.5) * LMRATIO + 0.5, 0.031372549, 0.968627451);
    lm.y = clamp((pos.y - 0.5) * LMRATIO + 0.5, 0.031372549, 0.968627451);
    return lm;
}

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

uniform float near;
uniform float far;

float linearizeDepth(float depth)
{
    return (2.0 * near) / (far + near - depth * (far - near));
}

uniform int worldTime;

float sunHeight()
{
    float height = 0.0;
    if (worldTime > 13000 && worldTime < 23000)
    {
        height = -sqrt(1.0-pow((worldTime-18000)/5000.0, 2.0));
    }
    else
    {
        if (worldTime >= 23000)
            height = sqrt(1.0-pow((worldTime-30000)/7000.0, 2.0));
        else
            height = sqrt(1.0-pow((worldTime-6000)/7000.0, 2.0));
    }
    return height;
}

float shadowlightHeight()
{
    float height = 0.0;
    if (worldTime > 13000 && worldTime < 23000)
    {
        height = sqrt(1.0-pow((worldTime-18000)/5000.0, 2.0));
    }
    else
    {
        if (worldTime >= 23000)
            height = sqrt(1.0-pow((worldTime-30000)/7000.0, 2.0));
        else
            height = sqrt(1.0-pow((worldTime-6000)/7000.0, 2.0));
    }
    return height;
}