//
//  AutoOrientingImageView.swift
//  Gravity
//
//  Created by Cooper Knaak on 3/28/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import UIKit


public class AutoOrientingImageView: UIImageView {

    public var portraitImage:UIImage? = nil
    public var landscapeImage:UIImage? = nil

    override public var frame:CGRect {
        didSet {
            if (self.frame.size.width < self.frame.size.height) {
                self.image = self.portraitImage
            } else {
                self.image = self.landscapeImage
            }
        }
    }

    public init(portrait:UIImage, landscape:UIImage) {

        self.portraitImage = portrait
        self.landscapeImage = landscape

        super.init(image: portrait)

    }//initialize

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
