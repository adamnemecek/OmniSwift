//
//  ColorWheelView.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 8/30/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import UIKit

public class ColorWheelView: GLBufferedView {
    
    // MARK: - Types
    
    private class ColorWheelProgram: GLProgramDictionary {
        
        private init() {
            ColorWheelView.prepareOpenGL()
            
            let program = ShaderHelper.programForString("Color Wheel Shader")!
            super.init(program: program, locations: [
                "u_Projection",
                "u_Brightness",
                "u_Gradient",
                "u_Alpha",
                "u_OutlineColor",
                "a_Position",
                "a_Texture"
                ])
        }
        
    }
    
    // MARK: - Properties
    
    private var hue:CGFloat = 0.0
    private var saturation:CGFloat = 0.0
    public var brightness:CGFloat = 1.0
    private let program = ColorWheelProgram()
    public let vertices = TexturedQuadVertices(vertex: UVertex())
    public let gradient = GLGradientTexture2D(gradient: ColorGradient1D.hueGradient)
    
    private lazy var pinchRecognizer:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
    private let scaleDelta = ScaleDelta(scale: 1.0)
    private lazy var panRecognizer:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
    private lazy var rotationRecognizer:UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "handleRotation:")
    private var wheelAlpha:CGFloat = 1.0
    private var currentWheelAlpha:CGFloat = 1.0
    private let anchorImage = UIImageView(image: UIImage.imageWithPDFFile("CircleAnchor", size: CGSize(square: 48.0)))
    
    private(set) var currentColor = UIColor.whiteColor()
    public var colorChangedHandler:((UIColor) -> Void)? = nil
    
    public var enableRotation   = false
    public var outlineColor     = SCVector4.blackColor
    
    override public var frame:CGRect {
        didSet {
            if !(self.frame.width ~= oldValue.width || self.frame.height ~= oldValue.height) {
                self.renderToBuffer()
            }
        }
    }
    
    // MARK: - Setup
    
    override public init(frame:CGRect) {
        super.init(frame: frame)
        
        self.userInteractionEnabled = true
        self.addGestureRecognizer(self.pinchRecognizer)
        self.addGestureRecognizer(self.panRecognizer)
        self.addGestureRecognizer(self.rotationRecognizer)
        
        self.anchorImage.center = frame.size.center
        self.addSubview(self.anchorImage)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.brightness = CGFloat(aDecoder.decodeDoubleForKey("Brightness"))
        
        super.init(coder: aDecoder)
        
        self.userInteractionEnabled = true
        self.addGestureRecognizer(self.pinchRecognizer)
        self.addGestureRecognizer(self.panRecognizer)
        self.addGestureRecognizer(self.rotationRecognizer)
        
        self.anchorImage.center = self.frame.size.center
        self.addSubview(self.anchorImage)
    }
    
    override public func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        
        aCoder.encodeDouble(Double(self.brightness), forKey: "Brightness")
    }
    
    override public func regenerateBuffer() -> GLSFrameBuffer {
        
        self.vertices.iterateWithHandler() { index, vertex in
            let point = TexturedQuad.pointForIndex(index)
            vertex.position = (point * self.frame.size).getGLTuple()
            vertex.texture  = (point * 2.0 - 1.0).getGLTuple()
            vertex.texture.0 *= -1.0
        }
        return super.regenerateBuffer()
    }
    
    // MARK: - Logic
    
    private func regenerateColor() {
        self.currentColor = UIColor(hue: self.hue, saturation: self.saturation, brightness: self.brightness, alpha: self.wheelAlpha)
        self.colorChangedHandler?(self.currentColor)
    }
    
    override public func render() {
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.buffer.framebuffer)
        
        self.program.use()
        self.vertices.bufferData(GL_STATIC_DRAW)
        
        SCVector4().bindGLClearColor()
        
        let proj = GLSNode.universalProjection
        glUniformMatrix4fv(self.program["u_Projection"], 1, 0, proj.values)
        glUniform1f(self.program["u_Brightness"], GLfloat(self.brightness))
        glBindTexture(GLenum(GL_TEXTURE_2D), self.gradient.textureName)
        glUniform1f(self.program["u_Gradient"], 0.0)
        glUniform1f(self.program["u_Alpha"], GLfloat(self.wheelAlpha))
        self.program.uniform4f("u_OutlineColor", value: self.outlineColor)
        
        self.program.enableAttributes()
        self.program.bridgeAttributesWithSizes([2, 2], stride: self.vertices.stride)
        self.vertices.drawArrays()
        glFinish()
        self.program.disableAttributes()
    }
    
    public func handlePinch(sender:UIPinchGestureRecognizer) {
        self.scaleDelta.handlePinch(sender)
        self.brightness = self.scaleDelta.currentScale
        self.regenerateColor()
        self.renderToBuffer()
    }
    
    public func handlePan(sender:UIPanGestureRecognizer) {
        let location = sender.locationInView(self)
        let clampedLocation = CGPoint(x: location.x / self.frame.width, y: location.y / self.frame.height) * 2.0 - 1.0
        // I don't know why I must invert the x location.
        // I think it has something to do with the image & angle.
        let angle = atan2(clampedLocation.y, -clampedLocation.x)
        let hue = (angle / CGFloat(M_PI) + 1.0) / 2.0
        let saturation = clampedLocation.distanceFrom(CGPoint.zero)
        
        self.hue = hue
        self.saturation = saturation
        self.regenerateColor()
        
        let anchorAngle = atan2(clampedLocation.y, clampedLocation.x)
        let distance = location.distanceFrom(self.frame.size.center)
        self.anchorImage.center = CGPoint(angle: anchorAngle, length: min(distance, self.frame.size.width / 2.0)) + self.frame.size.center
    }
    
    public func handleRotation(sender:UIRotationGestureRecognizer) {
        guard self.enableRotation else {
            return
        }
        
        self.wheelAlpha = self.currentWheelAlpha + CGFloat(sender.rotation) * 2.0 / CGFloat(M_PI)
        self.wheelAlpha = min(max(self.wheelAlpha, 0.0), 1.0)
        
        switch sender.state {
        case .Ended:
            self.currentWheelAlpha = self.wheelAlpha
        default:
            break
        }
        
//        self.alpha = self.wheelAlpha
        self.renderToBuffer()
        self.regenerateColor()
    }
    
    public func setColor(color:UIColor, animated:Bool) {
        let comps = color.getHSBComponents()
        if animated {
            
        } else {
            self.hue        = comps[0]
            self.saturation = comps[1]
            self.brightness = comps[2]
            self.wheelAlpha = comps[3]
            self.regenerateColor()
        }
    }
}