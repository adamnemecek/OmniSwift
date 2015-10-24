//
//  UIButton+Creation.swift
//  Better Breeding
//
//  Created by Cooper Knaak on 12/6/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

import UIKit


public extension UIButton {
    
    public class func buttonWithFrame(frame:CGRect, title:String) -> UIButton {
        
        let but = UIButton(type: UIButtonType.System)
        
        but.setTitle(title, forState: UIControlState.Normal)
        but.frame = frame
        
        return but
        
    }//create button
    
    public class func buttonWithUnpressed(unpressed:UIImage, pressed:UIImage?, color:UIColor?, text:String?, textColor:UIColor?, font:UIFont?) -> UIButton {
        
        var unpresIm = unpressed
        var presIm = pressed
        
        if let color = color {
            
            unpresIm = unpresIm.addColor(color)
            presIm = presIm?.addColor(color)
            
        }//valid color
        
        if let text = text {
            if let textColor = textColor {
                if let font = font {
                    
                    let aStr = NSAttributedString(string: text, attributes: [NSFontAttributeName:font, NSForegroundColorAttributeName:textColor])
                    
                    unpresIm = unpresIm.addText(aStr)
                    presIm = presIm?.addText(aStr)
                }
            }
        }
        
        let createdButton = UIButton(type: UIButtonType.Custom)
        
        createdButton.frame = CGRect(origin: CGPoint.zero, size: unpresIm.size)
        createdButton.setImage(unpresIm, forState: UIControlState.Normal)
        
        if let presIm = presIm {
            createdButton.setImage(presIm, forState: UIControlState.Highlighted)
        }//valid pressed image
        
        
        return createdButton
    }//create button
    
    public class func roundedButtonWithSize(size:CGSize, title:String?, color:UIColor?, textColor:UIColor?, font:UIFont?) -> UIButton {
        
        let unpres = UIImage.imageWithPDFFile("RoundedRect-Unpressed", size: size)!
        let pres = UIImage.imageWithPDFFile("RoundedRect-Pressed", size: size)!
        
        let createdButton = UIButton.buttonWithUnpressed(unpres, pressed: pres, color: color, text: title, textColor: textColor, font: font)
        
        var disabledImage = UIImage.imageWithPDFFile("RoundedRect-Disabled", size: size)!
        disabledImage = disabledImage.addColor(UIColor.grayColor())
        createdButton.setImage(disabledImage, forState: UIControlState.Disabled)
        
        return createdButton
    }//button using rounded rect images
    
}//UIButton
