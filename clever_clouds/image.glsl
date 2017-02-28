/* the interesting code is all in Buf A */
// old color, reliative to current pixel
vec4 bufColor(in vec2 fragCoord, in vec2 dxy) {    
    return texture(iChannel0,  fract((fragCoord.xy + dxy) / iResolution.xy));
}

// grab the value for a nearby pixel
#define BC(dx,dy) (bufColor(fragCoord, vec2(dx, dy)))

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //apply a slight blur to the image in buffer A 
	fragColor = (BC(0,0)*4.0 + BC(-1, 0) + BC(1,0)+BC(0, -1) + BC(0, 1))/8.0;
}

