//
//  GLBufferedView.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 8/30/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import UIKit

public class GLBufferedView: UIImageView {

    // MARK: - Properties
    
    override public var frame:CGRect {
        didSet {
            self.buffer = self.regenerateBuffer()
        }
    }
    
    private(set) public lazy var buffer:GLSFrameBuffer = self.regenerateBuffer()
    
    // MARK: - Setup
    
    ///Returns a GLSFrameBuffer object of the correct size for this view.
    public func regenerateBuffer() -> GLSFrameBuffer {
        GLBufferedView.prepareOpenGL()
        return GLSFrameBuffer(size: self.frame.size)
    }
    
    public class func prepareOpenGL() {
        if EAGLContext.currentContext() != nil && ShaderHelper.sharedInstance.isLoaded {
            return
        }
        
        EAGLContext.setCurrentContext(CCTextureOrganizer.sharedContext)
        let viewPort = GLsizei(1024.0 * GLSFrameBuffer.getRetinaScale())
        glViewport(0, 0, viewPort, viewPort)
        GLSNode.universalProjection = SCMatrix4(right: 1024.0, top: 1024.0, back: -1024.0, front: 1024.0)
        
        ShaderHelper.sharedInstance.loadProgramsFromBundle()
    }
    
    // MARK: - Logic
    
    ///Renders the image to the OpenGL buffer and then converts that to a UIImage.
    final public func renderToBuffer() {
        GLBufferedView.prepareOpenGL()
        self.render()
        glFinish()
        self.image = self.buffer.getImage()
    }
    
    ///Override to bind and render to your framebuffer.
    public func render() {
        
    }
}
