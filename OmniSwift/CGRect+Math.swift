//
//  CGRect+Math.swift
//  InverseKinematicsTest
//
//  Created by Cooper Knaak on 10/23/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

import UIKit


// MARK: - Initializers

public extension CGRect {

    public init(size:CGSize) {
        self.init(origin: CGPoint.zero, size: size)
    }

    public init(width:CGFloat, height:CGFloat, centered:Bool = false) {
        let x = (centered ? -width / 2.0 : 0.0)
        let y = (centered ? -height / 2.0 : 0.0)
        self.init(x: x, y: y, width: width, height: height)
    }

    public init(square:CGFloat) {
        self.init(origin: CGPoint.zero, size: CGSize(square: square))
    }

    public init(center:CGPoint, size:CGSize) {
        self.init(x: center.x - size.width / 2.0, y: center.y - size.height / 2.0, width: size.width, height: size.height)
    }//initialize

    ///Creates a rect containing all points.
    public init(points:[CGPoint]) {
        if let p1 = points.first {
            var minX = p1.x
            var maxX = p1.x
            var minY = p1.y
            var maxY = p1.y
            for point in points {
                if minX > point.x {
                    minX = point.x
                } else if maxX < point.x {
                    maxX = point.x
                }
                if minY > point.y {
                    minY = point.y
                } else if maxY < point.y {
                    maxY = point.y
                }
            }

            self = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        } else {
            self = CGRect.zero
        }
    }
    ///Creates a rect containing all rects.
    public init(rects:[CGRect]) {
        if let r1 = rects.first {
            var minX = r1.minX
            var maxX = r1.maxX
            var minY = r1.minY
            var maxY = r1.maxY
            for rect in rects {
                if minX > rect.minX {
                    minX = rect.minX
                } else if maxX < rect.maxX {
                    maxX = rect.maxX
                }
                if minY > rect.minY {
                    minY = rect.minY
                } else if maxY < rect.maxY {
                    maxY = rect.maxY
                }
            }

            self = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        } else {
            self = CGRect.zero
        }
    }

}//initializers

// MARK: - Custom Getters
public extension CGRect {

    public var center:CGPoint {
        get {
            return CGPoint(x: CGRectGetMidX(self), y: CGRectGetMidY(self))
        }
        set {
            self = CGRect(center: newValue, size: self.size)
        }
    }//get center

    // MARK: - Corners

    public var topLeft:CGPoint {
        get {
//            return CGPoint(x: CGRectGetMinX(self), y: CGRectGetMaxY(self))
            return CGPoint(x: CGRectGetMinX(self), y: CGRectGetMinY(self))
        }
        set {
            // I originally had the topLeft & bottomLeft setters
            // switched. There are correct now, but only for UI.
            // If I want to use them in OpenGL, they will need
            // to be switched back.
            self = CGRect(origin: newValue, size: self.size)
        }
    }

    public var bottomLeft:CGPoint {
        get {
            return CGPoint(x: CGRectGetMinX(self), y: CGRectGetMaxY(self))
        }
        set {
            self = CGRect(x: newValue.x, y: newValue.y - self.size.height, width: self.size.width, height: self.size.height)
        }
    }

    public var topRight:CGPoint {
        get {
            return CGPoint(x: CGRectGetMaxX(self), y: CGRectGetMinY(self))
        }
        set {
            self = CGRect(x: newValue.x - self.size.width, y: newValue.y, width: self.size.width, height: self.size.height)
        }
    }

    public var bottomRight:CGPoint {
        get {
            return CGPoint(x: CGRectGetMaxX(self), y: CGRectGetMaxY(self))
        }
        set {
            self = CGRect(x: newValue.x - self.size.width, y: newValue.y - self.size.height, width: self.size.width, height: self.size.height)
        }
    }

    // MARK: - Middles

    public var leftMiddle:CGPoint {
        get {
            return CGPoint(x: CGRectGetMinX(self), y: CGRectGetMidY(self))
        }
        set {
            self = CGRect(x: newValue.x, y: newValue.y - self.size.height / 2.0, width: self.size.width, height: self.size.height)
        }
    }

    public var rightMiddle:CGPoint {
        get {
            return CGPoint(x: CGRectGetMaxX(self), y: CGRectGetMidY(self))
        }
        set {
            self = CGRect(x: newValue.x - self.size.width, y: newValue.y - self.size.height / 2.0, width: self.size.width, height: self.size.height)
        }
    }

    public var topMiddle:CGPoint {
        get {
            return CGPoint(x: CGRectGetMidX(self), y: CGRectGetMinY(self))
        }
        set {
            self = CGRect(x: newValue.x - self.size.width / 2.0, y: newValue.y, width: self.size.width, height: self.size.height)
        }
    }

    public var bottomMiddle:CGPoint {
        get {
            return CGPoint(x: CGRectGetMidX(self), y: CGRectGetMaxY(self))
        }
        set {
            self = CGRect(x: newValue.x - self.size.width / 2.0, y: newValue.y - self.size.height, width: self.size.width, height: self.size.height)
        }
    }


    public subscript(vertex:TexturedQuad.VertexName) -> CGPoint {
        get {
            switch vertex {
            case .BottomLeft:
                return self.bottomLeft
            case .BottomRight:
                return self.bottomRight
            case .TopLeft:
                return self.topLeft
            case .TopRight:
                return self.topRight
            }
        }
        set {
            switch vertex {
            case .BottomLeft:
                self.bottomLeft     = newValue

            case .BottomRight:
                self.bottomRight    = newValue

            case .TopLeft:
                self.topLeft        = newValue

            case .TopRight:
                self.topRight       = newValue
            }
        }
    }

    ///Returns a random point in or on the rectangle.
    public func randomPoint() -> CGPoint {
        let xPercent = GLSParticleEmitter.randomFloat()
        let yPercent = GLSParticleEmitter.randomFloat()
        return self.origin + CGPoint(x: xPercent, y: yPercent) * self.size
    }

    ///Returns the value from *NSStringFromCGRect*.
    public func getString() -> String {
        return NSStringFromCGRect(self)
    }

}//CGRect

// MARK: - Overridden Setters
//Overriden methods
//I added setters
public extension CGRect {

    public mutating func setSizeCentered(size:CGSize) {
        self = CGRect(center: self.center, size: size)
    }

    public mutating func setSizeCenteredWidth(width:CGFloat, height:CGFloat) {
        self = CGRect(center: self.center, size: CGSize(width: width, height: height))
    }

    public mutating func setWidthCentered(width:CGFloat) {
        self = CGRect(center: self.center, size: CGSize(width: width, height: self.size.height))
    }

    public mutating func setHeightCentered(height:CGFloat) {
        self = CGRect(center: self.center, size: CGSize(width: self.size.width, height: height))
    }


    public mutating func setMinX(newValue:CGFloat) {
        self = CGRect(x: newValue, y: self.minY, width: self.width, height: self.height)
    }

    public mutating func setMinY(newValue:CGFloat) {
        self = CGRect(x: self.minX, y: newValue, width: self.width, height: self.height)
    }

    public mutating func setMaxX(newValue:CGFloat) {
        self = CGRect(x: newValue - self.width, y: self.minY, width: self.width, height: self.height)
    }

    public mutating func setMaxY(newValue:CGFloat) {
        self = CGRect(x: self.minX, y: newValue - self.height, width: self.width, height: self.height)
    }

}

extension CGRect {

    // MARK: - Custom GL Getters

    public var topLeftGL:CGPoint {
        get {
            return CGPoint(x: CGRectGetMinX(self), y: CGRectGetMaxY(self))
        }
        set {
            // I originally had the topLeft & bottomLeft setters
            // switched. There are correct now, but only for UI.
            // If I want to use them in OpenGL, they will need
            // to be switched back.
            self = CGRect(x: newValue.x, y: newValue.y - self.size.height, width: self.size.width, height: self.size.height)
        }
    }

    public var bottomLeftGL:CGPoint {
        get {
            return CGPoint(x: CGRectGetMinX(self), y: CGRectGetMinY(self))
        }
        set {
            self = CGRect(origin: newValue, size: self.size)
        }
    }

    public var topRightGL:CGPoint {
        get {
            return CGPoint(x: CGRectGetMaxX(self), y: CGRectGetMaxY(self))
        }
        set {
            self = CGRect(x: newValue.x - self.size.width, y: newValue.y - self.size.height, width: self.size.width, height: self.size.height)
        }
    }

    public var bottomRightGL:CGPoint {
        get {
            return CGPoint(x: CGRectGetMaxX(self), y: CGRectGetMinY(self))
        }
        set {
            self = CGRect(x: newValue.x - self.size.width, y: newValue.y, width: self.size.width, height: self.size.height)
        }
    }
}

public extension CGRect {

    // MARK: - Convenience

    /**
    Divides self into 4 different rects which all meet at *point*.

    - parameter point: The point where the divisions meet.
    - returns: An array of CGRect values. (OpenGL Coordinates)
    [0]: Top Left
    [1]: Bottom Left
    [2]: Top Right
    [3]: Bottom Right
    */
    public func divideAt(point:CGPoint) -> [CGRect] {

        let topLeft = CGRect(x: self.topLeftGL.x, y: point.y, width: point.x - self.topLeftGL.x, height: self.topLeftGL.y - point.y)
        let bottomLeft = CGRect(x: self.bottomLeftGL.x, y: self.bottomLeftGL.y, width: point.x - self.bottomLeftGL.x, height: point.y - self.bottomLeftGL.y)
        let bottomRight = CGRect(x: point.x, y: self.bottomRightGL.y, width: self.bottomRightGL.x - point.x, height: point.y - self.bottomRightGL.y)
        let topRight = CGRect(x: point.x, y: point.y, width: self.topRightGL.x - point.x, height: self.topRightGL.y - point.y)

        return [topLeft, bottomLeft, topRight, bottomRight]
    }

    /**
    Divides self into 4 different rects which all meet *percent* of the way through self.

    - parameter percent: The percent, in range [0.0, 1.0].
    - returns: An array of CGRect values that meet at the given percent.
    */
    public func divideAtPercent(percent:CGPoint) -> [CGRect] {
        return self.divideAt(self.origin + percent * self.size)
    }

    /**
     Linearly interpolates between the corner of the rectangle.
     - parameters point: A point with x and y coordinates ranging between [0.0, 1.0]
     corresponding to the percentage across the rectangle.
     - returns: The interpolated point inside the rectangle
     */
    public func interpolate(point:CGPoint) -> CGPoint {
        return CGPoint(x: linearlyInterpolate(point.x, left: self.minX, right: self.maxX), y: linearlyInterpolate(point.y, left: self.minY, right: self.maxY))
    }
}

// MARK: - Operators

public func +(lhs:CGRect, rhs:CGRect) -> CGRect {
    return CGRect(origin: lhs.origin + rhs.origin, size: lhs.size + rhs.size)
}

public func -(lhs:CGRect, rhs:CGRect) -> CGRect {
    return CGRect(origin: lhs.origin - rhs.origin, size: lhs.size - rhs.size)
}

public func *(lhs:CGRect, rhs:CGRect) -> CGRect {
    return CGRect(origin: lhs.origin * rhs.origin, size: lhs.size * rhs.size)
}

public func /(lhs:CGRect, rhs:CGRect) -> CGRect {
    return CGRect(origin: lhs.origin / rhs.origin, size: lhs.size / rhs.size)
}

public func +=(inout lhs:CGRect, rhs:CGRect) {
    lhs = CGRect(origin: lhs.origin + rhs.origin, size: lhs.size + rhs.size)
}

public func -=(inout lhs:CGRect, rhs:CGRect) {
    lhs = CGRect(origin: lhs.origin - rhs.origin, size: lhs.size - rhs.size)
}

public func *=(inout lhs:CGRect, rhs:CGRect) {
    lhs = CGRect(origin: lhs.origin * rhs.origin, size: lhs.size * rhs.size)
}

public func /=(inout lhs:CGRect, rhs:CGRect) {
    lhs = CGRect(origin: lhs.origin / rhs.origin, size: lhs.size / rhs.size)
}

// MARK: - Operators (CGFloat)

public func +(lhs:CGRect, rhs:CGFloat) -> CGRect {
    return CGRect(origin: lhs.origin + rhs, size: lhs.size + rhs)
}

public func -(lhs:CGRect, rhs:CGFloat) -> CGRect {
    return CGRect(origin: lhs.origin - rhs, size: lhs.size - rhs)
}

public func *(lhs:CGRect, rhs:CGFloat) -> CGRect {
    return CGRect(origin: lhs.origin * rhs, size: lhs.size * rhs)
}

public func /(lhs:CGRect, rhs:CGFloat) -> CGRect {
    return CGRect(origin: lhs.origin / rhs, size: lhs.size / rhs)
}

public func +(lhs:CGFloat, rhs:CGRect) -> CGRect {
    return CGRect(origin: lhs + rhs.origin, size: lhs + rhs.size)
}

public func -(lhs:CGFloat, rhs:CGRect) -> CGRect {
    return CGRect(origin: lhs - rhs.origin, size: lhs - rhs.size)
}

public func *(lhs:CGFloat, rhs:CGRect) -> CGRect {
    return CGRect(origin: lhs * rhs.origin, size: lhs * rhs.size)
}

public func /(lhs:CGFloat, rhs:CGRect) -> CGRect {
    return CGRect(origin: lhs / rhs.origin, size: lhs / rhs.size)
}

public func +=(inout lhs:CGRect, rhs:CGFloat) {
    lhs = CGRect(origin: lhs.origin + rhs, size: lhs.size + rhs)
}

public func -=(inout lhs:CGRect, rhs:CGFloat) {
    lhs = CGRect(origin: lhs.origin - rhs, size: lhs.size - rhs)
}

public func *=(inout lhs:CGRect, rhs:CGFloat) {
    lhs = CGRect(origin: lhs.origin * rhs, size: lhs.size * rhs)
}

public func /=(inout lhs:CGRect, rhs:CGFloat) {
    lhs = CGRect(origin: lhs.origin / rhs, size: lhs.size / rhs)
}

// MARK: - Operators (CGPoint)

public func +(lhs:CGRect, rhs:CGPoint) -> CGRect {
    return CGRect(origin: lhs.origin + rhs, size: lhs.size)
}

public func -(lhs:CGRect, rhs:CGPoint) -> CGRect {
    return CGRect(origin: lhs.origin - rhs, size: lhs.size)
}

public func *(lhs:CGRect, rhs:CGPoint) -> CGRect {
    return CGRect(origin: lhs.origin * rhs, size: lhs.size)
}

public func /(lhs:CGRect, rhs:CGPoint) -> CGRect {
    return CGRect(origin: lhs.origin / rhs, size: lhs.size)
}

public func +(lhs:CGPoint, rhs:CGRect) -> CGRect {
    return CGRect(origin: lhs + rhs.origin, size: rhs.size)
}

public func -(lhs:CGPoint, rhs:CGRect) -> CGRect {
    return CGRect(origin: lhs - rhs.origin, size: rhs.size)
}

public func *(lhs:CGPoint, rhs:CGRect) -> CGRect {
    return CGRect(origin: lhs * rhs.origin, size: rhs.size)
}

public func /(lhs:CGPoint, rhs:CGRect) -> CGRect {
    return CGRect(origin: lhs / rhs.origin, size: rhs.size)
}

public func +=(inout lhs:CGRect, rhs:CGPoint) {
    lhs = CGRect(origin: lhs.origin + rhs, size: lhs.size)
}

public func -=(inout lhs:CGRect, rhs:CGPoint) {
    lhs = CGRect(origin: lhs.origin - rhs, size: lhs.size)
}

public func *=(inout lhs:CGRect, rhs:CGPoint) {
    lhs = CGRect(origin: lhs.origin * rhs, size: lhs.size)
}

public func /=(inout lhs:CGRect, rhs:CGPoint) {
    lhs = CGRect(origin: lhs.origin / rhs, size: lhs.size)
}

// MARK: - Operators (CGSize)

public func +(lhs:CGRect, rhs:CGSize) -> CGRect {
    return CGRect(origin: lhs.origin, size: lhs.size + rhs)
}

public func -(lhs:CGRect, rhs:CGSize) -> CGRect {
    return CGRect(origin: lhs.origin, size: lhs.size - rhs)
}

public func *(lhs:CGRect, rhs:CGSize) -> CGRect {
    return CGRect(origin: lhs.origin, size: lhs.size * rhs)
}

public func /(lhs:CGRect, rhs:CGSize) -> CGRect {
    return CGRect(origin: lhs.origin, size: lhs.size / rhs)
}

public func +(lhs:CGSize, rhs:CGRect) -> CGRect {
    return CGRect(origin: rhs.origin, size: lhs + rhs.size)
}

public func -(lhs:CGSize, rhs:CGRect) -> CGRect {
    return CGRect(origin: rhs.origin, size: lhs - rhs.size)
}

public func *(lhs:CGSize, rhs:CGRect) -> CGRect {
    return CGRect(origin: rhs.origin, size: lhs * rhs.size)
}

public func /(lhs:CGSize, rhs:CGRect) -> CGRect {
    return CGRect(origin: rhs.origin, size: lhs / rhs.size)
}

public func +=(inout lhs:CGRect, rhs:CGSize) {
    lhs = CGRect(origin: lhs.origin, size: lhs.size + rhs)
}

public func -=(inout lhs:CGRect, rhs:CGSize) {
    lhs = CGRect(origin: lhs.origin, size: lhs.size - rhs)
}

public func *=(inout lhs:CGRect, rhs:CGSize) {
    lhs = CGRect(origin: lhs.origin, size: lhs.size * rhs)
}

public func /=(inout lhs:CGRect, rhs:CGSize) {
    lhs = CGRect(origin: lhs.origin, size: lhs.size / rhs)
}
