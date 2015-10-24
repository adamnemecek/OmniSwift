//
//  GLSUniversalRenderer.swift
//  Gravity
//
//  Created by Cooper Knaak on 2/18/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import UIKit


public struct UVertex: CustomStringConvertible {
    
    public var position:(GLfloat, GLfloat) = (0.0, 0.0)
    public var texture:(GLfloat, GLfloat)  = (0.0, 0.0)
    public var index:GLfloat = 0.0
    
    public var description:String {
        return "[\(index)]:\(position)-\(texture)"
    }
    public init() {
        
    }
}

public class GLSUniversalRenderer: NSObject {
    
    public let renderer = UniversalRenderProgram.sharedInstance
    
    public var references:[GLSNodeReference] = []
    public var vertices:[UVertex] = []
    public var modelMatrices = SCMatrix4Array(matrices: [])
    public var tintColors = SCVector3Array()
    public var tintIntensities = SCVector3Array()
    public var shadeColors = SCVector3Array()
    public var alphas:[GLfloat] = []
    
    public var backgroundVertices:[UVertex] = []
    public var backgroundModelMatrices = SCMatrix4Array(matrices: [])
    public var backgroundTintColors = SCVector3Array()
    public var backgroundTintIntensities = SCVector3Array()
    public var backgroundShadeColors = SCVector3Array()
    public var backgroundAlphas:[GLfloat] = []
    
    public var projection = SCMatrix4()
    
    public var currentIndex = 0
    public var currentVertexIndex = 0
    
    public var camera = GLSCamera()
    
    public var shouldUpdate = true
    public var backgroundContext:EAGLContext? = nil
    //    public var backgroundQueue:dispatch_queue_t = dispatch_queue_create("GLSUniversalRenderer Update Queue", DISPATCH_QUEUE_SERIAL)
    public var backgroundQueue = GLSUniversalRenderer.universalBackgroundQueue
    public static let universalBackgroundQueue:dispatch_queue_t = dispatch_queue_create("GLSUniversalRenderer Update Queue", DISPATCH_QUEUE_SERIAL)
    
    public let operationQueue = NSOperationQueue()
    public var drawingOperation:NSOperation? = nil
    public var updatingOperation:NSOperation? = nil
    public var regeneratingOperation:NSOperation? = nil
    private var insertRemoveOperations:[NSOperation] = []
    
    public override init() {
        
        self.operationQueue.underlyingQueue = self.backgroundQueue
        
        super.init()
        
    }
    
    
    public func addNode(node:GLSNode) {
        
        dispatch_async(self.backgroundQueue) { [unowned self] in
            
            let reference = GLSNodeReference(node: node, index: self.currentIndex, startIndex: self.currentVertexIndex, vertexCount: node.vertices.count)
            
            self.references.append(reference)
            
            self.vertices += node.vertices
            self.modelMatrices.addMatrix(node.recursiveModelMatrix())
            self.tintColors += node.tintColor
            self.tintIntensities += node.tintIntensity
            self.shadeColors += node.shadeColor
            self.alphas.append(GLfloat(node.alpha))
            
            ++self.currentIndex
            self.currentVertexIndex += node.vertices.count
            
            //        self.iterateVertices(reference) { (inout vertex:UVertex) in vertex.index = GLfloat(reference.index) }
            self.updateIndexForNode(reference)
        }
    }//add node
    
    public var isInserting = false
    public var insertionCount = 0
    public func insertNode(node:GLSNode, atIndex:Int) {
        
        let operation = NSBlockOperation
            /*dispatch_async(self.backgroundQueue) */{ [unowned self] in
                //            dispatch_suspend(dispatch_get_main_queue())
                self.isInserting = true
                /*
                if (index < 0 || index > self.references.count) {
                print("Insertion Failed:\(index)-\(self.references.count)")
                if (index - self.references.count >= 25) {
                print("Major Error.")
                }
                return
                }
                */
                var index = atIndex
                if (index < 0) {
                    return
                } else if (index > self.references.count) {
                    index = self.references.count
                }
                
                
                var startVertexIndex = self.currentVertexIndex
                if (index == 0) {
                    startVertexIndex = 0
                } else if (index < self.references.count) {
                    startVertexIndex = self.references[index - 1].endIndex
                }
                let reference = GLSNodeReference(node: node, index: index, startIndex: startVertexIndex, vertexCount: node.vertices.count)
                
                self.references.insert(reference, atIndex: index)
                
                for iii in reference.startIndex..<reference.endIndex {
                    let vIndex = iii - reference.startIndex
                    if (self.renderer.isRendering) {
                        ++self.insertionCount
                        print("Insertion Error \(self.insertionCount)!")
                    }
                    self.vertices.insert(node.vertices[vIndex], atIndex: iii)
                }
                
                self.modelMatrices.insertMatrix(node.recursiveModelMatrix(), atIndex: index)
                self.tintColors.insertVector(node.tintColor, atIndex: index)
                self.tintIntensities.insertVector(node.tintIntensity, atIndex: index)
                self.shadeColors.insertVector(node.shadeColor, atIndex: index)
                self.alphas.insert(GLfloat(node.alpha), atIndex: index)
                
                ++self.currentIndex
                self.currentVertexIndex += node.vertices.count
                
                self.updateIndexForNode(reference)
                
                startVertexIndex += node.vertices.count
                for iii in (index + 1)..<self.references.count {
                    let cur = self.references[iii]
                    cur.index = iii
                    cur.startIndex = startVertexIndex
                    
                    self.updateIndexForNode(cur)
                    
                    startVertexIndex += cur.vertexCount
                }
                
                self.isInserting = false
                //            dispatch_resume(dispatch_get_main_queue())
        }
        
        GLSUniversalRenderer.addOperation(operation)
    }//insert node at index
    
    public func removeNode(node:GLSNode) {
        
        let operation = NSBlockOperation
            /*dispatch_async(self.backgroundQueue) */{ [unowned self] in
                
                for (iii, cur) in self.references.enumerate() {
                    if (cur.node === node) {
                        self.removeNodeAtIndex_Internal(iii)
                        //                    self.removeNodeAtIndex(iii)
                        break
                    }
                }
                
        }
        
        GLSUniversalRenderer.addOperation(operation)
    }//remove node
    
    public func removeNodeAtIndex(index:Int) {
        
        dispatch_async(self.backgroundQueue) { [unowned self] in
            
            self.removeNodeAtIndex_Internal(index)
            
        }
        
    }//remove node at index
    
    private func removeNodeAtIndex_Internal(index:Int) {
        
        if (index < 0 || index >= self.references.count) {
            return
        }
        
        if self.isInserting {
            print("Error! Removed while inserting! (1)")
        }
        
        let startIndex = self.references[index].startIndex
        let vertexCount = self.references[index].vertexCount
        
        self.references.removeAtIndex(index)
        
        self.modelMatrices.removeMatrixAtIndex(index)
        self.tintColors.removeVectorAtIndex(index)
        self.tintIntensities.removeVectorAtIndex(index)
        self.shadeColors.removeVectorAtIndex(index)
        self.vertices.removeRange(startIndex..<(startIndex + vertexCount))
        self.alphas.removeAtIndex(index)
        
        --self.currentIndex
        self.currentVertexIndex -= vertexCount
        
        for iii in index..<self.references.count {
            
            --self.references[iii].index
            self.references[iii].startIndex -= vertexCount
            
            self.updateIndexForNode(self.references[iii])
            
        }//update vertices
        
        if self.isInserting {
            print("Error! Removed while inserting! (2)")
        }
    }
    
    
    public func updateNodeAtIndex(index:Int) {
        
        if (index < 0 || index >= self.references.count) {
            return
        }
        
        if let node = self.references[index].node {
            
            if (node.modelMatrixIsDirty) {
                
                let rmm = node.recursiveModelMatrix()
                //                self.backgroundModelMatrices.changeMatrix(rmm, atIndex: index)
                self.backgroundModelMatrices.changeMatrix_Fast2D(rmm, atIndex: index)
                /* 1.1 -- 64.6 -- 29.7 */
                node.modelMatrixIsDirty = false
            }
            
            if (node.alphaIsDirty) {
                //                self.alphas[index] = GLfloat(node.alpha)
                self.backgroundAlphas[index] = GLfloat(node.alpha)
                node.alphaIsDirty = false
            }
            
            if (node.tintColorIsDirty) {
                //                self.tintColors.changeVector(node.tintColor, atIndex: index)
                self.backgroundTintColors.changeVector(node.tintColor, atIndex: index)
                node.tintColorIsDirty = false
            }
            
            if (node.tintIntensityIsDirty) {
                //                self.tintIntensities.changeVector(node.tintIntensity, atIndex: index)
                self.backgroundTintIntensities.changeVector(node.tintIntensity, atIndex: index)
                node.tintIntensityIsDirty = false
            }
            
            if (node.shadeColorIsDirty) {
                //                self.shadeColors.changeVector(node.shadeColor, atIndex: index)
                self.backgroundShadeColors.changeVector(node.shadeColor, atIndex: index)
                node.shadeColorIsDirty = false
            }
            
            if (node.verticesAreDirty) {
                
                let range = self.references[index].startIndex..<self.references[index].endIndex
                //                self.vertices.replaceRange(range, with: node.vertices)
                self.backgroundVertices.replaceRange(range, with: node.vertices)
                node.verticesAreDirty = false
            }
        }
        
    }//update node at index
    
    public func updateNode(node:GLSNode) {
        
        for (iii, cur) in self.references.enumerate() {
            
            if (cur.node === node) {
                self.updateNodeAtIndex(iii)
                break
            }
        }
        
    }//update node
    
    public func update() {
        
        if (self.shouldUpdate) {
            self.shouldUpdate = false
            
            let operation = NSBlockOperation
                /*dispatch_async(self.backgroundQueue) */{ [unowned self] in
                    
                    self.backgroundVertices = self.vertices
                    self.backgroundModelMatrices.setMatrices(self.modelMatrices)
                    self.backgroundTintColors.setVectors(self.tintColors)
                    self.backgroundTintIntensities.setVectors(self.tintIntensities)
                    self.backgroundShadeColors.setVectors(self.shadeColors)
                    self.backgroundAlphas = self.alphas
                    
                    var referencesToRemove:[Int] = []
                    for iii in 0..<self.references.count {
                        
                        if (self.references[iii].shouldRemove) {
                            referencesToRemove.append(iii)
                            
                        } else {
                            
                            self.updateNodeAtIndex(iii)
                            
                        }
                    }
                    
                    self.vertices = self.backgroundVertices
                    self.modelMatrices.setMatrices(self.backgroundModelMatrices)
                    self.tintColors.setVectors(self.backgroundTintColors)
                    self.tintIntensities.setVectors(self.backgroundTintIntensities)
                    self.shadeColors.setVectors(self.backgroundShadeColors)
                    self.alphas = self.backgroundAlphas
                    
                    for (var iii = referencesToRemove.count - 1; iii >= 0; --iii) {
                        self.removeNodeAtIndex_Internal(referencesToRemove[iii])
                    }
                    
                    self.shouldUpdate = true
            }
            
            operation.name = "Update"
            operation.completionBlock = { [unowned self] in self.updatingOperation = nil }
            operation.addOptionalDependency(self.drawingOperation)
            self.operationQueue.addOperation(operation)
        }
        
        self.insertRemoveOperations = self.insertRemoveOperations.filter() { !$0.finished }
    }//update
    
    public func updateIndexForNode(reference:GLSNodeReference) {
        
        for iii in reference.startIndex..<reference.endIndex {
            self.vertices[iii].index = GLfloat(reference.index)
        }
        
    }//update index for reference
    
    public func iterateVertices(reference:GLSNodeReference, withBlock block:(inout UVertex) -> ()) {
        
        for iii in reference.startIndex..<reference.endIndex {
            block(&self.vertices[iii])
        }
        
    }
    
    
    public func regenerateReferencesForParent(node:GLSNode) {
        
        let operation = NSBlockOperation() { [unowned self] in
            self.regenerateReferencesForParent_Internal(node)
        }
        operation.completionBlock = { [unowned self] in self.regeneratingOperation = nil }
        GLSUniversalRenderer.addOperation(operation)
        self.regeneratingOperation = operation
    }//regenerate references for parent
    
    public func regenerateReferencesForParent_Internal(node:GLSNode) {
        
        var refs:[GLSNodeReference] = []
        var startIndex = 0
        var renderIndex = 0
        
        var vertices:[UVertex] = []
        var modelMatrices:[GLfloat] = []
        var tintColors:[GLfloat] = []
        var tintIntensities:[GLfloat] = []
        var shadeColors:[GLfloat] = []
        var alphas:[GLfloat] = []
        
        let block:(GLSNode) -> () = { node in
            refs.append(GLSNodeReference(node: node, index: renderIndex, startIndex: startIndex, vertexCount: node.vertices.count))
            
            for iii in 0..<node.vertices.count {
                node.vertices[iii].index = GLfloat(renderIndex)
            }
            vertices += node.vertices
            
            modelMatrices += node.recursiveModelMatrix().values
            tintColors += node.tintColor.getGLArray()
            tintIntensities += node.tintIntensity.getGLArray()
            shadeColors += node.shadeColor.getGLArray()
            alphas.append(GLfloat(node.alpha))
            
            startIndex += node.vertices.count
            renderIndex++
        }
        
        node.iterateChildrenRecursively(block)
        
        self.references = refs
        self.vertices = vertices
        self.modelMatrices.values = modelMatrices
        self.tintColors.values = tintColors
        self.tintIntensities.values = tintIntensities
        self.shadeColors.values = shadeColors
        self.alphas = alphas
    }//regerenate references for parent (internal)
    
    
    public func render() {
        
        self.renderer.bind()
        self.renderer.render()
        
    }//render
    
    
    public func removeAll() {
        
        self.references.removeAll(keepCapacity: true)
        self.vertices.removeAll(keepCapacity: true)
        self.modelMatrices.removeAll()
        self.tintColors.removeAll()
        self.tintIntensities.removeAll()
        self.shadeColors.removeAll()
        
        self.currentIndex = 0
        self.currentVertexIndex = 0
        
        GLSUniversalEmitterRenderer.removeAll()
    }//remove all references
    
}

//GLSUniversalRenderer + SharedInstance
public extension GLSUniversalRenderer {
    
    public class var sharedInstance:GLSUniversalRenderer {
        struct StaticInstance {
            static let instance = GLSUniversalRenderer()
        }
        
        return StaticInstance.instance
    }
    
    public class func addNode(node:GLSNode) {
        GLSUniversalRenderer.sharedInstance.addNode(node)
    }
    
    public class func removeNode(node:GLSNode) {
        GLSUniversalRenderer.sharedInstance.removeNode(node)
    }
    
    public class func update() {
        GLSUniversalRenderer.sharedInstance.update()
    }
    
    public class func render() {
        GLSUniversalRenderer.sharedInstance.render()
    }
    
    public class func removeAll() {
        GLSUniversalRenderer.sharedInstance.removeAll()
    }
    
    public class func addOperation(operation:NSOperation) {
        
        if let uOperation = GLSUniversalRenderer.sharedInstance.updatingOperation {
            operation.addDependency(uOperation)
        }
        if let dOperation = GLSUniversalRenderer.sharedInstance.drawingOperation {
            operation.addDependency(dOperation)
        }
        
        GLSUniversalRenderer.sharedInstance.operationQueue.addOperation(operation)
    }//add operation
    
    
    public class var viewCamera:GLSCamera { return GLSUniversalRenderer.sharedInstance.camera }
    
}//Shared Instance

//GLSUniversalRenderer + Emitter
public extension GLSUniversalRenderer {
    
    public func addEmitter(emitter:GLSParticleEmitter) {
        
        self.addNode(emitter.buffer.sprite)
        GLSUniversalEmitterRenderer.sharedInstance.addEmitter(emitter)
        
    }//add emitter
    
    public func insertEmitter(emitter:GLSParticleEmitter, atIndex index:Int) {
        
        self.insertNode(emitter.buffer.sprite, atIndex: index)
        
        //Since emitters are rendered to seperate background
        //buffers, the order they are rendered doesn't matter
        GLSUniversalEmitterRenderer.sharedInstance.addEmitter(emitter)
        
    }//insert emitter
    
    public func removeEmitter(emitter:GLSParticleEmitter) {
        
        self.removeNode(emitter.buffer.sprite)
        GLSUniversalEmitterRenderer.sharedInstance.removeEmitter(emitter)
        
    }//remove emitter
    
    
}//Emitters
