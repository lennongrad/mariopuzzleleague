shader_type canvas_item;
uniform sampler2D noiseTexture;
uniform float dissolveAmount : hint_range(0, 1);
uniform float edgeSize = 0.1;
uniform float edgeThickness = .1;
uniform vec4 edgeColor : hint_color;
uniform float noiseTiling = 1;
void fragment()
{
	vec4 originalTexture = texture(TEXTURE, UV);
	vec4 dissolveNoise = texture(noiseTexture, UV * noiseTiling);
	float remappedDissolve = dissolveAmount * (1.01  + edgeThickness) - edgeThickness;
	vec4 step1 = step(remappedDissolve, dissolveNoise);
	vec4 step2 = step(remappedDissolve + edgeThickness, dissolveNoise);
	vec4 edge = step1 - step2;
	edge.a = originalTexture.a;
	vec4 edgeColorArea = edge * edgeColor;
	originalTexture.a *= step1.r;
	vec4 combinedColor = mix(originalTexture, edgeColorArea, edge.r);
	COLOR = combinedColor;
}