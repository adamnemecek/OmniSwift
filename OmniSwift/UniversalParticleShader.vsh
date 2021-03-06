
uniform mat4 u_Projection;

attribute vec2 a_Position;
attribute float a_Size;
attribute vec3 a_Color;
attribute vec4 a_TextureAnchor;

varying vec3 v_Color;
varying vec4 v_TextureAnchor;

void main(void) {
    
    vec4 pos = u_Projection * vec4(a_Position, 0.0, 1.0);
    gl_Position = pos;
    
    gl_PointSize = a_Size;
    
    v_Color = a_Color;
    v_TextureAnchor = a_TextureAnchor;
}