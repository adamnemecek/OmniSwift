//
//  GLSUniversalEmitterRenderer.swift
//  Gravity
//
//  Created by Cooper Knaak on 2/20/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import GLKit

public class GLSUniversalEmitterRenderer: NSObject {

    public var vertices:[PEVertex] = []
    public var references:[GLSEmitterReference] = []

    public var shouldUpdate = true

    public var renderer = UniversalEmitterRenderProgram()

    public var drawingOperation:NSOperation? = nil
    public var updatingOperation:NSOperation? = nil

    public func addEmitter(emitter:GLSParticleEmitter) {

        self.dispatchAsync() { [unowned self] in

            let ref = GLSEmitterReference(emitter: emitter, startIndex: self.vertices.count)
            self.references.append(ref)

            self.vertices += emitter.particles

        }
    }//add emitter

    public func removeEmitter(emitter:GLSParticleEmitter) {

        for (iii, cur) in self.references.enumerate() {
            if (cur.emitter === emitter) {
                self.removeReferenceAtIndex(iii)
                break
            }
        }

    }

    public func removeReferenceAtIndex(index:Int) {

        self.dispatchAsync() { [unowned self] in
            if (index < 0 || index >= self.references.count) {
                return
            }

            //        let range = self.references[index].startIndex..<self.references[index].endIndex
            /*
            if let emitter = self.references[index].emitter {

            let range = self.references[index].startIndex..<(self.references[index].startIndex + emitter.particles.count)
            self.vertices.removeRange(range)

            }
            */

            self.updateVertices()

            self.references.removeAtIndex(index)
        }
    }

    public func updateVertices() {

        if (!self.shouldUpdate) {
            return
        }

        self.shouldUpdate = false

        let operation = NSBlockOperation
            /*self.dispatchAsync()*/ { [unowned self] in
                //            self.vertices.removeAll(keepCapacity: true)

                var verts:[PEVertex] = []
                var startIndex = 0
                for (_, cur) in self.references.enumerate() {

                    if let emitter = cur.emitter {
                        //                    self.vertices += emitter.particles
                        verts += emitter.particles
                    }

                    /*
                    *  Don't set index because it doesn't matter what
                    *  order emitters are rendered in because they are
                    *  all rendered to different background textures.
                    *  However, setting the index causes the 'universalRenderIndex'
                    *  property of the actual emitter node to change,
                    *  screwing up the render hiearchy
                    */
                    //            cur.index = iii
                    cur.updateIndices(startIndex)
                    startIndex = cur.endIndex
                }

                self.vertices = verts

                self.shouldUpdate = true
        }

        operation.completionBlock = { [unowned self] in self.updatingOperation = nil }
        self.updatingOperation = operation
        GLSUniversalRenderer.addOperation(operation)
    }//update vertices

    public func render() {

//        self.updateVertices()
        self.renderer.bind()
        self.renderer.render()

    }//render

    public func dispatchAsync(block:dispatch_block_t) {

//        dispatch_async(GLSUniversalRenderer.sharedInstance.backgroundQueue, block)
//        dispatch_async(ParticleEmitterBackgroundQueue.sharedInstance.queues[0], block)

        let operation = NSBlockOperation(block: block)
        GLSUniversalRenderer.addOperation(operation)
    }//dispatch async


    public func removeAll() {

        self.vertices.removeAll(keepCapacity: true)
        self.references.removeAll(keepCapacity: true)

    }//remove all
}

//GLSUniversalEmitterRenderer + SharedInstance
extension GLSUniversalEmitterRenderer {

    public class var sharedInstance:GLSUniversalEmitterRenderer {
        struct StaticInstance {
            static let instance = GLSUniversalEmitterRenderer()
        }

        return StaticInstance.instance
    }

    public class func render() {
        GLSUniversalEmitterRenderer.sharedInstance.render()
    }

    public class func removeAll() {
        GLSUniversalEmitterRenderer.sharedInstance.removeAll()
    }

}//Shared Instance
