shader_type canvas_item;
uniform sampler2D noiseTexture;
uniform bool active;

void fragment()
{
	vec4 originalTexture = texture(TEXTURE, UV);
	if(active){
		vec4 dissolveNoise1 = texture(noiseTexture, UV + vec2(TIME * .1, -TIME * .1));
		vec4 dissolveNoise2 = texture(noiseTexture, UV + vec2(TIME * .3, -TIME * .3));
		vec4 dissolveNoise3 = texture(noiseTexture, UV + vec2(TIME * .5, -TIME * .5));
		COLOR.r = originalTexture.r * .2 + dissolveNoise1.r * .8;
		COLOR.g = originalTexture.g * .2 + dissolveNoise2.g * .8;
		COLOR.b = originalTexture.b * .2 + dissolveNoise3.b * .8;
		COLOR.a = originalTexture.a;
	} else {
		COLOR = originalTexture;
	}
}