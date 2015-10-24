//
//  ViewList.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 6/28/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import UIKit

public protocol HasFrame {
    var frame:CGRect { get set }
}

extension UIView: HasFrame {}

public class ViewList: NSObject {
    
    // MARK: - Types
    
    public enum Flag: CustomStringConvertible {
        case None
        case ShouldReturn
        case ExtraSpace(CGFloat)
        
        public var description:String {
            switch self {
            case .None:
                return "ViewList.Flag.None"
            case .ShouldReturn:
                return "ViewList.Flag.ShouldReturn"
            case let .ExtraSpace(space):
                return "ViewList.Flag.ExtraSpace(\(space))"
            }
        }
    }
    
    // MARK: - Properties
    
    public var views:[HasFrame]
    public let buffer:CGFloat
    
    public let flags:[Flag]
    
    // MARK: - Setup
    
    public init(views:[HasFrame], flags:[Flag], buffer:CGFloat) {
        
        self.views  = views
        self.buffer = buffer
        
        var addedFlags = flags
        while addedFlags.count < views.count {
            addedFlags.append(.None)
        }
        self.flags = addedFlags
        
        super.init()
        
    }
    
    public convenience init(views:[HasFrame], buffer:CGFloat) {
        self.init(views: views, flags: [], buffer: buffer)
    }
    
    // MARK: - Logic
    
    private func incrementAt(rect:CGRect, inout maxX:CGFloat, inout maxY:CGFloat, minY:CGFloat) -> CGRect {
        var frame = rect
        frame.topLeft = CGPoint(x: maxX, y: minY)
        maxX += frame.width + self.buffer
        maxY = max(maxY, frame.maxY)
        
        return frame
    }
    
    public func framesInRect(rect:CGRect) -> [CGRect] {
        
        var maxX = self.buffer + rect.minX
        var minY = self.buffer + rect.minY
        var maxY:CGFloat = rect.minY
        
        var frames:[CGRect] = []
        for iii in 0..<self.views.count {
            
            var frame = self.views[iii].frame
            frame = self.incrementAt(frame, maxX: &maxX, maxY: &maxY, minY: minY)
            
            if maxX > rect.maxX {
                maxX = self.buffer + rect.minX
                minY = maxY + self.buffer
                
                frame = self.incrementAt(frame, maxX: &maxX, maxY: &maxY, minY: minY)
            }/* else if self.flags[iii] == .ShouldReturn {
                maxX = self.buffer + rect.minX
                minY = maxY + self.buffer
            }*/ else {
                switch self.flags[iii] {
                case .ShouldReturn:
                    maxX = self.buffer + rect.minX
                    minY = maxY + self.buffer
                case let .ExtraSpace(extraSpace):
                    maxX += extraSpace
                default:
                    break
                }
            }
            
            frames.append(frame)
        }
        
        return frames
    }
    
    public func frameInRect(rect:CGRect) -> CGRect {
        
        if self.views.count <= 0 {
            return CGRect.null
        }
        
        let frames = self.framesInRect(rect)
        var minX = frames[0].minX
        var maxX = frames[0].maxX
        var minY = frames[0].minY
        var maxY = frames[0].maxY
        
        for iii in 1..<frames.count {
            minX = min(minX, frames[iii].minX)
            maxX = max(maxX, frames[iii].maxX)
            minY = min(minY, frames[iii].minY)
            maxY = max(maxY, frames[iii].maxY)
        }
        
        minX -= self.buffer
        minY -= self.buffer
        maxX += self.buffer
        maxY += self.buffer
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    /*
    private func incrementAt(iii:Int, inout maxX:CGFloat, inout maxY:CGFloat, minY:CGFloat) {
        var frame = self.views[iii].frame
        frame.topLeft = CGPoint(x: maxX, y: minY)
        maxX += frame.width + self.buffer
        maxY = max(maxY, frame.maxY)
        
        self.views[iii].frame = frame
    }
    */
    public func layoutViewsInRect(rect:CGRect) {

        let frames = self.framesInRect(rect)
        for (index, frame) in frames.enumerate() {
            self.views[index].frame = frame
        }
        
    }
    
    public func centerVerticallyInRect(rect:CGRect) {
        
        if self.views.count <= 0 {
            return
        }
        
//        let minX = rect.minX + self.buffer
//        let width = rect.width - self.buffer * 2.0
        
        let frames = self.framesInRect(rect)
        
        var indices:[[Int]] = []
        var currentArray:[Int] = []
        var lastMinY = frames.first!.minY
        for (iii, frame) in frames.enumerate() {
            if frame.minY ~= lastMinY {
                currentArray.append(iii)
            } else {
                indices.append(currentArray)
                currentArray = [iii]
                lastMinY = frame.minY
            }
        }
        if currentArray.count > 0 {
            indices.append(currentArray)
        }
        
        for array in indices {
            let minX = frames[array.first!].minX
            let maxX = frames[array.last! ].maxX
            let w = maxX - minX
            
            for index in array {
                let frame = frames[index]
                let percent = (frame.midX - minX) / w - 0.5
                let center = CGPoint(x: percent * w + rect.midX, y: frame.midY)
                self.views[index].frame = CGRect(center: center, size: frame.size)
            }
            
        }
        
    }
    
    
    public class func emptyFlags(count:Int) -> [Flag] {
        return [Flag](count: count, repeatedValue: .None)
    }
    
}

extension ViewList {
    
    // MARK: - Class Methods
    
    public class func frameAroundFrames(frames:[HasFrame]) -> CGRect {
        
        if frames.count <= 0 {
            return CGRect.zero
        }
        
        var minX = frames[0].frame.minX
        var minY = frames[0].frame.minY
        var maxX = frames[0].frame.maxX
        var maxY = frames[0].frame.maxY
        
        for iii in 1..<frames.count {
            minX = min(minX, frames[iii].frame.minX)
            minY = min(minY, frames[iii].frame.minY)
            maxX = min(maxX, frames[iii].frame.maxX)
            maxY = min(maxY, frames[iii].frame.maxY)
        }
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}