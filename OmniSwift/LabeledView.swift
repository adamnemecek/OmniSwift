//
//  LabeledView.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 7/12/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import UIKit

public class LabeledView: NSObject, HasFrame, ContainsViewsProtocol {

    // MARK: - Properties
    
    public let label:UILabel
    public let title:String
    public private(set) var view:HasFrame
    
    ///How much extra space is placed between *label* and *view*.
    public var buffer:CGFloat = 0.0 {
        didSet {
            self.pinViews()
        }
    }
    
    ///A boolean value determining whether the label aligned horizontally or vertically.
    public var horizontal = true {
        didSet {
            self.pinViews()
        }
    }
    
    public var frame:CGRect {
        get {
            if self.horizontal {
                let minX = self.label.frame.minX
                let maxX = self.view.frame.maxX
                let minY = min(self.label.frame.minY, self.view.frame.minY)
                let maxY = max(self.label.frame.maxY, self.view.frame.maxY)
                return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
            } else {
                let minX = min(self.label.frame.minX, self.view.frame.minX)
                let maxX = max(self.label.frame.maxX, self.view.frame.maxX)
                let minY = self.label.frame.minY
                let maxY = self.view.frame.maxY
                return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
            }
        }
        set {
            if self.horizontal {
                
                self.label.frame.leftMiddle = CGPoint(x: newValue.minX, y: newValue.midY)
                let vx = self.label.frame.maxX + self.buffer
                let vw = newValue.maxX - vx
                self.view.frame = CGRect(x: vx, y: newValue.minY, width: vw, height: newValue.height)
                
            } else {
                self.label.frame.topMiddle = CGPoint(x: newValue.midX, y: newValue.minY)
                let vy = self.label.frame.maxY + self.buffer
                let vh = newValue.maxY - vy
                self.view.frame = CGRect(x: newValue.minX, y: vy, width: newValue.width, height: vh)
            }
        }
    }
    
    public var views:[UIView] {
        if let view = self.view as? UIView {
            return [self.label, view]
        } else {
            return [self.label]
        }
    }
    
    ///Accessor for label's text color.
    public var textColor:UIColor? {
        get {
            return self.label.textColor
        }
        set {
            self.label.textColor = newValue
        }
    }
    ///Accessor for label's font.
    public var font:UIFont? {
        get {
            return self.label.font
        }
        set {
            self.label.font = newValue
            if let font = newValue {
                self.label.changeFrameForFont(font)
                self.pinViews()
            }
        }
    }
    
    // MARK: - Setup
    
    public init(title:String, view:HasFrame) {
        self.title  = title
        self.label  = UILabel.labelWithText(title)
        self.view   = view
        
        super.init()
        
        self.pinViews()
    }
    
    // MARK: - Logic
    
    ///Pins *view* to correct side of *label* according to *horizontal*.
    public func pinViews() {
        
        if self.horizontal {
            self.view.frame.leftMiddle = self.label.frame.rightMiddle + CGPoint(x: self.buffer)
        } else {
            self.view.frame.topMiddle = self.label.frame.bottomMiddle + CGPoint(y: self.buffer)
        }
        
    }
    
}
