https://www.shadertoy.com/view/4td3Wn

tags: 2d, face, buffer, rorschach

This shader combines the previous frame with a frame from a video to give a Rorschach ink blot like effect.

The model's dark makeup mean the her eyes tend to appear in the resulting white blob, which makes faces appear.


bufa:
	iChannel0: bufa
	iChannel1: black and white noise
	iChannel2: video -  http://www.youtube.com/watch?v=I02Ss2VUM3U

image:
	iChannel0: bufa
