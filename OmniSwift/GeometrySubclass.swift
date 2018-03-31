//
//  GeometrySubclass.swift
//  Better Breeding
//
//  Created by Cooper Knaak on 12/6/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

import UIKit


public class GeometrySubclass: NSObject {

    public var frame:CGRect {

        get {
            return CGRectZero
        }//get

        set {

        }//set

    }//frame

    public var center:CGPoint {

        get {
            return CGPointZero
        }//get

        set {

        }//set

    }//center

    public var minX:CGFloat {
        get {
            return CGRectGetMinX(self.frame)
        }
        set {
            self.frame.setMinX(newValue)
        }
    }//minX

    public var midX:CGFloat {
        return CGRectGetMidX(self.frame)
    }//midX

    public var maxX:CGFloat {
        get {
            return CGRectGetMaxX(self.frame)
        }
        set {
            self.frame.setMaxX(newValue)
        }
    }//maxX

    public var minY:CGFloat {
        get {
            return CGRectGetMinY(self.frame)
        }
        set {
            self.frame.setMinY(newValue)
        }
    }//minY

    public var midY:CGFloat {
        return CGRectGetMidY(self.frame)
    }//midY

    public var maxY:CGFloat {
        get {
            return CGRectGetMaxY(self.frame)
        }
        set {
            self.frame.setMaxY(newValue)
        }
    }//maxY

    public var size:CGSize {
        return self.frame.size
    }//size

    public var width:CGFloat {
        return CGRectGetWidth(self.frame)
    }//width

    public var height:CGFloat {
        return CGRectGetHeight(self.frame)
    }//height
}
