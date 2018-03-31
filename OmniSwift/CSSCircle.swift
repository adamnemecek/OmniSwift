//
//  CSSCircle.swift
//  InverseKinematicsTest
//
//  Created by Cooper Knaak on 10/21/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

import UIKit


public class CSSCircle: CSSEllipse {

    public let radius:CGFloat

    public init(center:CGPoint, radius:CGFloat) {
        self.radius = radius

        super.init(center: center, size: CGSize(width: radius * 2.0, height: radius * 2.0))

    }//initialize


    public func positiveYForX(xValue:CGFloat) -> CGFloat? {

        if (!CSSShape.inBetween(lower: center.x - radius, higher: center.x + radius, value: xValue)) {

            return nil

        }//invalid value

        let realX = xValue - center.x
        return center.y + sqrt(radius * radius - realX * realX)
    }//positive y-value for x-value

    public func negativeYForX(xValue:CGFloat) -> CGFloat? {

        if (!CSSShape.inBetween(lower: center.x - radius, higher: center.x + radius, value: xValue)) {

            return nil

        }//invalid value

        let realX = xValue - center.x
        return center.y - sqrt(radius * radius - realX * realX)
    }//negative y-value for x-value

    public func positiveXForY(yValue:CGFloat) -> CGFloat? {

        if (!CSSShape.inBetween(lower: center.y - radius, higher: center.y + radius, value: yValue)) {

            return nil

        }//invalid value

        let realY = yValue - center.y
        return center.x + sqrt(radius * radius - realY * realY)
    }//positive x-value for y-value

    public func negativeXForY(yValue:CGFloat) -> CGFloat? {

        if (!CSSShape.inBetween(lower: center.y - radius, higher: center.y + radius, value: yValue)) {

            return nil

        }//invalid value

        let realY = yValue - center.y
        return center.x - sqrt(radius * radius - realY * realY)
    }//negative x-value for y-value

    public func pointForAngle(theta:CGFloat) -> CGPoint {

        return CGPoint(angle: theta, length: radius) + center

    }//get point for angle

    public func pointLiesInside(point:CGPoint) -> Bool {
        let xDist = point.x - center.x
        let yDist = point.y - center.y

        //Square Root call can be removed by comparing
        //Square of distance to square of radius
        return (xDist * xDist + yDist * yDist) <= radius * radius
    }//point lies inside circle


    override public func copy() -> AnyObject {
        return CSSCircle(center: center, radius: radius)
    }//copy

    override public var description:String {

        return "Circle \(center) \(radius)"

    }//description

    override public func collide(shape: CSSShape) -> Bool {

            if (!CGRectIntersectsRect(self.frame, shape.frame)) {

                return false

            }//frames don't collide, so shapes can't collide

        if let shapeLineSegment = shape as? CSSLineSegment {

            return shapeLineSegment.collideLineSegmentWithCircle(self)

        }//line segment

        else if let shapeRectangle = shape as? CSSRectangle {

            return shapeRectangle.collideRectangleWithCircle(self)

        }//rectangle

        else if let shapeTriangle = shape as? CSSTriangle {

            return shapeTriangle.collideTriangleWithCircle(self)

        }//triangle

        else if let shapeCircle = shape as? CSSCircle {

            return collideCircleWithCircle(shapeCircle)

        }//circle

        return false

    }//collision detection

}//CSSCircle

public extension CSSCircle {

    public func collideCircleWithCircle(shape:CSSCircle) -> Bool {

        //return center.distanceFrom(shape.center) <= radius + shape.radius
        let dist = self.center.distanceFrom(shape.center)
        let radPlus = self.radius + shape.radius

        return dist <= radPlus
    }//collide circle with circle

}//collision detection
