//
//  ButtonSwitch.swift
//  Gravity
//
//  Created by Cooper Knaak on 6/14/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import UIKit
//

protocol ButtonSwitchObserver {
    
    func buttonSwitch(buttonSwitch:ButtonSwitch, changedValueTo value:Bool)
    
}

///Functions like a UISwitch, looks like a UIButton / UIImageView.
public class ButtonSwitch: UIControl {

    // MARK: - Types
    
    public typealias ValueChangedBlock = (ButtonSwitch) -> ()
    
    // MARK: - Properties
    
    ///Whether the switch is in the on state.
    public var on:Bool = true {
        didSet {
            if self.on != oldValue {
                self.setNeedsDisplay()
                
                for (_, block) in self.valueChangedBlocks {
                    block(self)
                }
                
                self.sendActionsForControlEvents(.ValueChanged)
            }
        }
    }
    
    ///The image to use when in the on state.
    public var onImage:UIImage?  = nil {
        didSet {
            self.onMask = self.onImage?.CGImage
        }
    }
    ///The image to use when in the off state.
    public var offImage:UIImage? = nil {
        didSet {
            self.offMask = self.offImage?.CGImage
        }
    }
    
    private var onMask:CGImageRef?  = nil
    private var offMask:CGImageRef? = nil
    
    ///The text to use when in the on state. You are required to insert newline characters.
    public var onText  = "On"
    ///The text to use when in the off state. You are required to insert newline characters.
    public var offText = "Off"
    ///The color of the text when in the on state.
    public var onTextColor  = UIColor.blackColor() {
        didSet {
            self.onTextDictionary[NSForegroundColorAttributeName] = self.onTextColor
        }
    }
    ///The color of the text when in the off state.
    public var offTextColor = UIColor.blackColor() {
        didSet {
            self.offTextDictionary[NSForegroundColorAttributeName] = self.offTextColor
        }
    }
    ///Accesses both *onTextColor* and *offTextColor*. Getting the value
    ///causes both values to be set to the same value.
    public var textColor:UIColor {
        get {
            self.offTextColor = self.onTextColor
            return self.onTextColor
        }
        set {
            self.onTextColor  = newValue
            self.offTextColor = newValue
        }
    }
    ///The color of the text when in the off state.
    public var font:UIFont? = nil {
        didSet {
            self.onTextDictionary[NSFontAttributeName]  = self.font
            self.offTextDictionary[NSFontAttributeName] = self.font
        }
    }
    
    private var onTextDictionary:[String:AnyObject]  = [NSForegroundColorAttributeName:UIColor.blackColor()]
    private var offTextDictionary:[String:AnyObject] = [NSForegroundColorAttributeName:UIColor.blackColor()]
    
    private var valueChangedBlocks:[String:ValueChangedBlock] = [:]
    // MARK: - Setup
    
    /**
    Initializes a *ButtonSwitch* object.
    
    - parameter frame: The frame of the button.
    - parameter onImage: The image to use in the on state.
    - parameter offImage: The image to use in the off state.
    - returns: An initialized *ButtonSwitch* object.
    */
    public init(frame:CGRect, onImage:UIImage?, offImage:UIImage?) {
        
        self.onImage    = onImage
        self.offImage   = offImage
        self.onMask     = onImage?.CGImage
        self.offMask    = offImage?.CGImage
        
        let pStyle = NSMutableParagraphStyle()
        pStyle.alignment = NSTextAlignment.Center
        pStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.onTextDictionary[NSParagraphStyleAttributeName]  = pStyle
        self.offTextDictionary[NSParagraphStyleAttributeName] = pStyle
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        
        self.addTarget(self, action: "didTouchDownInside:", forControlEvents: .TouchDown)
        self.addTarget(self, action: "didTouchUpInside:",   forControlEvents: .TouchUpInside)
        self.addTarget(self, action: "didTouchUpInside:",   forControlEvents: .TouchCancel)
        self.addTarget(self, action: "didTouchUpOutside:",  forControlEvents: .TouchUpOutside)
    }

    /**
    Initializes a *ButtonSwitch* object. Gets the frame from either
    *onImage* or *offImage*. If both are *nil*, then sets frame to 0.
    
    - parameter onImage: The image to use in the on state.
    - parameter offImage: The image to use in the off state.
    - returns: An initialized *ButtonSwitch* object.
    */
    public convenience init(onImage:UIImage?, offImage:UIImage?) {
        
        let rect:CGRect
        if let onIm = onImage {
            rect = CGRect(size: onIm.size)
        } else if let offIm = offImage {
            rect = CGRect(size: offIm.size)
        } else {
            rect = CGRect(square: 1.0)
        }
        
        self.init(frame: rect, onImage: onImage, offImage: offImage)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        self.onImage ??= aDecoder.decodeObjectOfClass(UIImage.self, forKey: "On Image")
        fatalError("ButtonSwitch::init(coder:) not implemented!")
        
    }
    
    // MARK: - Logic
    
    public override func drawRect(rect: CGRect) {

        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        
        if let onImage = self.onImage where self.on {

            onImage.drawInRect(rect)
            
            let aText = NSAttributedString(string: self.onText, attributes: self.onTextDictionary)
            let aSize = aText.size()
            let hDiff = rect.size.height - aSize.height
            let aRect = CGRect(x: rect.origin.x, y: rect.origin.y + hDiff / 2.0, width: rect.size.width, height: aSize.height)
            aText.drawInRect(aRect)
            
        } else if let offImage = self.offImage where !self.on {
            
            offImage.drawInRect(rect)
            
            let aText = NSAttributedString(string: self.offText, attributes: self.offTextDictionary)
            let aSize = aText.size()
            let offset = aSize.center
            aText.drawAtPoint(rect.center - offset)
        }
        
        if let mask = (self.on ? self.onMask : self.offMask) where self.highlighted {
            CGContextClipToMask(context, rect, mask)
            CGContextSetFillColorWithColor(context, UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5).CGColor)
            CGContextFillRect(context, rect)
        }
        
        CGContextRestoreGState(context)
    }//draw rect
    
    // MARK: - Touches
    
    public func didTouchDownInside(sender:ButtonSwitch) {
        self.highlighted = true
        self.setNeedsDisplay()
    }
    
    public func didTouchUpInside(sender:AnyObject?) {
        self.on = !self.on
        self.highlighted = false
    }
    
    public func didTouchUpOutside(sender:AnyObject?) {
        self.highlighted = false
        self.setNeedsDisplay()
    }
    
    // MARK: - Observers
    
    /**
    Adds a block that is invoked when the value of *on* is changed.
    
    - parameter key: The key to associate the block with. If a block already exists with a given key, it is replaced.
    - parameter block: The block to invoke when the value changes.
    */
    public func addKey(key:String, block:ValueChangedBlock) {
        self.valueChangedBlocks[key] = block
    }
    
    /**
    Removes a ValueChangedBlock associated with a given key.
    
    - parameter key: The key associated with the block to remove.
    - returns: *true* if the block was successfully removed, *false* if it didn't exist in the first place.
    */
    public func removeBlockForKey(key:String) -> Bool {
        if  self.valueChangedBlocks[key] != nil {
            self.valueChangedBlocks[key] = nil
            return true
        } else {
            return false
        }
    }
}
