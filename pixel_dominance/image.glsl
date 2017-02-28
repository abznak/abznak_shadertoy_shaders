/* the interesting code is all in Buf A */

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
	vec2 uv;
    
    //copy Buf A to the screen
    uv = fragCoord.xy / iResolution.xy;
    
    // this removes the 'down-left' tendency that the Buf A algorithm produces
    //uv = fract((fragCoord.xy-vec2(float(iFrame))) / iResolution.xy);
    
	fragColor = texture(iChannel0, uv);
}
