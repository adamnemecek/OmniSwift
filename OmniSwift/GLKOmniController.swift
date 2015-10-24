//
//  GLKOmniController.swift
//  Fields and Forces
//
//  Created by Cooper Knaak on 12/13/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

import GLKit

public class GLKOmniController: GLKViewController {
    
    public var framebufferStack:GLSFramebufferStack! = nil
    public var container:GLSNode! = nil
    public var projection:SCMatrix4 = SCMatrix4()

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        
        let glkView = self.view as! GLKView
        glkView.context = CCTextureOrganizer.sharedContext
        EAGLContext.setCurrentContext(CCTextureOrganizer.sharedContext)
        
        self.container = GLSNode(frame: CGRectZero, projection: projection)
        
        self.framebufferStack = GLSFramebufferStack(initialBuffer: glkView)
        self.container.framebufferStack = self.framebufferStack
        
        let vSize = self.getFrame().size
        self.projection = SCMatrix4(right: vSize.width, top: vSize.height, back: -1024, front: 1024)
        
//        GLKOmniController.setupOpenGL()
        
        self.preferredFramesPerSecond = 30
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override public func glkView(view: GLKView, drawInRect rect: CGRect) {
        
        glClearColor(0.2, 0.2, 0.2, 1.0)
        glClear(GLenum(GL_COLOR_BUFFER_BIT))
        
        self.container.render(SCMatrix4())
//        GLSUniversalRenderer.render()


    }//draw
    
    public func update() {
        
        let dt = CGFloat(self.timeSinceLastUpdate)
        
        self.updateContainer(dt)
        

    }//update
    
    public func updateContainer(dt:CGFloat) {
        
        self.container.update(dt)
    }//update container

    
    public func calculateProjection() {
        let vSize = self.view.frame.size
        self.projection = SCMatrix4(right: vSize.width, top: vSize.height, back: -1024, front: 1024)
    }
    
    
    public class func setupOpenGL() {
        struct StaticOnceToken {
            static var onceToken:dispatch_once_t = 0;
        }
        
        dispatch_once(&StaticOnceToken.onceToken) {
            let cctOrg = CCTextureOrganizer.sharedInstance
            cctOrg.files = [ "Atlases" ]
            cctOrg.loadTextures()
            
            ShaderHelper.sharedInstance.loadPrograms(["Basic Shader":"BasicShader", "Universal 2D Shader":"Universal2DShader", "Universal Particle Shader":"UniversalParticleShader", "Noise Shader":"NoiseShader"])
        }//dispatch only one time
        
    }//setup OpenGL
    
}
/*
//GLKOmniControler+TouchesAndControls
public extension GLKOmniController {
    
    override public func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        let touchLocation = self.locationFromTouches(touches)
    }//touches began
    
    override public func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        
        let touchLocation = self.locationFromTouches(touches)
    }//touches moved
    
    override public func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        
        let touchLocation = self.locationFromTouches(touches)
    }//touches moved
    
    override public func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
        
        let touchLocation = self.locationFromTouches(touches)
    }
    
}// Touches and Controls
*/