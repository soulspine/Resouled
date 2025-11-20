varying vec4 Color0;
varying vec2 TexCoord0;
varying vec2 PosOut;

uniform sampler2D Texture0;

void main()
{
	vec2 Pos = PosOut;
	vec4 color = texture2D(Texture0, TexCoord0);
	
	color.r *= 0.5;
	
	gl_FragColor = color;
}
