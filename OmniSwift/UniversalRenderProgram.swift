//
//  UniversalRenderProgram.swift
//  Gravity
//
//  Created by Cooper Knaak on 2/18/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import UIKit


public class UniversalRenderProgram: NSObject {
   
    public var program:GLuint = 0
    public var vertexBuffer:GLuint = 0
    public var u_Projection:GLint = 0
    public var u_ModelMatrix:GLint = 0
//    var u_ViewPosition:GLint = 0
    public var u_TintColor:GLint = 0
    public var u_TintIntensity:GLint = 0
    public var u_ShadeColor:GLint = 0
    public var u_TextureInfo:GLint = 0
    public var u_Alpha:GLint = 0
    public var a_Index:GLint = 0
    public var a_Position:GLint = 0
    public var a_Texture:GLint = 0
    
    public let defaultTextureName:GLuint
    public var currentTextureName:GLuint = 0
    public var currentFramebuffer = GLSFramebufferReference()
    public var clearColor:SCVector4? = SCVector4.blackColor
    
    private var textureGroups:[GLSUniversalTextureWrangler.TextureGroup] = []
    
    override init() {
        
        self.program = ShaderHelper.programForString("Universal 2D Shader")!
        
        self.u_Projection = glGetUniformLocation(self.program, "u_Projection")
        self.u_ModelMatrix = glGetUniformLocation(self.program, "u_ModelMatrix")
//        self.u_ViewPosition = glGetUniformLocation(self.program, "u_ViewPosition")
        self.u_TintColor = glGetUniformLocation(self.program, "u_TintColor")
        self.u_TintIntensity = glGetUniformLocation(self.program, "u_TintIntensity")
        self.u_ShadeColor = glGetUniformLocation(self.program, "u_ShadeColor")
        self.u_TextureInfo = glGetUniformLocation(self.program, "u_TextureInfo")
        self.u_Alpha = glGetUniformLocation(self.program, "u_Alpha")
        self.a_Index = glGetAttribLocation(self.program, "a_Index")
        self.a_Position = glGetAttribLocation(self.program, "a_Position")
        self.a_Texture = glGetAttribLocation(self.program, "a_Texture")
        
        self.defaultTextureName = CCTextureOrganizer.textureForString("Error Block")?.name ?? 0
        self.currentTextureName = self.defaultTextureName
        
        super.init()
        
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vertexBuffer)
        
//        print("\(self.program) \(vertexBuffer) \(u_Projection) \(u_ModelMatrix) \(u_TintColor) \(u_TintIntensity) \(u_ShadeColor) \(u_TextureInfo) \(u_Alpha) \(a_Index) \(a_Position) \(a_Texture)\n")
        
    }//initialize
    
    public func bind() {
        
        let uRend = GLSUniversalRenderer.sharedInstance
        let rCount = GLsizei(uRend.references.count)
        
        self.bind(Int(rCount), vertices: uRend.vertices, modelMatrices: uRend.modelMatrices.values, tintColors: uRend.tintColors.values, tintIntensities: uRend.tintIntensities.values, shadeColors: uRend.shadeColors.values, alphas: uRend.alphas)
        /*
        return;
            
        glUseProgram(self.program)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), sizeof(UVertex) * uRend.vertices.count, uRend.vertices, GLenum(GL_STREAM_DRAW))
        
        glBindTexture(GLenum(GL_TEXTURE_2D), self.currentTextureName)
        glUniform1f(self.u_TextureInfo, 0)
        
        glUniformMatrix4fv(self.u_Projection, 1, 0, uRend.projection.values)
        glUniformMatrix4fv(self.u_ModelMatrix, rCount, 0, uRend.modelMatrices.values)
//        glUniform2f(self.u_ViewPosition, GLfloat(uRend.camera.position.x), GLfloat(uRend.camera.position.y))
        
        glUniform3fv(self.u_TintColor, rCount, uRend.tintColors.values)
        glUniform3fv(self.u_TintIntensity, rCount, uRend.tintIntensities.values)
        glUniform3fv(self.u_ShadeColor, rCount, uRend.shadeColors.values)
        glUniform1fv(self.u_Alpha, rCount, uRend.alphas)
        
        let stride = sizeof(UVertex)
        self.bridgeAttribute(self.a_Position, size: 2, stride: stride, position: 0)
        self.bridgeAttribute(self.a_Texture, size: 2, stride: stride, position: 2)
        self.bridgeAttribute(self.a_Index, size: 1, stride: stride, position: 4)
        
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        */
    }//bind
    
    public var backgroundVertices:[UVertex] = []
    public func bind(count:Int, vertices:[UVertex], modelMatrices:[GLfloat], tintColors:[GLfloat], tintIntensities:[GLfloat], shadeColors:[GLfloat], alphas:[GLfloat]) {
        
//        dispatch_suspend(GLSUniversalRenderer.sharedInstance.backgroundQueue)
        let rCount = GLsizei(count)
        
        /*self.backgroundVertices.removeAll(keepCapacity: true)
        for cur in vertices {
            self.backgroundVertices.append(cur)
        }*/
        self.backgroundVertices = vertices
        self.backgroundVertices.append(UVertex())
        self.backgroundVertices.removeLast()
        
        glUseProgram(self.program)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), sizeof(UVertex) * vertices.count, backgroundVertices/*vertices*/, GLenum(GL_DYNAMIC_DRAW))
    
        self.textureGroups = GLSUniversalTextureWrangler.getTextures(GLSUniversalRenderer.sharedInstance.references)
//        self.textureGroups = [ GLSUniversalTextureWrangler.TextureGroup(texture: self.defaultTextureName, start: 0, count: self.backgroundVertices.count) ]
        /*glBindTexture(GLenum(GL_TEXTURE_2D), self.currentTextureName)
        glUniform1i(self.u_TextureInfo, 0)*/
        
        glUniformMatrix4fv(self.u_Projection, 1, 0, GLSUniversalRenderer.sharedInstance.projection.values)
        glUniformMatrix4fv(self.u_ModelMatrix, rCount, 0, modelMatrices)
//        glUniform2f(self.u_ViewPosition, GLfloat(uRend.camera.position.x), GLfloat(uRend.camera.position.y))
        
        glUniform3fv(self.u_TintColor, rCount, tintColors)
        glUniform3fv(self.u_TintIntensity, rCount, tintIntensities)
        glUniform3fv(self.u_ShadeColor, rCount, shadeColors)
        glUniform1fv(self.u_Alpha, rCount, alphas)
        
        let stride = sizeof(UVertex)
        self.bridgeAttribute(self.a_Position, size: 2, stride: stride, position: 0)
        self.bridgeAttribute(self.a_Texture, size: 2, stride: stride, position: 2)
        self.bridgeAttribute(self.a_Index, size: 1, stride: stride, position: 4)
        
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        
    }//bind
    
    public var isRendering = false
    public var renderCount = 0
    public func render() {
        
//        let uRend = GLSUniversalRenderer.sharedInstance
        
        self.currentFramebuffer.bind()
        self.bindClearColor()
        
        for cur in self.textureGroups {
            cur.render()
        }
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glDisableVertexAttribArray(GLuint(self.a_Position))
        glDisableVertexAttribArray(GLuint(self.a_Texture))
        glDisableVertexAttribArray(GLuint(self.a_Index))
        /*
        return;

        dispatch_suspend(GLSUniversalRenderer.sharedInstance.backgroundQueue)
        /*dispatch_suspend(ParticleEmitterBackgroundQueue.sharedInstance.queues[0])
        dispatch_suspend(dispatch_get_main_queue())*/
        
        
        /*glBindTexture(GLenum(GL_TEXTURE_2D), self.defaultTextureName)
        glDrawArrays(TexturedQuad.drawingMode, 0, GLsizei(uRend.vertices.count))*/
        var count = 0
        for cur in uRend.references {
            
            if (cur.hidden) {
                continue
            }
            
            self.swapTexture(cur)

            glDrawArrays(TexturedQuad.drawingMode, GLsizei(cur.startIndex), GLsizei(cur.vertexCount))

        }
        
        dispatch_resume(GLSUniversalRenderer.sharedInstance.backgroundQueue)
        /*dispatch_resume(ParticleEmitterBackgroundQueue.sharedInstance.queues[0])
        dispatch_resume(dispatch_get_main_queue())*/
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glDisableVertexAttribArray(GLuint(self.a_Position))
        glDisableVertexAttribArray(GLuint(self.a_Texture))
        glDisableVertexAttribArray(GLuint(self.a_Index))
        */
    }//render
    
    public func bindClearColor() {
        
        if let c = self.clearColor {
            glClearColor(GLfloat(c.r), GLfloat(c.b), GLfloat(c.g), GLfloat(c.a))
            glClear(GLenum(GL_COLOR_BUFFER_BIT))
        }
        
    }//bind clear color
    
    public func swapTexture(reference:GLSNodeReference) {
        
        let curTex = reference.textureName
        
        if (curTex != self.currentTextureName) {
            self.currentTextureName = curTex
            glBindTexture(GLenum(GL_TEXTURE_2D), curTex)
        }
        
    }//swap textures (potentially)
    
    public func swapFramebuffer(reference:GLSNodeReference) {
        
        if let bufRef = reference.node?.framebufferReference {
            if (bufRef != self.currentFramebuffer) {
                bufRef.bind()
                self.currentFramebuffer = bufRef
            }
        }
        
    }//swap framebuffers
    
}

//UniversalRenderProgram + SharedInstance
public extension UniversalRenderProgram {
    
    public class var sharedInstance:UniversalRenderProgram {
        struct StaticInstance {
            static let instance = UniversalRenderProgram()
        }
        
        return StaticInstance.instance
    }
    
}//SharedInstance

public extension UniversalRenderProgram {
    
    public func bridgeUniform3f(location:GLint, vector:SCVector3) {
        
        glUniform3f(location, GLfloat(vector.x), GLfloat(vector.y), GLfloat(vector.z))
        
    }//glUniform3f
    
    public func bridgeUniform4f(location:GLint, vector:SCVector4) {
        
        glUniform4f(location, GLfloat(vector.x), GLfloat(vector.y), GLfloat(vector.z), GLfloat(vector.w))
        
    }//glUniform4f
    
    public func bridgeAttribute(location:GLint, size:Int, stride:Int, position:Int) {
        
        glEnableVertexAttribArray(GLuint(location))
        
        let pointer = UnsafePointer<Void>(bitPattern: sizeof(GLfloat) * position)
        glVertexAttribPointer(GLuint(location), GLint(size), GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(stride), pointer)
        
    }//bridge attribute
    
    public func getHex(value:GLenum) -> NSString {
        return NSString(format: "%x", value)
    }
    
}
