//
//  ShaderHelper.swift
//  InverseKinematicsTest
//
//  Created by Cooper Knaak on 10/13/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

import GLKit

public class ShaderHelper : NSObject {

    // MARK: - Shared Instance
    public class var sharedInstance : ShaderHelper {
        struct Static {
            static let instance:ShaderHelper = ShaderHelper()
        }//static instance
        return Static.instance
    }//shared instance class
    
    // MARK: - Properties
    
    public var programs:[String:GLuint] = [:]
    private(set) public var isLoaded = false
    
    // MARK: - Setup
    
    override init() {

    }
    
    // MARK: - Logic
    
    public func loadPrograms(dict:[String:String]) {
        
        for (key, file) in dict {
            let program = buildProgram(file)
            programs[key] = program
        }//create shaders
        
        self.isLoaded = true
    }//load programs
    
    ///Gets all *.vsh* and *.fsh* files from the main bundle and loads them.
    public func loadProgramsFromBundle() {
        let uppercaseSet = NSCharacterSet.uppercaseLetterCharacterSet()
        
        var fileDict:[String:String] = [:]
        let files = NSFileManager.defaultManager().allFilesOfType("vsh").map() { $0.absoluteString }
        for file in files {
            var nextFile = file
            var indices:[Int] = []
            
            //Skip first character
            for (iii, curChar) in enumerate(nextFile.utf16, range: 1..<file.characterCount) {
                if uppercaseSet.characterIsMember(curChar) {
                    indices.append(iii)
                }
            }
            
            for (iii, index) in indices.enumerate() {
                // I add 'iii' because inserting characters will increase the length of the string.
                let stringIndex = nextFile.startIndex.advancedBy(index + iii)
                nextFile.insert(" ", atIndex: stringIndex)
            }
            
            fileDict[nextFile] = file
        }
        
        self.loadPrograms(fileDict)
    }
    
    public func buildProgram(file:String) -> GLuint {
        let program = glCreateProgram()

        let vertexShader = buildShader(file + ".vsh", shaderType: GLenum(GL_VERTEX_SHADER))
        let fragmentShader = buildShader(file + ".fsh", shaderType: GLenum(GL_FRAGMENT_SHADER))
        
        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
        
        glLinkProgram(program)
    
        return program
    }//create program
    
    public func buildShader(file:String, shaderType:GLenum) -> GLuint {
        
        let path = NSBundle.mainBundle().pathForResource(file, ofType: nil)
        //var data = String.stringWithContentsOfFile(path!, encoding: NSUTF8StringEncoding, error: nil)
        let data = try? String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        var text:UnsafePointer<GLchar> = (data! as NSString).UTF8String
        
        /*let source = glCreateShader(shaderType)
        
        var textAddress = UnsafePointer<UnsafePointer<GLchar>>(text)
        textAddress = withUnsafePointer(&text, { (pointer:UnsafePointer<GLchar>) in
            
            glShaderSource(source, 1, textAddress, nil)
        })*/
        let source = withUnsafePointer(&text) { (pointer:UnsafePointer<UnsafePointer<GLchar>>) -> GLuint in
            let sourceValue = glCreateShader(shaderType)
            glShaderSource(sourceValue, 1, pointer, nil)
            glCompileShader(sourceValue)
            return sourceValue
        }
        
        var logLength:GLint = 0
        glGetShaderiv(source, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if (logLength > 0)
        {//valid log
            var ump = Array<GLchar>(count: Int(logLength), repeatedValue: 0)
//            var ump = UnsafeMutablePointer<GLchar>(malloc(UInt(logLength)))
            glGetShaderInfoLog(source, logLength, &logLength, &ump)
            let str = String(UTF8String: ump)
            print("Shader Log:\(str!)")
        }//valid log
        
        var status:GLint = 0
        glGetShaderiv(source, GLenum(GL_COMPILE_STATUS), &status)
        if (status == 0)
        {//invalid
            let error = glGetError()
            print("\(file)--Error:\(error)")
        }//invalid
        
        return source
    }//create shader
    
    
    public subscript(index:String) -> GLuint? {
        if let program = self.programs[index] {
            return program
        } else {
            print("ShaderHelper: \(index) does not exist!")
            return nil
        }
    }//get program for string
    
    public class func programForString(key:String) -> GLuint? {
        return ShaderHelper.sharedInstance[key]
    }//get program for string
    
//Logic
    
    
}//shader helper
