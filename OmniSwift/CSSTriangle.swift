//
//  CSSTriangle.swift
//  InverseKinematicsTest
//
//  Created by Cooper Knaak on 10/21/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

import UIKit


public class CSSTriangle: CSSShape {

    public var points:[CGPoint] = []
    public var lines:[CSSLineSegment] = []
    
    override public var frame:CGRect {
        var minX:CGFloat = points[0].x
        var minY:CGFloat = points[0].x
        var maxX:CGFloat = points[0].x
        var maxY:CGFloat = points[0].y
        
        for iii in 0..<points.count {
            minX = min(minX, points[iii].x)
            maxX = max(maxX, points[iii].x)
            minY = min(minX, points[iii].y)
            maxY = max(maxX, points[iii].y)
        }//get true values
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }//get frame
    
    
    public init(point1:CGPoint, point2:CGPoint, point3:CGPoint) {
        points.append(point1)
        points.append(point2)
        points.append(point3)
        
        lines.append(CSSLineSegment(point1: points[0], point2: points[1]))
        lines.append(CSSLineSegment(point1: points[1], point2: points[2]))
        lines.append(CSSLineSegment(point1: points[2], point2: points[0]))
    }//initialize
    
    
    public func pointLiesInside(point:CGPoint) -> Bool {
        
        for iii in 0..<lines.count {
            
            for jjj in iii..<lines.count {
                
                if (lines[iii].validX(point.x) && lines[jjj].validX(point.x)) {
                
                    //x-value is valid for both lines, so
                    //y-values are guarunteed to exist
                    
                    let y1 = lines[iii].yForX(point.x)!
                    let y2 = lines[jjj].yForX(point.x)!
                    
                    return CSSShape.inBetween(lower: y1, higher: y2, value: point.y)
                    
                }//x-value is valid for both lines
                
            }//loop through combinations of lines
            
        }//loop through combinations of lines
        
        return false
    }//point lies inside
    
    
    override public func translate(trans: CGPoint) {
        
        for iii in 0..<points.count {
            points[iii] += trans
            lines[iii].translate(trans)
        }//translate points
        
    }//translate
    
    override public func copy() -> AnyObject {
        return CSSTriangle(point1: points[0], point2: points[1], point3: points[2])
    }//copy
    
    override public var description:String {
        
        return "Triangle \(points[0]) \(points[1]) \(points[2])"
        
    }//description
    
    
    override public func collide(shape: CSSShape) -> Bool {
            
            if (!CGRectIntersectsRect(self.frame, shape.frame)) {
                
                return false
                
            }//frames don't collide, so shapes can't collide
        
        if let shapeLine = shape as? CSSLineSegment {
            
            return shapeLine.collideLineSegmentWithTriangle(self)
            
        }//line segment
            
        else if let shapeRectangle = shape as? CSSRectangle {
            
            return shapeRectangle.collideRectangleWithTriangle(self)
            
        }//rectangle
            
        else if let shapeTriangle = shape as? CSSTriangle {
            
            return collideTriangleWithTriangle(shapeTriangle)
            
        }//triangle
            
        else if let shapeCircle = shape as? CSSCircle {
            
            return collideTriangleWithCircle(shapeCircle)
            
        }//circle
        
        return false
    }//collision detection
    
}//CSSTriangle

public extension CSSTriangle {
    
    
    public func collideTriangleWithTriangle(shape:CSSTriangle) -> Bool {
        
        for iii in 0..<lines.count {
            
            if (self.lines[iii].collideLineSegmentWithTriangle(shape)) {
                
                return true
                
            }//collision
            
        }//loop through lines
        
        for iii in 0..<lines.count {
            
            if (shape.lines[iii].collideLineSegmentWithTriangle(self)) {
                
                return true
                
            }//collision
            
        }//loop through shape's lines
        
        return false
    }//collide triangle with triangle
    
    public func collideTriangleWithCircle(shape:CSSCircle) -> Bool {
        
        for iii in 0..<lines.count {
            
            if (lines[iii].collideLineSegmentWithCircle(shape)) {
                
                return true
                
            }//collision
            
        }//loop through lines
        
        //If center lies inside, shapes collide. If center doesn't, but
        //Lines touch, then collideLineSegmentWithCircle returns true
        
        return self.pointLiesInside(shape.center)
        
    }//collide triangle with circle
    
    
}//collision detection