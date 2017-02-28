/* the interesting code is all in Buf A */

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //copy Buf A to the screen
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = texture(iChannel0, uv);
}
