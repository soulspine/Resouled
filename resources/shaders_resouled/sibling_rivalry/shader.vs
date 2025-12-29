attribute vec3 Position;
attribute vec4 Color;
attribute vec2 TexCoord;

varying vec4 Color0;
varying vec2 TexCoord0;

uniform mat4 Transform;

void main()
{
	gl_Position = Transform * vec4(Position.xyz, 1.0);
	Color0 = Color;
	TexCoord0 = TexCoord;
}
