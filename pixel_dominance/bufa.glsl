/* 
 * random number, varying by time.  Seed should be a prime.
 *
 * Just reads the data from iChannel1 in sequence if seed is 1.  It's going to repeat every
 * 65535 frames, but the state should be different enough that it doesn't matter.
 * I'd like to set the seeds up so differently seeded calls repeat at different rates but I'm
 * not sure I've done that yet.  It works, anyway.
 */
vec4 rnd_tv(int seed) {                
    const float res_x = 256.;
    const float res_y = 256.;    
    int j = iFrame * seed;
    float x = mod(float(j), res_x);
    float y = mod((float(j) / res_x), res_y);
	return texture(iChannel1, vec2(x/res_x, y/res_y));
}


// old color, reliative to current pixel
vec4 oldColor(in vec2 fragCoord, in vec2 dxy) {    
    return texture(iChannel0,  fract((fragCoord.xy + dxy) / iResolution.xy));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	const vec4 black = vec4(0., 0., 0., 1.);
    const vec4 white = vec4(1.);
    const vec4 red = vec4(1., 0., 0., 1.);
    // current coordinates, normalised 0..1
    vec2 uv = fragCoord.xy / iResolution.xy;              
    

    //////////////////////    
    // sometimes adds a small coloured square at a random location
    //////////////////////    
    if (true) {        
        vec2 rpt = rnd_tv(1).xy;
        
        // I don't think iChannel1 is uniform.  Zooms in a bit to a more uniform area.
        // some of the resulting points are out of bounds now.  That's fine.
        rpt *= 2.;
        rpt -= .5;
                         
        const float square_size = 2.;
        if (all(lessThan(abs(uv - rpt), vec2(square_size)/iResolution.xy))) {                   
            fragColor = rnd_tv(13);
            fragColor.a = 1.;
            return;
        } 
    }
    
    
    
    
    //////////////////////
 	// pick the dominant pixel from neighbouring pixels (and this pixel).   
 	//////////////////////
    
    
    // get old colour from buffer
    #define oc(x,y) (oldColor(fragCoord, vec2(x,y)))    
    
    vec4 oldcol = oc(0., 0.);          
    vec4 col = oldcol;
    
	#define notblack(x) (any(greaterThan(x, black)))
    #define isblack(x) (!notblack(x))
    
    
    //iterate over nearby pixels
    for (float dx = -1.0; dx < 2.0; dx++) {
        for (float dy = -1.0; dy < 2.0; dy++) {
            vec4 acol = oc(dx, dy);

            float q = dot(acol, acol);
            float w = dot(col, col);

            
            // if the colour being replaced is background (black), always replace it with
            // anything that isn't black.
            if (isblack(col)&&notblack(acol)) {
                col = acol;
            }

            
            if (notblack(acol)) {
                float diff = (q - w)/1.5; //    1.5 = 3/2 to rescale -3..3 to -1..1                   

                // different cutoffs are fun, as are varying cutoffs.
                float cutoff;
                cutoff = 0.5;
                //cutoff = sin(float(iFrame/100)) * .5;
                
                // designed so ever pixel beats half of the colour space, see https://www.shadertoy.com/view/Mtt3Wn
                if ((diff < 0. && diff > -cutoff) || (diff > cutoff)) {
                    col = acol;  //note - picked deterministically if multiple pixels qualify
                }
            }
        }
    }        
   
    fragColor = col;    
}









