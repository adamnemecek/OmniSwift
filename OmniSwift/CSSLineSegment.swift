//
//  CSSLineSegment.swift
//  InverseKinematicsTest
//
//  Created by Cooper Knaak on 10/21/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

import UIKit


public class CSSLineSegment: CSSShape {

    public var firstPoint:CGPoint = CGPointZero
    public var secondPoint:CGPoint = CGPointZero
    public let vertical:Bool
    public let slope:CGFloat?
    public var yIntercept:CGFloat? {

        if let m = slope {

            return firstPoint.y - m * firstPoint.x

        } else {

            if (CSSShape.epsilon(firstPoint.x, val2: 0.0)) {

                return firstPoint.x

            } else {

                return nil

            }

        }

    }

    override public var frame:CGRect {
        let minX = min(firstPoint.x, secondPoint.x)
        let minY = min(firstPoint.y, secondPoint.y)
        let maxX = max(firstPoint.x, secondPoint.x)
        let maxY = max(firstPoint.y, secondPoint.y)

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }//get frame

    public init(point1:CGPoint, point2:CGPoint) {

        self.firstPoint = point1
        self.secondPoint = point2

        if (CSSShape.epsilon(point1.x, val2: point2.x, error: 0.001)) {

            self.vertical = true
            self.slope = nil

        } else {

            self.vertical = false
            self.slope = (point2.y - point1.y) / (point2.x - point1.x)

        }

        super.init()
    }//initialize with points

    public convenience init(x1:CGFloat, y1:CGFloat, x2:CGFloat, y2:CGFloat) {

        self.init(point1:CGPoint(x: x1, y: y1), point2: CGPoint(x: x2, y: y2))

    }//initialize with points' components


    //These only return values if arguments are in range of line segment
    public func yForX(xValue:CGFloat) -> CGFloat? {

        if (!validX(xValue)) {

            return nil

        } else if (vertical) {

            return nil

        }

        //Passed 'vertical' test, so 'slope' and 'yIntercept' are guarunteed to exist
        return slope! * xValue + yIntercept!
    }//get y-value for x-value

    public func xForY(yValue:CGFloat) -> CGFloat? {

        if (!validY(yValue)) {

            return nil

        } else if (vertical) {

            return firstPoint.x

        }

        //Passed 'vertical' test, so slope is guarunteed to exist,
        //which means 'yIntercept' is also guarunteed to exist
        return (yValue - yIntercept!) / slope!
    }//get x-value for y-value

    public func validX(xValue:CGFloat) -> Bool {
        return CSSShape.inBetween(lower: firstPoint.x, higher: secondPoint.x, value: xValue)
    }//check whether 'xValue' is in range of line segment

    public func validY(yValue:CGFloat) -> Bool {
        return CSSShape.inBetween(lower: firstPoint.y, higher: secondPoint.y, value: yValue)
    }//check whether 'yValue' is in range of line segment


    override public func translate(trans: CGPoint) {
        firstPoint += trans
        secondPoint += trans
    }//translate

    override public func copy() -> AnyObject {
        return CSSLineSegment(point1: firstPoint, point2: secondPoint)
    }//copy

    override public var description:String {

        return "Line Segment \(firstPoint) \(secondPoint)"

    }//description


    override public func collide(shape:CSSShape) -> Bool {

        //Frames do not collide, therefore it is guarunteed
        //that shapes do not collide
        if (!CGRectIntersectsRect(self.frame, shape.frame)) {
            return false
        }//do not intersect

        if let shapeLine = shape as? CSSLineSegment {

            return collideLineSegmentWithLineSegment(shapeLine)

        }//line segment

        else if let shapeRectangle = shape as? CSSRectangle {

            return collideLineSegmentWithRectangle(shapeRectangle)

        }//rectangle

        else if let shapeTriangle = shape as? CSSTriangle {

            return collideLineSegmentWithTriangle(shapeTriangle)

        }//triangle

        else if let shapeCircle = shape as? CSSCircle {

            return collideLineSegmentWithCircle(shapeCircle)

        }//circle

        return false
    }//check collision

}//line segment

public extension CSSLineSegment {

    public func collideLineSegmentWithLineSegment(shape:CSSLineSegment) -> Bool {

        if (self.vertical && shape.vertical) {
            return CSSShape.epsilon(self.firstPoint.x, val2: self.secondPoint.x)
        }//both are vertical

        else if (self.vertical) {

            if let yValue = shape.yForX(firstPoint.x) {

                return CSSShape.inBetween(lower: firstPoint.y, higher: secondPoint.y, value: yValue)

            } else {

                return false

            }

        }//self is vertical

        else if (shape.vertical) {

            if let yValue = self.yForX(shape.firstPoint.x) {

                return CSSShape.inBetween(lower: shape.firstPoint.y, higher: shape.secondPoint.y, value: yValue)

            } else {

                return false

            }

        }//shape is vertical

            //Neither are vertical, both have valid slopes and yIntercepts
        else if (CSSShape.epsilon(self.slope!, val2: shape.slope!)) {
            //If lines are the same, then they have the same yIntercpet
            //Else, they do not and therefore do not collide
            return CSSShape.epsilon(self.yIntercept!, val2: shape.yIntercept!)
        }//parallel

        let collisionFrame = CGRectIntersection(self.frame, shape.frame)
        let xValue = (shape.yIntercept! - self.yIntercept!) / (self.slope! - shape.slope!)

        return CSSShape.inBetween(lower: CGRectGetMinX(collisionFrame), higher: CGRectGetMaxX(collisionFrame), value: xValue)
    }//collide line segment line segment

    public func collideLineSegmentWithRectangle(shape:CSSRectangle) -> Bool {

        for iii in 0..<shape.lines.count {

            if (collideLineSegmentWithLineSegment(shape.lines[iii])) {

                return true

            }//found collision

        }//loop through lines

        //If both points lie inside, then lines will not register collision
        //but checking inside rectangle will. If the second point lies inside
        //but the first point doesn't, then the lines will collide and
        //control will not reach here, having already returned 'true'

        return shape.pointLiesInside(firstPoint)

    }//collide line segment rectangle

    public func collideLineSegmentWithTriangle(shape:CSSTriangle) -> Bool {

        for iii in 0..<shape.lines.count {

            if (collideLineSegmentWithLineSegment(shape.lines[iii])) {

                return true

            }//found collision

        }//loop through lines

        //If both points lie inside, then lines will not register collision
        //but checking inside triangle will. If the second point lies inside
        //but the first point doesn't, then the lines will collide and
        //control will not reach here, having already returned 'true'

        return shape.pointLiesInside(firstPoint)

    }//collide line segment triangle

    public func collideLineSegmentWithCircle(shape:CSSCircle) -> Bool {

        if (self.vertical) {

            if (shape.pointLiesInside(firstPoint) || shape.pointLiesInside(secondPoint)) {

                return true

            }//one of the points lies inside circle, therefore they must touch (circles are filled)

            //If neither point lies inside, then a vertical line segment that collides
            //with a circle has a point above and below the circle, so I only need
            //to check one of either the positive or negative y-values for the x-value

            //Since frames are guarunteed to collide, I know
            //that the positiveY is guarunteed to exist
            if let positiveY = shape.positiveYForX(firstPoint.x) {

                return CSSShape.inBetween(lower: firstPoint.y, higher: secondPoint.y, value: positiveY)

            } else {
                return false
            }
        }//vertical

        if (shape.pointLiesInside(self.firstPoint)) {
            /*
            *  If the first point lies inside the circle,
            *  then the line touches and I return true.
            *  If the second point is inside but the
            *  first point isn't (and thus it doesn't
            *  return true here), then the line must
            *  cross the circle, which means I don't
            *  have to check the other point.
            */
            return true
        }

        //Not vertical, 'slope' and 'yIntercept' are guarunteed to exist

        let h = shape.center.x
        let k = shape.center.y
        let r = shape.radius
        let m = self.slope!
        let y = self.yIntercept!
        let f = y - k

        let a = 1.0 + m * m
        let b = 2.0 * (m * f - h)
        let c = f * f + h * h - r * r

        let radical = b * b - 4 * a * c
        //a > 0 guarunteed because it equals 1 + (a square)
        //and a square is always positive
        if (radical < 0.0) {
            return false
        }

        let positiveX = (-b + sqrt(radical)) / (2.0 * a)
        let negativeX = (-b - sqrt(radical)) / (2.0 * a)

        return CSSShape.inBetween(lower: self.firstPoint.x, higher: self.secondPoint.x, value: positiveX)
            || CSSShape.inBetween(lower: self.firstPoint.x, higher: self.secondPoint.x, value: negativeX)

    }//collide line segment circle

}//collision detection
