//
//  CSSEllipse.swift
//  InverseKinematicsTest
//
//  Created by Cooper Knaak on 10/21/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

import UIKit

public class CSSEllipse: CSSShape {
    
    public var center = CGPoint()
    public var size = CGSize()
    
    override public var frame:CGRect {
        return CGRect(x: center.x - size.width / 2.0, y: center.y - size.height / 2.0, width: size.width, height: size.height)
    }//get frame
    
    public var eccentricity:CGFloat {
        let a = size.width / 2.0
        let b = size.height / 2.0
        return sqrt(1.0 - b * b / a * a)
    }//get eccentricity
    
    public init(center:CGPoint, size:CGSize) {
        self.center = center
        self.size = size
    }//initialize
    
    
    override public func translate(trans: CGPoint) {
        center += trans
    }//translate
    
    override public func copy() -> AnyObject {
        return CSSEllipse(center: center, size: size)
    }//copy
    
    override public var description:String {
        
        return "Ellipse \(center) \(size)"
        
    }//description
    
}//CSSEllipse
