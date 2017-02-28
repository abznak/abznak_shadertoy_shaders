//----------------------------------------------------------------------------------------
// based on https://www.shadertoy.com/view/4djSRW
///  3 out, 3 in...
#define HASHSCALE3 vec3(.1031, .1030, .0973)
//#define HASHSCALE3 vec3(443.897, 441.423, 437.195)
#define MAX_ITERATIONS 30
#define MIN_ITERATIONS 4
vec3 hash33(vec3 p3, int i)
{
	p3 = fract(p3 * HASHSCALE3);
    p3 += dot(p3, p3.yxz+19.19+float(i)/20.);
    return fract((p3.xxy + p3.yxx)*p3.zyx);

}
vec3 rnd3(vec2 position, int i)
{

    i += MIN_ITERATIONS;
    vec3 a = vec3(0.0), b = a;
    //NOTE - not handling i > MAX_ITERATIONS
    //will just start scaling down random numbers
    for (int t = 0; t < MAX_ITERATIONS; t++)  // max_iterations thing is due to GLSL limitations?
    {
        if (t == i) {
            break;
        }
        float v = float(t+1)*.132;
        vec3 pos = vec3(position, iGlobalTime*.3) + iGlobalTime * 500. + 50.0;
        a += hash33(pos, i);  //just changing the numer of iterations doesn't work
    }
    vec3 col = a / float(i);
    return col;
}
//----------------------------------------------------------------------------------------


// old color, reliative to current pixel
vec4 oldColor(in vec2 fragCoord, in vec2 dxy) {    
    return texture(iChannel0,  fract((fragCoord.xy + dxy) / iResolution.xy));
}

//get the next random number for the current pixel
#define RND() (rnd3(fragCoord, rndi++))

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    int rndi = 0;
	const vec4 black = vec4(0., 0., 0., 1.);
    const vec4 white = vec4(1.);
    const vec4 red = vec4(1., 0., 0., 1.);
    // current coordinates, normalised 0..1
    vec2 uv = fragCoord.xy / iResolution.xy;              
    
    vec3 rnd;

    //////////////////////    
    // sometimes adds a small coloured square at a random location
    //////////////////////    
    rnd = RND();
    if (true) {                   
        if (true || iGlobalTime < 2.0) {
            if (rnd.x < .00001) {
                fragColor = vec4(RND(), 1.);  
                return;
            }
        }
    }
    
    
    
    
    //////////////////////
 	// shuffle pixels around in a way that avoids vertical edges
 	//////////////////////
    
    
    // get old colour from buffer
    #define oc(x,y) (oldColor(fragCoord, vec2(x,y)))    
    
    vec4 oldcol = oc(0., 0.);          
    vec4 col = oldcol;
    //fragColor = col; return;
	#define notblack(x) (any(greaterThan(x, black)))
    #define isblack(x) (!notblack(x))
    

    
    float dir = -1.;
    if (rnd.y < .5) {
        dir = 1.;
    }
    
    if (isblack(col)) {        
        // if current color is black, pick a nearby color
        col = oc(dir, 0.);
    } else {
        // pick a nearby color IF it does NOT create a vertical edge
        vec4 potcol = oc(0, dir);
        if (potcol == oc(-1., dir) && potcol == oc(1., dir)) {
            col = potcol;
        }
    }
    

    //////////////////////
 	// perhaps tweak the result
 	//////////////////////    

    float change_chance = pow(iMouse.x/iResolution.x, 2.)/9.;
    if (change_chance == 0.) {
        //it can be below 0.05, but not exactly 0
        // so we still have a change_chance when the user hasn't clicked.
        change_chance = 0.05;
    }
      
    
    //fragColor = col; return;

    //////////////////////
 	// pick the dominant pixel from neighbouring pixels (and this pixel).
    // each colour dominates half the other colors
 	//////////////////////    

    //iterate over nearby pixels
    for (float dx = -1.0; dx < 2.0; dx++) {
        for (float dy = -1.0; dy < 2.0; dy++) {
            vec4 acol = oc(dx, dy);

            float q = dot(acol, acol);
            float w = dot(col, col);

            //NB - the distribution of the dot-product of random colours is not uniform
            //TODO: bigger range of values for change_chance
            //TODO: use col.y to determine for loops' directions
            //TODO: use col.z (or acol.z) to modify change_chance
            q=acol.x;
            w=col.x; 
            //w=col.y; //+ col.y/10.;
            //w=acol.y+col.x;
            //w=acol.y*col.x;
                
            
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
                    if (RND().x < change_chance) {
                    	col = acol;  //note - picked deterministically if multiple pixels qualify
                    }
                }
            }
        }
    }        
   
    fragColor = col;    
}









