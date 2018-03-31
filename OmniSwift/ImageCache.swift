//
//  ImageCache.swift
//  Gravity
//
//  Created by Cooper Knaak on 3/28/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import UIKit


public class ImageCache: NSObject, XMLFileHandlerDelegate {

    public var images:[String:UIImage] = [:]

    public let backgroundQueue = dispatch_queue_create("ImageCache Background Queue", DISPATCH_QUEUE_SERIAL)

    private var fileName = ""
    private lazy var fileHandler:XMLFileHandler = XMLFileHandler(file: self.fileName, directory: nil, delegate: self)

    public func loadImagesFromFile(file:String) {

        self.fileName = file
        //        self.fileHandler.loadFile()
        self.loadImages()

    }//load images

    public func loadImages() {
        dispatch_async(self.backgroundQueue) { [unowned self] in
            self.fileHandler.loadFile()
        }
    }

    public func loadImages_sync() {

        dispatch_sync(self.backgroundQueue) { [unowned self] in
            self.fileHandler.loadFile()
        }

    }//load images with dispatch_sync

    /** Deallocates all images in 'images' dictionary.
    Invoke 'loadImages' to reload all images.
    */
    public func destroyImages() {

        autoreleasepool {
            self.images.removeAll(keepCapacity: true)
        }

    }//destroy images

    public func startElement(elementName: String, attributes: XMLDictionary) {
        autoreleasepool {
            if (elementName == "Images") {
                return
            }//Use 'Images' as main xml key

            let name = attributes["name"]!
            let key = attributes["key"]!

            if let extensionString = attributes["extension"] {

                /*if (extensionString == "png") {
                self.loadPNGImage(name, withKey: key)
                } else if (ext)*/
                switch extensionString {
                case "png", "PNG":
                    self.loadPNGImage(name, withExtension: extensionString, withKey: key)
                case "pdf", "PDF":
                    let size = CGSizeFromString(attributes["size"]!)
                    self.loadPDFImage(name, withExtension: extensionString, withKey: key, size: size)
                default:
                    print("\(elementName)-\(name)-\(key) has invalid extension: \(extensionString).")
                    break
                }
            }
        }
    }//start element

    private func loadPNGImage(name:String, withExtension:String, withKey key:String) {

        //".png" extension is not needed when loading png files.
        //Creating the image adds it to the cache. Not saving
        //it lets me leave it in the cache rather than saving
        //it as an image. The extension and key parameters
        //are reserved for later use, when I might change my mind.
        let _ = UIImage(named: name)

    }//load png image with key

    private func loadPDFImage(name:String, withExtension:String, withKey key:String, size:CGSize) {

        let image = UIImage.imageWithPDFFile(name, size: size)

        //PDF Images must be stored.
        self.images[key] = image

    }//load pdf image with key

    subscript(key:String) -> UIImage? {
        get {
            if let validImage = self.images[key] {
                return validImage
            } else {
                //PNG Images are not loaded into the cache
                return UIImage(named: key)
            }
        }
        set {
            self.images[key] = newValue
        }
    }

    deinit {
        autoreleasepool {
            self.images.removeAll(keepCapacity: false)
        }
    }
}

// MARK: - Singleton

public extension ImageCache {

    public class var sharedInstance:ImageCache {
        struct StaticInstance {
            static var instance:ImageCache! = nil
            static var onceToken:dispatch_once_t = 0
        }

        dispatch_once(&StaticInstance.onceToken) {
            StaticInstance.instance = ImageCache()
        }

        return StaticInstance.instance
    }

    public class func imageForKey(key:String) -> UIImage? {
        return ImageCache.sharedInstance[key]
    }

}//Singleton
