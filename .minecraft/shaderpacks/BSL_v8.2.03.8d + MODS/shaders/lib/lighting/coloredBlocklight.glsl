vec3 ApplyMultiColoredBlocklight(vec3 blocklightCol, vec2 screenPos) {
	vec3 coloredLight = texture2D(colortex9, screenPos.xy).rgb;
		
	vec3 coloredLightNormalized = normalize(coloredLight + 0.00001);
	coloredLightNormalized *= GetLuminance(blocklightCol) / GetLuminance(coloredLightNormalized);
	float coloredLightMix = min((coloredLight.r + coloredLight.g + coloredLight.b) * 256.0, 1.0);

	return mix(blocklightCol, coloredLightNormalized, coloredLightMix);
}