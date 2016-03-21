
precision mediump float;

uniform highp sampler2D u_TextureInfo1;
uniform highp sampler2D u_TextureInfo2;
/*uniform float u_Alpha;
uniform vec3 u_TintColor;
uniform vec3 u_TintIntensity;
uniform vec3 u_ShadeColor;*/

varying vec2 v_Texture1;
varying vec2 v_Texture2;

void main(void) {
    
    vec4 texColor = texture2D(u_TextureInfo1, v_Texture1) * texture2D(u_TextureInfo2, v_Texture2);
    
    /*texColor.rgb *= u_ShadeColor;
    texColor = vec4(mix(texColor.rgb, u_TintColor, u_TintIntensity), texColor.a * u_Alpha);*/
    
    gl_FragColor = texColor;
    
}//main