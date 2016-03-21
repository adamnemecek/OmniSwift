
precision mediump float;

uniform highp sampler2D u_GradientInfo;
uniform highp sampler2D u_TextureInfo;

varying vec2 v_RadialTexture;
varying vec2 v_Texture;

void main(void) {
    
    float angle = atan(v_RadialTexture.y, v_RadialTexture.x);
    float offset = angle / (2.0 * 3.14159265);
    vec4 color = texture2D(u_GradientInfo, vec2(offset, 0.0));
    vec4 shadeColor = texture2D(u_TextureInfo, v_Texture);
    
    gl_FragColor = color * shadeColor;
}//main
