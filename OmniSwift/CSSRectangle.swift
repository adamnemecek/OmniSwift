//
//  CSSRectangle.swift
//  InverseKinematicsTest
//
//  Created by Cooper Knaak on 10/21/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

import UIKit


public class CSSRectangle: CSSShape {

    public var center = CGPoint()
    public var size = CGSize()


    public var left:CGFloat {
        return center.x - size.width / 2.0
    }//left

    public var right:CGFloat {
        return center.x + size.width / 2.0
    }//right

    public var bottom:CGFloat {
        return center.y - size.height / 2.0
    }//bottom

    public var top:CGFloat {
        return center.y + size.height / 2.0
    }//top

    public var topLeft:CGPoint {
        return CGPoint(x: left, y: top)
    }//top left

    public var topRight:CGPoint {
        return CGPoint(x: right, y: top)
    }//top right

    public var bottomLeft:CGPoint {
        return CGPoint(x: left, y: bottom)
    }//bottom left

    public var bottomRight:CGPoint {
        return CGPoint(x: right, y: bottom)
    }//bottom right

    public let lines:[CSSLineSegment]

    override public var frame:CGRect {
        return CGRect(x: center.x - size.width / 2.0, y: center.y - size.height / 2.0, width: size.width, height: size.height)
    }//frame

    public init(center:CGPoint, size:CGSize) {
        self.center = center
        self.size = size

        let cx = center.x
        let cy = center.y
        let w = size.width / 2.0
        let h = size.height / 20
        self.lines = [  CSSLineSegment(x1: cx - w, y1: cy + h, x2: cx + w, y2: cy + h),
            CSSLineSegment(x1: cx + w, y1: cy + h, x2: cx + w, y2: cy - h),
            CSSLineSegment(x1: cx + w, y1: cy - h, x2: cx - w, y2: cy - h),
            CSSLineSegment(x1: cx - w, y1: cy - h, x2: cx - w, y2: cy + h)]

        super.init()

    }//initialize

    public convenience init(center:CGPoint, width:CGFloat, height:CGFloat) {
        self.init(center:center, size:CGSize(width:width, height:height))
    }//initialize

    public convenience init(origin:CGPoint, size:CGSize) {
        self.init(center:CGPoint(x: origin.x + size.width / 2.0, y: origin.y + size.height / 2.0), size:size)
    }//initialize

    public convenience init(rect:CGRect) {
        self.init(origin:rect.origin, size:rect.size)
    }//initialize



    public func pointLiesInside(point:CGPoint) -> Bool {
        return CSSShape.inBetween(lower: left, higher: right, value: point.x)
            && CSSShape.inBetween(lower: bottom, higher: top, value: point.y)
    }//checks if point lies inside rectangle


    override public func translate(trans: CGPoint) {
        center += trans

        for iii in 0..<lines.count {

            lines[iii].translate(trans)

        }//translate lines

    }//translate

    override public func collide(shape:CSSShape) -> Bool {

        if (!CGRectIntersectsRect(self.frame, shape.frame)) {

            return false

        }//frames don't collide, so shapes can't collide

        if let shapeLine = shape as? CSSLineSegment {

            return shapeLine.collideLineSegmentWithRectangle(self)

        }//line segment

        else if let shapeRectangle = shape as? CSSRectangle {

            return shapeRectangle.collideRectangleWithRectangle(shapeRectangle)

        }//rectangle

        else if let shapeTriangle = shape as? CSSTriangle {

            return self.collideRectangleWithTriangle(shapeTriangle)

        }//triangle

        else if let shapeCircle = shape as? CSSCircle {

            return self.collideRectangleWithCircle(shapeCircle)

        }//circle


        return false
    }//collision detection


    override public func copy() -> AnyObject {
        return CSSRectangle(center: center, size: size)
    }//copy

    override public var description:String {

        return "Rectangle \(center) \(size)"

    }//description


}//CSSRectangle

public extension CSSRectangle {

    public func collideRectangleWithRectangle(shape:CSSRectangle) -> Bool {

        for iii in 0..<lines.count {

            if (lines[iii].collideLineSegmentWithRectangle(shape)) {

                return true

            }//collision

            if (shape.lines[iii].collideLineSegmentWithRectangle(self)) {

                return true

            }//collision

        }//loop through lines

        //collideLineSegmentWithRectangle handles all cases, including when lines touch
        //or when lines lie entirely inside rectangle
        return false
    }//collide rectangle with rectangle

    public func collideRectangleWithTriangle(shape:CSSTriangle) -> Bool {

        for iii in 0..<lines.count {

            if (lines[iii].collideLineSegmentWithTriangle(shape)) {

                return true

            }//collision

            if (shape.lines[iii].collideLineSegmentWithRectangle(self)) {

                return true

            }//collision

        }//loop through lines

        //collideLineSegmentWithTriangle and collideLineSegmentWithRectangle handle
        //all cases, including when lines touch or when lines lie entirely inside rectangle
        return false

    }//collide rectangle with triangle

    public func collideRectangleWithCircle(shape:CSSCircle) -> Bool {

        for iii in 0..<lines.count {

            if (lines[iii].collideLineSegmentWithCircle(shape)) {

                return true

            }//collision

        }//loop through lines

        //If center does not lie inside but rectangle and circle collide,
        //then the lines must collide and collideLineSegmentWithCircle
        //catches it. Otherwise, circle's center must be inside rectangle
        //for rectangle to collide but not individual lines

        return self.pointLiesInside(shape.center)

    }//collide rectangle with circle

}//collision detection
