attribute vec3 Position;
attribute vec4 Color;
attribute vec2 TexCoord;
attribute vec4 RenderData;
attribute float Scale;
varying vec4 Color0;
varying vec2 TexCoord0;
varying vec4 RenderDataOut;
varying float ScaleOut;
uniform mat4 Transform;
void main(void)
{
    RenderDataOut = RenderData;
    ScaleOut = Scale;
    Color0 = Color;
    TexCoord0 = TexCoord;
    gl_Position = Transform * vec4(Position.xyz, 1.0);
}