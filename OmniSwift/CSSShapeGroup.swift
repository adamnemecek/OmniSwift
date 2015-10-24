//
//  CSSShapeGroup.swift
//  InverseKinematicsTest
//
//  Created by Cooper Knaak on 10/23/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

import UIKit


public class CSSShapeGroup: NSObject {
   
    public var shapes:[CSSShape] = []
    public var frame = CGRectZero
    public var center:CGPoint = CGPointZero {
        
        willSet {
            let translateBy = newValue - center
            
            for iii in 0..<shapes.count {
                self.shapes[iii].translate(translateBy)
            }//translate shapes
            
            self.frame = CGRect(center: newValue, size: self.frame.size)
        }//set center
        
    }//center
    
    public init(shapes:[CSSShape], frame:CGRect) {
        
        self.shapes = shapes
        self.frame = frame
        self.center = self.frame.center
        
        super.init()
    }//initialize
    
    public convenience init(shapes:[CSSShape]) {
        
        var minX:CGFloat = 0.0
        var minY:CGFloat = 0.0
        var maxX:CGFloat = 0.0
        var maxY:CGFloat = 0.0
        
        for iii in 0..<shapes.count {
            
            if (iii == 0) {
                minX = CGRectGetMinX(shapes[iii].frame)
                minY = CGRectGetMinY(shapes[iii].frame)
                maxX = CGRectGetMaxX(shapes[iii].frame)
                maxY = CGRectGetMaxY(shapes[iii].frame)
                continue
            }//first shape, set values directly
            
            
            minX = min(minX, CGRectGetMinX(shapes[iii].frame))
            minY = min(minY, CGRectGetMinY(shapes[iii].frame))
            maxX = min(maxX, CGRectGetMaxX(shapes[iii].frame))
            maxY = min(maxY, CGRectGetMaxY(shapes[iii].frame))
        }//find correct min/max values
        
        self.init(shapes:shapes, frame:CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY))
    }//initialize
    
    
    public func collide(group:CSSShapeGroup) -> Bool {
        
        if (!CGRectIntersectsRect(self.frame, group.frame)) {
            
            return false
            
        }//cannot collide
        
        for iii in 0..<shapes.count {
            
            for jjj in 0..<group.shapes.count {
                
                if (shapes[iii].collide(group.shapes[jjj])) {
                    
                    return true
                    
                }//shapes do collide
                
            }//loop through other group's shapes
            
        }//loop through my shapes
        
        return false
    }//check for collision
    
    
    override public var description:String {
        
        var str = "Shape Group \(frame) \(center)\n"
        
        for iii in 0..<shapes.count {
            str += "\(shapes[iii])\n"
        }//add shapes
        
        return str
    }//get description
    
    
}//CSSShapeGroup
