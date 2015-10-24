//
//  CGRect+Enumeration.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 10/17/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

import Foundation

extension CGRect {
    
    public func enumerateInnerRectsWithSize(size:CGSize) -> [(x:Int, y:Int, rect:CGRect)] {
        var rects:[(x:Int, y:Int, rect:CGRect)] = []
        
        let xIter = Int(self.size.width / size.width)
        let yIter = Int(self.size.height / size.height)
        
        for j in 0..<yIter {
            for i in 0..<xIter {
                let origin = self.origin + (size * CGSize(width: i, height: j)).getCGPoint()
                rects.append((x: i, y: j, rect: CGRect(origin: origin, size: size)))
            }
        }
        
        return rects
    }
    
}