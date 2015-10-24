//
//  GLSNode+UniversalRendering.swift
//  Gravity
//
//  Created by Cooper Knaak on 2/19/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import GLKit

//Handles adding/removing nodes from the universal
//render tree. Just have these methods return immediately
//if you later decide not to let GLSNode handle this.
//Or just never set the superparent's 'universalRenderer' property
public extension GLSNode {
    
    // MARK: - GLSUniversalRenderer
    
    public func nodeAddedAsChild(node:GLSNode) {
        
        if let _ = self.universalRenderer {
            
            var index = self.universalRenderIndex + 1
            /*
             *  Since 'node' is added to 'children' before this
             *  method is called, 'children' always has at least 1
             *  member and the last child is always 'node'. I need
             *  to access the second-to-last child's 'universalRenderIndex'
             */
            if (self.children.count >= 2) {
                index = self.children[self.children.count - 2].universalRenderIndex + 1
                self.children[self.children.count - 2].iterateChildrenRecursively() { (childNode:GLSNode) in
                    index = childNode.universalRenderIndex + 1
                }

            }
            
            self.configureChild(node, withIndex: index)
        }
        
    }//node added as child
    
    public func nodeRemovedFromParent(node:GLSNode) {
        
        if let uRend = self.universalRenderer {
            
            node.removeFromUniversalRenderer = true
            node.universalRenderer = nil
            node.universalRenderIndex = 0
            uRend.removeNode(node)
            
            node.iterateChildrenRecursively() { (childNode:GLSNode) in
                node.universalRenderer = nil
                childNode.universalRenderIndex = 0
                
                uRend.removeNode(childNode)
            }
            
            self.removeFramebuffersOfChild(node)
            
            
            if (GLSNode.wrangleEmitters) {
                if let emitterNode = node as? GLSParticleEmitter {
                    GLSUniversalEmitterRenderer.sharedInstance.removeEmitter(emitterNode)
                }
            }
        }
        
    }//node removed from parent
    
    public func nodeInsertedAsChild(node:GLSNode, atIndex:Int) {
        
        if let _ = self.universalRenderer {
         
            var index = self.universalRenderIndex + 1
            //Only child is newly inserted 'node'
            if (self.children.count == 1) {
                
            }
            //Inserted at very end.
            else if (atIndex > 0 && atIndex <= self.children.count) {
                //Children guarunteed to have more than 1 element.
                //atIndex - 1 is guarunteed to be valid and be
                //the index before the newly inserted 'node'
                let beforeChild = self.children[atIndex - 1]
                var curIndex = beforeChild.universalRenderIndex
                beforeChild.iterateChildrenRecursively() {
                    if ($0.universalRenderIndex > curIndex) {
                        curIndex = $0.universalRenderIndex
                    }
                }
                
                index = curIndex + 1
            }
            
            self.configureChild(node, withIndex: index)
        }
        
    }//node inserted as child
    
    private func configureChild(node:GLSNode, withIndex:Int) {
        
        if let uRend = self.universalRenderer {
            
            var index = withIndex
            
            uRend.insertNode(node, atIndex: index)
            
            node.removeFromUniversalRenderer = false
            node.universalRenderIndex = index
            node.universalRenderer = uRend
            
            ++index
            
            node.iterateChildrenRecursively() { (childNode:GLSNode) in
                childNode.universalRenderer = uRend
                childNode.universalRenderIndex = index
                uRend.insertNode(childNode, atIndex: index)
                ++index
            }
            
            self.setFramebufferOfChild(node)
            
            
            if (GLSNode.wrangleEmitters) {
                if let emitterNode = node as? GLSParticleEmitter {
                    GLSUniversalEmitterRenderer.sharedInstance.addEmitter(emitterNode)
                }
            }
        }
        
    }//configure node added as child
    
    
    public func setFramebufferOfChild(node:GLSNode) {
        
        if (node.framebufferReference.isValid) {
            return
        }
        
        node.framebufferReference = self.framebufferReference
        
        for cur in node.children {
            node.setFramebufferOfChild(cur)
        }
        
    }//set framebuffer of children
    
    //Completely removes framebuffers of children,
    //even if they originally were set
    public func removeFramebuffersOfChild(node:GLSNode) {
        
        node.framebufferReference = GLSFramebufferReference()
        node.iterateChildrenRecursively() { $0.framebufferReference = node.framebufferReference }
        
    }//remove framebuffers of children
    
    // MARK: - RecursiveRenderer
    
    public func nodeAddedAsChild_Recursive(node:GLSNode) {
        
        if let rRend = self.recursiveRenderer {
            
            var index = self.universalRenderIndex + 1
            if self.children.count >= 2 {
                let childNode = self.children[self.children.count - 2]
                index = childNode.universalRenderIndex + 1
                childNode.iterateChildrenRecursively() {
                    index = $0.universalRenderIndex + 1
                }
            }
            
            node.recursiveRenderer = rRend
            node.universalRenderIndex = index
            rRend.insertNode(node, atIndex: index)
            node.iterateChildrenRecursively() { [unowned self] in
                $0.universalRenderIndex = ++index
                rRend.insertNode($0, atIndex: index)
                $0.recursiveRenderer = rRend
                $0.framebufferStack = self.framebufferStack
            }
        }
        
    }
    
    public func nodeRemovedFromParent_Recursive(node:GLSNode) {
        
        if let rRend = self.recursiveRenderer {
            
            node.removeFromUniversalRenderer = true
            node.recursiveRenderer = nil
            
            
            let totalCount = node.recursiveChildrenCount()
            rRend.removeNodesInRange(node.universalRenderIndex...(node.universalRenderIndex + totalCount))
            
            node.universalRenderIndex = -1
            node.iterateChildrenRecursively() { childNode in
                childNode.recursiveRenderer = nil
                childNode.universalRenderIndex = -1
            }

            /*
            rRend.removeNodeAtIndex(node.universalRenderIndex)
            node.universalRenderIndex = 0
            
            node.iterateChildrenRecursively() { childNode in
                rRend.removeNodeAtIndex(childNode.universalRenderIndex)
                childNode.recursiveRenderer = nil
                childNode.universalRenderIndex = 0
            }
            */
        }
        
    }
    
}//Universal Rendering
