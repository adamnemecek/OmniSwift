//
//  CSSShape+RandomPointProtocol.swift
//  Gravity
//
//  Created by Cooper Knaak on 2/27/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import UIKit


//Conform to random point protocol to let
//'GLSParticleEmitter' use your class
//to spawn particles in random positions
public protocol RandomPointProtocol {
     func randomPoint() -> CGPoint
}

 extension CSSCircle: RandomPointProtocol {

    public func randomPoint() -> CGPoint {

        let randomAngle = GLSParticleEmitter.randomFloat(0.0, between: 2.0 * CGFloat(M_PI))
        let randomRadius = GLSParticleEmitter.randomFloat(0.0, between: self.radius)

        return self.center + CGPoint(angle: randomAngle, length: randomRadius)
    }

}//Random Point Protocol

extension CSSRectangle: RandomPointProtocol {

    public func randomPoint() -> CGPoint {

        let randomHorizontal = GLSParticleEmitter.randomFloat(0.0, withRange: self.size.width)
        let randomVertical = GLSParticleEmitter.randomFloat(0.0, withRange: self.size.height)

        return self.center + CGPoint(x: randomHorizontal, y: randomVertical)
    }//get a random point

}//Random Point Protocol

extension CSSLineSegment: RandomPointProtocol {

    public func randomPoint() -> CGPoint {

        let randomDistance = GLSParticleEmitter.randomFloat()

        return self.firstPoint + (self.secondPoint - self.firstPoint) * randomDistance
    }//random point

}//Random Point Protocol
