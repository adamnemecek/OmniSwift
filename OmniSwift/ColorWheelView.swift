//
//  ColorWheelView.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 8/30/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import UIKit

public class ColorWheelView: GLBufferedView, UIGestureRecognizerDelegate {
    
    // MARK: - Types
    
    private class ColorWheelAnimation {
        private let hueDelta:AnimationDelta<CGFloat>
        private let saturationDelta:AnimationDelta<CGFloat>
        private let brightnessDelta:AnimationDelta<CGFloat>
        private let alphaDelta:AnimationDelta<CGFloat>
        private let positionDelta:AnimationDelta<CGPoint>
        private var time:CGFloat = 0.0
        private let duration:CGFloat
        private var isFinished:Bool { return self.duration <= self.time }
        
        private var position:CGPoint { return self.positionDelta[self.time / self.duration] }
        
        private init(wheel:ColorWheelView, hue:CGFloat, saturation:CGFloat, brightness:CGFloat, alpha:CGFloat, position:CGPoint, duration:CGFloat) {
            self.hueDelta           = AnimationDelta(start: wheel.hue, end: hue)
            self.saturationDelta    = AnimationDelta(start: wheel.saturation, end: saturation)
            self.brightnessDelta    = AnimationDelta(start: wheel.brightness, end: brightness)
            self.alphaDelta         = AnimationDelta(start: wheel.wheelAlpha, end: alpha)
            self.positionDelta      = AnimationDelta(start: wheel.anchorImage.center, end: position)
            self.duration           = duration
        }
        
        private func update(dt:CGFloat) -> UIColor {
            self.time += dt
            let t = self.time / self.duration
            let h = self.hueDelta[t]
            let s = self.saturationDelta[t]
            let b = self.brightnessDelta[t]
            let a = self.alphaDelta[t]
            return UIColor(hue: h, saturation: s, brightness: b, alpha: a)
        }
        
    }
    
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
    
    private lazy var pinchRecognizer:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
    private var scaleDelta = ScaleDelta(scale: 2.0)
    private lazy var panRecognizer:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    private lazy var rotationRecognizer:UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation))
 
    private var wheelAlpha:CGFloat = 1.0
    private var currentWheelAlpha:CGFloat = 1.0
    private let anchorImage = UIImageView(image: UIImage.imageWithPDFFile("CircleAnchor", size: CGSize(square: 48.0)))
    
    private var currentAnimation:ColorWheelAnimation? = nil
    
    private(set) var currentColor = UIColor.whiteColor()
    public var colorChangedHandler:((UIColor) -> Void)? = nil
    public var colorStoppedChangingHandler:((UIColor) -> Void)? = nil
    
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
        self.scaleDelta.minimumScale = 1.0
        self.scaleDelta.maximumScale = 2.0
        super.init(frame: frame)
        
        self.userInteractionEnabled = true
        self.addGestureRecognizer(self.pinchRecognizer)
        self.addGestureRecognizer(self.panRecognizer)
        self.addGestureRecognizer(self.rotationRecognizer)
//        self.pinchRecognizer.delegate       = self
//        self.panRecognizer.delegate         = self
//        self.rotationRecognizer.delegate    = self
        
        self.anchorImage.center = frame.size.center
        self.addSubview(self.anchorImage)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.scaleDelta.minimumScale = 1.0
        self.scaleDelta.maximumScale = 2.0
        self.brightness = CGFloat(aDecoder.decodeDoubleForKey("Brightness"))
        
        super.init(coder: aDecoder)
        
        self.userInteractionEnabled = true
        self.addGestureRecognizer(self.pinchRecognizer)
        self.addGestureRecognizer(self.panRecognizer)
        self.addGestureRecognizer(self.rotationRecognizer)
//        self.pinchRecognizer.delegate       = self
//        self.panRecognizer.delegate         = self
//        self.rotationRecognizer.delegate    = self
        
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
            //The following line causes a segmentation fault 11 only when archiving
            //vertex.texture.0 *= -1.0
            vertex.texture = (-vertex.texture.0, vertex.texture.1)
        }
        return super.regenerateBuffer()
    }
    /*
    // MARK: - Logic
    
    private func anchorPositionForColor(color:UIColor) -> CGPoint {
        let comps = color.getHSBComponents()
        let angle = -(2.0 * comps[0]) * CGFloat(M_PI)
        let distance = self.frame.width / 2.0 * comps[1]
        return CGPoint(angle: angle, length: distance) + self.frame.size.center
    }
    */
    private func regenerateColor(invokeHandler:Bool) {
        self.currentColor = UIColor(hue: self.hue, saturation: self.saturation, brightness: self.brightness, alpha: self.wheelAlpha)
        if invokeHandler {
            self.colorChangedHandler?(self.currentColor)
        }
    }
    
    private func invokeColorStoppedChangingHandler(sender:UIGestureRecognizer) {
        
        if let handler = self.colorStoppedChangingHandler where sender.state == .Ended {
            handler(self.currentColor)
        }
    }
    /*
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
    */
    public func handlePinch(sender:UIPinchGestureRecognizer) {
        self.scaleDelta.handlePinch(sender)
        //Subtract 1.0, because I add 1.0 when I set the scaleDelta
        //because ScaleDeltas don't work when scale hits 0
        self.brightness = self.scaleDelta.currentScale - 1.0
        self.regenerateColor(true)
        self.invokeColorStoppedChangingHandler(sender)
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
        self.regenerateColor(true)
        
        let anchorAngle = atan2(clampedLocation.y, clampedLocation.x)
        let distance = location.distanceFrom(self.frame.size.center)
        self.anchorImage.center = CGPoint(angle: anchorAngle, length: min(distance, self.frame.size.width / 2.0)) + self.frame.size.center
        
        self.invokeColorStoppedChangingHandler(sender)
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
        
        self.renderToBuffer()
        self.invokeColorStoppedChangingHandler(sender)
        self.regenerateColor(true)
    }
    /*
    public func setColor(color:UIColor, animated:Bool) {
        let comps = color.getHSBComponents()
        if animated {
            let comps = color.getHSBComponents()
            self.currentAnimation = ColorWheelAnimation(wheel: self, hue: comps[0], saturation: comps[1], brightness: comps[2], alpha: comps[3], position: self.anchorPositionForColor(color), duration: 0.5)
        } else {
            self.hue        = comps[0]
            self.saturation = comps[1]
            self.brightness = comps[2]
            self.wheelAlpha = comps[3]
            
            self.currentWheelAlpha  = self.wheelAlpha
            //Add 1.0, because ScaleDeltas don't work at all when scale hits 0
            self.scaleDelta         = ScaleDelta(scale: self.brightness + 1.0)
            self.scaleDelta.minimumScale = 1.0
            self.scaleDelta.maximumScale = 2.0
            
            self.anchorImage.center = self.anchorPositionForColor(color)
            self.renderToBuffer()
            self.regenerateColor(false)
        }
    }
    
    public func updateAnimation(dt:CGFloat) {
        if let anim = self.currentAnimation {
            self.setColor(anim.update(dt), animated: false)
            self.anchorImage.center = anim.position
            if anim.isFinished {
                self.currentAnimation = nil
            }
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        switch (gestureRecognizer, otherGestureRecognizer) {
        case (self.pinchRecognizer, self.panRecognizer):
            return true
        default:
            return false
        }
    }
    */
}