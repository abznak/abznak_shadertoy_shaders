/* 
 * This shader combines the previous frame with a frame for a video to give a Rorschach 
 * ink blot like effect.
 * 
 * Specifically, it sums the 9 adjacent pixels with 9 copies of the pixel from the video.  
 * If the x channel of the result is more than 9 (i.e. the average colour is more than half) then
 * the resulting pixel is white.  Otherwise it is black.
 */

// old color, reliative to current pixel
vec4 oldColor(in vec2 fragCoord, in vec2 dxy) {    
    return texture(iChannel0,  (fragCoord.xy + dxy) / iResolution.xy);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {

    // current coordinates, normalised 0..1
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    // just the use static texture for the first second.
    const float start_time = 1.0;
    if (iGlobalTime < start_time) {
        fragColor = texture(iChannel1, uv);
        return;
    }
 
    // sum the adjacent pixels (including the current pixel)
    vec4 tot = vec4(0.0, 0.0, 0.0, 0.0);
    for (float dx = -1.0; dx < 2.0; dx++) {
        for (float dy = -1.0; dy < 2.0; dy++) {
            tot += oldColor(fragCoord, vec2(dx, dy));                       
        }
    }
    
    // add in a pixel from the video, with the same total weight as the existing samples
    tot += texture(iChannel2, uv) * vec4(9.0, 9.0, 9.0, 9.0);
    
	// output white if x value is more than half of max
    // I've done the calculations so far with all the channels, even though I only use x because
    // I'm planning on doing something more interesting with the other channel's data in the future.
    if (tot.x > 9.0) {
        fragColor = vec4(1.0, 1.0, 1.0, 1.0);
    } else {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }
    
}
