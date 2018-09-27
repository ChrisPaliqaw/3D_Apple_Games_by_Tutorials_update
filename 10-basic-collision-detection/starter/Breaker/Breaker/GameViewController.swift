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
  
  var scnView: SCNView!
  var scnScene: SCNScene!
  var game = GameHelper.sharedInstance
  var horizontalCameraNode: SCNNode!
  var verticalCameraNode: SCNNode!
  var ballNode: SCNNode!
  var paddleNode: SCNNode!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupScene()
    setupNodes()
    setupSounds()
  }
  
  func setupScene() {
    scnView = self.view as! SCNView
    scnView.delegate = self
    
    scnScene = SCNScene(named: "Breaker.scnassets/Scenes/Game.scn")
    scnView.scene = scnScene
  }
  
  func setupNodes() {
    horizontalCameraNode = scnScene.rootNode.childNode(withName: "HorizontalCamera", recursively: true)!
    verticalCameraNode = scnScene.rootNode.childNode(withName: "VerticalCamera", recursively: true)!
    
    scnScene.rootNode.addChildNode(game.hudNode)
    
    ballNode = scnScene.rootNode.childNode(withName: "Ball", recursively: true)!
    
    paddleNode = scnScene.rootNode.childNode(withName: "Paddle", recursively: true)!
  }
  
  func setupSounds() {
  }
  
  override var shouldAutorotate: Bool { return true }
  
  override var prefersStatusBarHidden: Bool { return true }
  
  // 1
  override func viewWillTransition(to size: CGSize, with coordinator:
    UIViewControllerTransitionCoordinator) {
    // 2
    let deviceOrientation = UIDevice.current.orientation
    switch(deviceOrientation) {
    case .portrait:
      scnView.pointOfView = verticalCameraNode
    default:
      scnView.pointOfView = horizontalCameraNode
    }
  }
}

extension GameViewController: SCNSceneRendererDelegate {
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    game.updateHUD()
  }
}
