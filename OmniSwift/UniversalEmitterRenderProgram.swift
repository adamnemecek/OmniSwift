//
//  UniversalEmitterRenderProgram.swift
//  Gravity
//
//  Created by Cooper Knaak on 2/20/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import GLKit

public class UniversalEmitterRenderProgram: NSObject {

    public var program:GLuint = 0
    public var vertexBuffer:GLuint = 0
    public var u_Projection:GLint = 0
    public var u_TextureInfo:GLint = 0
    public var a_Position:GLint = 0
    public var a_Color:GLint = 0
    public var a_Size:GLint = 0
    public var a_TextureAnchor:GLint = 0
    
    public let defaultTextureName:GLuint
    public var currentTextureName:GLuint = 0
    
    override init() {
        
        self.program = ShaderHelper.programForString("Universal Particle Shader")!
        
        self.u_Projection = glGetUniformLocation(self.program, "u_Projection")
        self.u_TextureInfo = glGetUniformLocation(self.program, "u_TextureInfo")
        self.a_Position = glGetAttribLocation(self.program, "a_Position")
        self.a_Color = glGetAttribLocation(self.program, "a_Color")
        self.a_Size = glGetAttribLocation(self.program, "a_Size")
        self.a_TextureAnchor = glGetAttribLocation(self.program, "a_TextureAnchor")
        
        self.defaultTextureName = CCTextureOrganizer.textureForString("White Tile")!.name
        self.currentTextureName = self.defaultTextureName
        
        super.init()
        
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vertexBuffer)
        
    }//initialize
    
    public func bind() {
        
        func bridgeAttribute(location:GLint, size:Int, stride:Int, position:Int) {
            
            glEnableVertexAttribArray(GLuint(location))
            
            let pointer = UnsafePointer<Void>(bitPattern: sizeof(GLfloat) * position)
            glVertexAttribPointer(GLuint(location), GLint(size), GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(stride), pointer)
            
        }//bridge attribute
        
        let proj = GLSUniversalRenderer.sharedInstance.projection
        let uRend = GLSUniversalEmitterRenderer.sharedInstance
        let stride = sizeof(PEVertex)
        
        glUseProgram(self.program)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), stride * uRend.vertices.count, uRend.vertices, GLenum(GL_DYNAMIC_DRAW))
        
        glBindTexture(GLenum(GL_TEXTURE_2D), self.currentTextureName)
        glUniform1i(self.u_TextureInfo, 0)
        
        glUniformMatrix4fv(self.u_Projection, 1, 0, proj.values)
        
        bridgeAttribute(self.a_Position, size: 2, stride: stride, position: 0)
        bridgeAttribute(self.a_Color, size: 3, stride: stride, position: 2)
        bridgeAttribute(self.a_Size, size: 1, stride: stride, position: 5)
        bridgeAttribute(self.a_TextureAnchor, size: 4, stride: stride, position: 6)
        
        glBlendColor(0, 0, 0, 1.0);
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_CONSTANT_ALPHA));
    }//bind
    
    public func render() {
        
        let uRend = GLSUniversalEmitterRenderer.sharedInstance

        for reference in uRend.references {
            
            glBindFramebuffer(GLenum(GL_FRAMEBUFFER), reference.framebuffer)
            reference.emitter?.buffer.bindClearColor()
            
            if (reference.emitter === nil || reference.vertexCount <= 0) {
                continue
            }
            
            let curTex = reference.textureName
            if (curTex != self.currentTextureName) {
                self.currentTextureName = curTex
                glBindTexture(GLenum(GL_TEXTURE_2D), curTex)
            }
            
            
            glDrawArrays(GLenum(GL_POINTS), GLint(reference.startIndex), GLsizei(reference.vertexCount))
        }
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glDisableVertexAttribArray(GLuint(self.a_Position))
        glDisableVertexAttribArray(GLuint(self.a_Color))
        glDisableVertexAttribArray(GLuint(self.a_Size))
        glDisableVertexAttribArray(GLuint(self.a_TextureAnchor))
    }//render
    
}
