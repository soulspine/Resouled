varying vec4 Color0;
varying vec2 TexCoord0;

uniform sampler2D Texture0;

void main()
{
	vec4 color = Color0 * texture2D(Texture0, TexCoord0);

	color.r += 0.85 * color.a * color.r;
	color.r *= color.r * 1,25;
	color.g *= 0.75;
	color.b *= 0.75;
	
	gl_FragColor = color;
}
