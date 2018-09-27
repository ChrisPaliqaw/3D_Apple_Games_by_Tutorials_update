/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
  
import UIKit
import SceneKit

class GameViewController: UIViewController {
  
  var scnView:SCNView!
  var scnScene:SCNScene!
  
  let CollisionCategoryBall = 1
  let CollisionCategoryStone = 2
  let CollisionCategoryPillar = 4
  let CollisionCategoryCrate = 8
  let CollisionCategoryPearl = 16
  
  var ballNode:SCNNode!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupScene()
    setupNodes()
    setupSounds()
  }

  func setupScene() {
    scnView = self.view as! SCNView
    scnView.delegate = self
    scnView.allowsCameraControl = true
    scnView.showsStatistics = true
    scnScene = SCNScene(named: "art.scnassets/game.scn")
    scnView.scene = scnScene
    
    scnScene.physicsWorld.contactDelegate = self
  }
  
  func setupNodes() {
    ballNode = scnScene.rootNode.childNode(withName: "ball", recursively: true)!
    ballNode.physicsBody?.contactTestBitMask = CollisionCategoryPillar | CollisionCategoryCrate | CollisionCategoryPearl
  }
  
  func setupSounds() {
  }
  
  override var shouldAutorotate : Bool { return false }
  
  override var prefersStatusBarHidden : Bool { return true }
}

extension GameViewController: SCNSceneRendererDelegate {
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
  }
}

extension GameViewController : SCNPhysicsContactDelegate {
  func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
    // 1
    var contactNode:SCNNode!
    if contact.nodeA.name == "ball" {
      contactNode = contact.nodeB
    } else {
      contactNode = contact.nodeA
    }
    
    // 2
    if contactNode.physicsBody?.categoryBitMask == CollisionCategoryPearl {
      contactNode.isHidden = true
      contactNode.runAction(SCNAction.waitForDurationThenRunBlock(duration: 30) { (node:SCNNode!) -> Void in
        node.isHidden = false
        })
    }
    
    // 3
    if contactNode.physicsBody?.categoryBitMask == CollisionCategoryPillar || contactNode.physicsBody?.categoryBitMask == CollisionCategoryCrate {
    }
  }
}

