//
//  CGFloat+Convenience.swift
//  MatTest
//
//  Created by Cooper Knaak on 2/8/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import Foundation
import UIKit

infix operator ~= { precedence 130 }
public func ~=(left:CGFloat, right:CGFloat) -> Bool {
    
    let epsilon:CGFloat = 0.001
    
    return abs(left - right) <= epsilon
}//about equals operator

//Optionally Assign Operator:
//If value to assign is nil,
//then no assignment happens.
//If the value exists, then
//the value is assigned
infix operator ??= { associativity right precedence 90 }
public func ??=<T>(inout lhs:T, rhs:T?) {
    if let rhs = rhs {
        lhs = rhs
    }
}
/*
infix operator !~= { precedence 130 }
func !~=<T: ApproximatelyEquatable_CC>(left:T, right:T) -> Bool {
return (left ~= right)
}
*/

extension CGFloat {
    
    public mutating func decrementTowardsZeroBy(decrementValue:CGFloat) {
        
        if (self > 0.0) {
            self -= decrementValue
        } else {
            self += decrementValue
        }
        
        if (abs(self) <= decrementValue / 2.0) {
            self = 0.0
        }
    }//decrement towards zero by
    
    public func nearestTo(values:(CGFloat, CGFloat)) -> CGFloat {
        
        if (abs(self - values.0) < abs(self - values.1)) {
            return values.0
        } else {
            return values.1
        }
        
    }//get value that is nearest to this value
    
}//CGFloat