shader_type canvas_item;

uniform vec4 glow_color = vec4(1.0, 0.9, 0.6, 1.0);
uniform float glow_strength = 2.0; // lower default

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Keep base texture as-is
    COLOR = tex;

    // Only add glow on brighter pixels
    float brightness = dot(tex.rgb, vec3(0.4, 0.7, 0.1)); // perceived brightness
    float glow = smoothstep(0.6, 1.0, brightness); // apply only to bright parts

    COLOR.rgb += glow_color.rgb * glow * glow_strength;
}
