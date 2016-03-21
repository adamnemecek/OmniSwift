uniform mat4 u_Projection;
uniform mat4 u_ModelMatrix;

attribute vec2 a_Position;
attribute vec2 a_Texture;
attribute float a_Index;
varying vec2 v_Position;
varying float v_Index;

void main(void) {
    
    vec4 pos = u_Projection * u_ModelMatrix * vec4(a_Position, 0.0, 1.0);
    gl_Position = pos;
    
    v_Position = a_Position;
    v_Index = a_Index;
    vec2 vTexture_PLACEHOLDER = a_Texture;
}//main