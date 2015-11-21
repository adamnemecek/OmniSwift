//
//  UIView+Convenience.swift
//  Gravity
//
//  Created by Cooper Knaak on 5/7/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import UIKit


public protocol ContainsViewsProtocol {
    var views:[UIView] { get }
}

extension ContainsViewsProtocol {
    
    public func removeFromSuperview() {
        for view in self.views {
            view.removeFromSuperview()
        }
    }
    
}

extension UIView {
    
    public func addSubview(object:ContainsViewsProtocol) {
        
        for view in object.views {
            self.addSubview(view)
        }
    }
    
    
    public class func animateEaseInOutWithDuration(duration:NSTimeInterval, animations:() -> Void) {
        
        UIView.animateWithDuration(duration, delay: 0.0, options: .CurveEaseInOut, animations: animations, completion: nil)
        
    }//convenience

    public class func animateEaseInOutWithDuration(duration:NSTimeInterval, animations:() -> Void, completion:() -> Void) {
        
        UIView.animateWithDuration(duration, delay: 0.0, options: .CurveEaseInOut, animations: animations) { finished in
            if finished {
                completion()
            }
        }
        
    }
    
    public func locationFromTouches(touches:NSSet) -> CGPoint {
        
        if (touches.count <= 0) {
            return CGPoint.zero
        }
        
        var location = CGPoint.zero
        
        touches.enumerateObjectsUsingBlock() {
            if let touch = $0.0 as? UITouch {
                location += touch.locationInView(self)
            }
        }
        
        return location / CGFloat(touches.count)
    }
    
    
    public func setRoundnessWithFactor(factor:CGFloat) {
        self.layer.cornerRadius = self.frame.size.minimum * factor
    }
    
    /**
     Positions views so there is an equal space between each of them horizontally. Centers them vertically.
     
     - parameter views: The views to equally space.
     - parameter rect: The rect to space and center the views in.
    */
    public class func spaceViewsEquallyHorizontally(views:[UIView], inRect rect:CGRect) {
        let totalWidth = views.reduce(0.0) { $0 + $1.frame.width }
        let buffer = (rect.width - totalWidth) / CGFloat(views.count + 1)
        var x = rect.minX + buffer
        for view in views {
            x += view.frame.width / 2.0
            view.center = CGPoint(x: x, y: rect.midY)
            x += view.frame.width / 2.0 + buffer
        }
    }
    
    public class func spaceViewsEquallyVertically(views:[UIView], inRect rect:CGRect) {
        let totalHeight = views.reduce(0.0) { $0 + $1.frame.height }
        let buffer = (rect.height - totalHeight) / CGFloat(views.count + 1)
        var y = rect.minY + buffer
        for view in views {
            view.center = CGPoint(x: rect.midX, y: y + view.frame.height / 2.0)
            y += view.frame.height + buffer
        }
    }
    
}