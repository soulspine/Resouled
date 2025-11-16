varying lowp vec4 Color0;
varying mediump vec2 TexCoord0;
varying lowp vec4 RenderDataOut;
varying lowp float ScaleOut;
uniform sampler2D Texture0;
void main(void)
{
    vec4 Color = Color0 * texture2D(Texture0, TexCoord0);
                
    Color.r *= 0.25 + Color.r;
    Color.g *= 0.3 + Color.g;
    Color.b *= 0.3 + Color.b;
    Color.r += 0.22;
    Color.g += 0.215;
    Color.b += 0.215;

    float similarityTo1stColor = abs(-Color.r -Color.g -Color.b);
    float similarityTo2ndColor = abs(0.674 - Color.r + 0.549 - Color.g + 0.549 - Color.b);
    float similarityTo3rdColor = abs(0.894 - Color.r + 0.871 - Color.g + 0.839 - Color.b);

    if (similarityTo1stColor < similarityTo2ndColor) {
        Color.r = 0;
        Color.g = 0;
        Color.b = 0;
    } else if (similarityTo2ndColor < similarityTo1stColor && similarityTo2ndColor < similarityTo3rdColor) {
        Color.r = 0.674;
        Color.g = 0.549;
        Color.b = 0.549;
    } else {
        Color.r = 0.894;
        Color.g = 0.871;
        Color.b = 0.839;
    }

    gl_FragColor = Color;
}