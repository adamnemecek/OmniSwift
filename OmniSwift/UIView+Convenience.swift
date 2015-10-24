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
}