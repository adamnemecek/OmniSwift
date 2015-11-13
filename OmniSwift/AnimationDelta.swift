//
//  AnimationDelta.swift
//  Gravity
//
//  Created by Cooper Knaak on 5/1/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import UIKit

public protocol AnimationDeltaProtocol: Interpolatable {
//    func *(CGFloat, Self) -> Self
//    func +(Self, Self) -> Self
    func -(_: Self, _: Self) -> Self
}

public func *(lhs:CGFloat, rhs:Int) -> Int { return Int(lhs * CGFloat(rhs)) }
public func *(lhs:CGFloat, rhs:Float) -> Float { return Float(lhs) * rhs }
public func *(lhs:CGFloat, rhs:Double) -> Double { return Double(lhs) * rhs }
extension Int:          AnimationDeltaProtocol {}
extension Float:        AnimationDeltaProtocol {}
extension Double:       AnimationDeltaProtocol {}
extension CGFloat:      AnimationDeltaProtocol {}
extension CGPoint:      AnimationDeltaProtocol {}
extension SCVector3:    AnimationDeltaProtocol {}
extension SCVector4:    AnimationDeltaProtocol {}

public class AnimationDelta<T: AnimationDeltaProtocol> {
    
    public let initialValue:T
    public let deltaValue:T
    
    public init(start:T, delta:T) {
        
        self.initialValue = start
        self.deltaValue = delta
        
    }//initialize
    
    public convenience init(start:T, end:T) {
        
        self.init(start: start, delta: end - start)
        
    }//initialize
    
    public convenience init(delta:T, end:T) {
        
        self.init(start: end - delta, delta: delta)
        
    }//initialize
    
    public func valueForTime(time:CGFloat) -> T {
        return self.initialValue + time * self.deltaValue
    }
    
    public subscript(time:CGFloat) -> T {
        return self.valueForTime(time)
    }
    
}