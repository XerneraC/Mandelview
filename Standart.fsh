#version 330 core


#define MAXITERATIONS 200

layout(location = 0) out vec4 color;

uniform vec4 u_pos;
uniform float u_scale;
uniform int u_mode;

varying vec2 quadCoord;


struct mbResult {
	float bailoutIts;
	bool isInside;
};


vec2 complexSquare( vec2 complex ) {
	// (a + b)^2 = (a^2 + 2ab + b^2)
	//              real  imag  real
	// result: (a^2-b^2,  2ab)
	float real = complex.x*complex.x - complex.y*complex.y;
	float imaginary = 2*complex.x*complex.y;
	return vec2(real, imaginary); 
}



mbResult Mandelbrot( vec4 coord ) {
	mbResult result;
	result.bailoutIts = 0.0;
	result.isInside = false;

	// Spliting the 4 dimensional coordinate
	vec2 c = coord.xy;
	vec2 z = coord.zw;

	// Iterating (doing the function)
	for (int i = 0; i < MAXITERATIONS; i++) {
		z = complexSquare(z) + c;
		if (length(z) > 10000.0) {
			result.bailoutIts = float(i)/float(MAXITERATIONS-1);
			break;
		}
	}
	if (length(z) < 10000.0) {
		result.isInside = true;
	}

	return result;
}


vec3 getHue( float hue ) {
	vec3 red     = vec3(1.0, 0.0, 0.0);
	vec3 yellow  = vec3(1.0, 1.0, 0.0);
	vec3 green   = vec3(0.0, 1.0, 0.0);
	vec3 cyan    = vec3(0.0, 1.0, 1.0);
	vec3 blue    = vec3(0.0, 0.0, 1.0);

	int transition = int(hue*4.0);
	float t = mod(hue*4.0, 1.0);

	vec3 fromColor = vec3(0.0);
	vec3 toColor   = vec3(0.0);

	switch (transition) {
		case 0:
			fromColor = red;
			toColor = yellow;
			break;

		case 1:
			fromColor = yellow;
			toColor = green;
			break;

		case 2:
			fromColor = green;
			toColor = cyan;
			break;

		case 3:
			fromColor = cyan;
			toColor = blue;
			break;

		default:
			break;
	}
	return t*toColor + (1.0-t)*fromColor;
}



void main() {
	//color = vec4(quadCoord, 0.0, 1.0);

	vec4 coord = vec4(0.0);

	switch (u_mode) {
		case 0:
			coord.x = (quadCoord.x - 0.5)*u_scale;
			coord.y = (quadCoord.y - 0.5)*u_scale;
			break;

		case 1:
			coord.z = (quadCoord.x - 0.5)*u_scale;
			coord.w = (quadCoord.y - 0.5)*u_scale;
			break;

		case 2:
			coord.x = (quadCoord.x - 0.5)*u_scale;
			coord.z = (quadCoord.y - 0.5)*u_scale;
			break;

		case 3:
			coord.y = (quadCoord.x - 0.5)*u_scale;
			coord.w = (quadCoord.y - 0.5)*u_scale;
			break;
	}

	/*
	vec2 c = ((quadCoord - vec2(0.5, 0.5))*u_scale - u_pos.xy);
	//vec2 c = u_pos.xy;
	//vec2 z = ((quadCoord - vec2(0.5, 0.5))*u_scale - u_pos.zw);
	vec2 z = u_pos.zw;*/

	mbResult result = Mandelbrot( coord + u_pos );
	float fac = pow(result.bailoutIts, 0.5);
	color = vec4(getHue(1.0-fac)*fac, 1.0);
	//color = vec4(c, 0.0, 1.0);
	
}