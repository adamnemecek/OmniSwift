//
//  CSSShape.swift
//  InverseKinematicsTest
//
//  Created by Cooper Knaak on 10/21/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

import UIKit


public class CSSShape: NSObject {

    public var frame:CGRect {
        return CGRectZero
    }//get frame
    
    public func translate(trans:CGPoint) {
        print("Error: CSSShape.translate()")
    }//translate shape
    
    override public func copy() -> AnyObject {
        print("Error: CSSShape.copy()")
        return self
    }//copy shape
    
    public func collide(shape:CSSShape) -> Bool {
        
        print("Error: CSSShape.collide()")
        
        return false
    }//collision detection
    
    override public var description:String {
        
        return "Error CSSShape::description"
        
    }//description
    
}

//Calculations
public extension CSSShape {
    
    public class var CloseEnoughFloat:CGFloat {
        return 0.001;
    }//used for 'epsilon' calculations
    
    public class func epsilon(val1:CGFloat, val2:CGFloat, error:CGFloat = CSSShape.CloseEnoughFloat) -> Bool {
        return abs(val1 - val2) < error
    }//check floating point equality
    
    //public class let CloseEnoughFloat:Float = 0.001
    public class func inBetween(lower lower:CGFloat, higher:CGFloat, value:CGFloat) -> Bool {
        return (lower <= value && value <= higher) || (higher <= value && value <= lower)
    }//in between the values
    
}//logical functions