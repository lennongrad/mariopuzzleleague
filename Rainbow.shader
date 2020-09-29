shader_type canvas_item;
uniform sampler2D noiseTexture;
uniform bool active;

void fragment()
{
	vec4 originalTexture = texture(TEXTURE, UV);
	if(active){
		vec4 dissolveNoise1 = texture(noiseTexture, UV + vec2(TIME * .1, -TIME * .1));
		vec4 dissolveNoise2 = texture(noiseTexture, UV + vec2(TIME * .2, -TIME * .2));
		vec4 dissolveNoise3 = texture(noiseTexture, UV + vec2(TIME * .3, -TIME * .3));
		COLOR.r = originalTexture.r * .5 + dissolveNoise1.r * .7;
		COLOR.g = originalTexture.g * .5 + dissolveNoise2.g * .7;
		COLOR.b = originalTexture.b * .5 + dissolveNoise3.b * .7;
		COLOR.a = originalTexture.a;
	} else {
		COLOR = originalTexture;
	}
}