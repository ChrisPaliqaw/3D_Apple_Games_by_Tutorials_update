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
import SpriteKit

class ViewController: UIViewController {

  let BitMaskPig = 1
  let BitMaskVehicle = 2
  let BitMaskObstacle = 4
  let BitMaskFront = 8
  let BitMaskBack = 16
  let BitMaskLeft = 32
  let BitMaskRight = 64
  let BitMaskCoin = 128
  let BitMaskHouse = 256
  
  let game = GameHelper.sharedInstance
  var scnView: SCNView!
  var gameScene: SCNScene!
  var splashScene: SCNScene!
  
  var pigNode: SCNNode!
  var cameraNode: SCNNode!
  var cameraFollowNode: SCNNode!
  var lightFollowNode: SCNNode!
  var trafficNode: SCNNode!
  
  var driveLeftAction: SCNAction!
  var driveRightAction: SCNAction!
  
  var jumpLeftAction: SCNAction!
  var jumpRightAction: SCNAction!
  var jumpForwardAction: SCNAction!
  var jumpBackwardAction: SCNAction!
  
  var triggerGameOver: SCNAction!
  
  var collisionNode: SCNNode!
  var frontCollisionNode: SCNNode!
  var backCollisionNode: SCNNode!
  var leftCollisionNode: SCNNode!
  var rightCollisionNode: SCNNode!
  
  var activeCollisionsBitMask: Int = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupScenes()
    setupNodes()
    setupActions()
    setupTraffic()
    setupGestures()
    setupSounds()
    game.state = .tapToPlay
  }
  
  func setupScenes() {
    scnView = SCNView(frame: self.view.frame)
    self.view.addSubview(scnView)
    
    gameScene = SCNScene(named: "/MrPig.scnassets/GameScene.scn")
    splashScene = SCNScene(named: "/MrPig.scnassets/SplashScene.scn")
    scnView.scene = splashScene
    scnView.delegate = self
    gameScene.physicsWorld.contactDelegate = self
  }
  
  func setupNodes() {
    pigNode = gameScene.rootNode.childNode(withName: "MrPig", recursively: true)!
    cameraNode = gameScene.rootNode.childNode(withName: "camera", recursively: true)!
    cameraNode.addChildNode(game.hudNode)
    cameraFollowNode = gameScene.rootNode.childNode(withName: "FollowCamera", recursively: true)!
    lightFollowNode = gameScene.rootNode.childNode(withName: "FollowLight", recursively: true)!
    trafficNode = gameScene.rootNode.childNode(withName: "Traffic", recursively: true)!
    
    collisionNode = gameScene.rootNode.childNode(withName: "Collision", recursively: true)!
    frontCollisionNode = gameScene.rootNode.childNode(withName: "Front", recursively: true)!
    backCollisionNode = gameScene.rootNode.childNode(withName: "Back", recursively: true)!
    leftCollisionNode = gameScene.rootNode.childNode(withName: "Left", recursively: true)!
    rightCollisionNode = gameScene.rootNode.childNode(withName: "Right", recursively: true)!
    
    pigNode.physicsBody?.contactTestBitMask = BitMaskVehicle | BitMaskCoin | BitMaskHouse
    frontCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
    backCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
    leftCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
    rightCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
  }
  
  func setupActions() {
    driveLeftAction = SCNAction.repeatForever(SCNAction.move(by: SCNVector3Make(-2.0, 0, 0), duration: 1.0))
    driveRightAction = SCNAction.repeatForever(SCNAction.move(by: SCNVector3Make(2.0, 0, 0), duration: 1.0))
    
    let duration = 0.2
    let bounceUpAction = SCNAction.moveBy(x: 0, y: 1.0, z: 0, duration: duration * 0.5)
    let bounceDownAction = SCNAction.moveBy(x: 0, y: -1.0, z: 0, duration: duration * 0.5)
    bounceUpAction.timingMode = .easeOut
    bounceDownAction.timingMode = .easeIn
    let bounceAction = SCNAction.sequence([bounceUpAction, bounceDownAction])
    let moveLeftAction = SCNAction.moveBy(x: -1.0, y: 0, z: 0, duration: duration)
    let moveRightAction = SCNAction.moveBy(x: 1.0, y: 0, z: 0, duration: duration)
    let moveForwardAction = SCNAction.moveBy(x: 0, y: 0, z: -1.0, duration: duration)
    let moveBackwardAction = SCNAction.moveBy(x: 0, y: 0, z: 1.0, duration: duration)
    let turnLeftAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: -90), z: 0, duration: duration, usesShortestUnitArc: true)
    let turnRightAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: 90), z: 0, duration: duration, usesShortestUnitArc: true)
    let turnForwardAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: 180), z: 0, duration: duration, usesShortestUnitArc: true)
    let turnBackwardAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: 0), z: 0, duration: duration, usesShortestUnitArc: true)
    jumpLeftAction = SCNAction.group([turnLeftAction, bounceAction, moveLeftAction])
    jumpRightAction = SCNAction.group([turnRightAction, bounceAction, moveRightAction])
    jumpForwardAction = SCNAction.group([turnForwardAction, bounceAction, moveForwardAction])
    jumpBackwardAction = SCNAction.group([turnBackwardAction, bounceAction, moveBackwardAction])
    
    let spinAround = SCNAction.rotateBy(x: 0, y: convertToRadians(angle: 720), z: 0, duration: 2.0)
    let riseUp = SCNAction.moveBy(x: 0, y: 10, z: 0, duration: 2.0)
    let fadeOut = SCNAction.fadeOpacity(to: 0, duration: 2.0)
    let goodByePig = SCNAction.group([spinAround, riseUp, fadeOut])
    let gameOver = SCNAction.run { (node:SCNNode) -> Void in
      self.pigNode.position = SCNVector3(x:0, y:0, z:0)
      self.pigNode.opacity = 1.0
      self.startSplash()
    }
    triggerGameOver = SCNAction.sequence([goodByePig, gameOver])
  }
  
  func setupTraffic() {
    for node in trafficNode.childNodes {
      if node.name?.contains("Bus") == true {
        driveLeftAction.speed = 1.0
        driveRightAction.speed = 1.0
      } else {
        driveLeftAction.speed = 2.0
        driveRightAction.speed = 2.0
      }
      if node.eulerAngles.y > 0 {
        node.runAction(driveLeftAction)
      } else {
        node.runAction(driveRightAction)
      }
    }
  }
  
  func setupGestures() {
    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleGesture(sender:)))
    swipeRight.direction = .right
    scnView.addGestureRecognizer(swipeRight)
    
    let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleGesture(sender:)))
    swipeLeft.direction = .left
    scnView.addGestureRecognizer(swipeLeft)
    
    let swipeForward = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleGesture(sender:)))
    swipeForward.direction = .up
    scnView.addGestureRecognizer(swipeForward)
    
    let swipeBackward = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleGesture(sender:)))
    swipeBackward.direction = .down
    scnView.addGestureRecognizer(swipeBackward)
  }

  @objc func handleGesture(sender: UISwipeGestureRecognizer) {
    guard game.state == .playing else {
        return
    }
    
    let activeFrontCollision = activeCollisionsBitMask & BitMaskFront == BitMaskFront
    let activeBackCollision = activeCollisionsBitMask & BitMaskBack == BitMaskBack
    let activeLeftCollision = activeCollisionsBitMask & BitMaskLeft == BitMaskLeft
    let activeRightCollision = activeCollisionsBitMask & BitMaskRight == BitMaskRight
    
    guard (sender.direction == .up && !activeFrontCollision) ||
        (sender.direction == .down && !activeBackCollision) ||
        (sender.direction == .left && !activeLeftCollision) ||
        (sender.direction == .right && !activeRightCollision) else {
            return
    }
    
    switch sender.direction {
    case UISwipeGestureRecognizerDirection.up:
      pigNode.runAction(jumpForwardAction)
    case UISwipeGestureRecognizerDirection.down:
      pigNode.runAction(jumpBackwardAction)
    case UISwipeGestureRecognizerDirection.left:
      if pigNode.position.x >  -15 {
        pigNode.runAction(jumpLeftAction)
      }
    case UISwipeGestureRecognizerDirection.right:
      if pigNode.position.x < 15 {
        pigNode.runAction(jumpRightAction)
      }
    default:
      break
    }
  }
  
  func setupSounds() {
  }
  
  func startSplash() {
    gameScene.isPaused = true
    let transition = SKTransition.doorsOpenVertical(withDuration: 1.0)
    scnView.present(splashScene, with: transition, incomingPointOfView: nil, completionHandler: {
      self.game.state = .tapToPlay
      self.setupSounds()
      self.splashScene.isPaused = false
    })
  }
  
  func startGame() {
    splashScene.isPaused = true
    let transition = SKTransition.doorsOpenVertical(withDuration: 1.0)
    scnView.present(gameScene, with: transition, incomingPointOfView: nil, completionHandler: {
      self.game.state = .playing
      self.setupSounds()
      self.gameScene.isPaused = false
    })
  }
  
  func stopGame() {
    game.state = .gameOver
    game.reset()
    pigNode.runAction(triggerGameOver)
  }
  
  func updatePositions() {
    collisionNode.position = pigNode.position
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if game.state == .tapToPlay {
      startGame()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override var prefersStatusBarHidden : Bool { return true }
  
  override var shouldAutorotate : Bool { return false }
}

extension ViewController: SCNSceneRendererDelegate {
  func renderer(_ renderer: SCNSceneRenderer,
    didApplyAnimationsAtTime time: TimeInterval) {
    guard game.state == .playing else {
      return
    }
    game.updateHUD()
    updatePositions()
  }
}

extension ViewController: SCNPhysicsContactDelegate {
  func physicsWorld(_ world: SCNPhysicsWorld,
    didBegin contact: SCNPhysicsContact) {
      guard game.state == .playing else {
        return
      }
      
      var collisionBoxNode: SCNNode!
      if contact.nodeA.physicsBody?.categoryBitMask == BitMaskObstacle {
        collisionBoxNode = contact.nodeB
      } else {
        collisionBoxNode = contact.nodeA
      }
      activeCollisionsBitMask |=
        collisionBoxNode.physicsBody!.categoryBitMask
      
      var contactNode: SCNNode!
      if contact.nodeA.physicsBody?.categoryBitMask == BitMaskPig {
        contactNode = contact.nodeB
      } else {
        contactNode = contact.nodeA
      }
      if contactNode.physicsBody?.categoryBitMask == BitMaskVehicle {
        stopGame()
      }
      
      if contactNode.physicsBody?.categoryBitMask == BitMaskCoin {
        contactNode.isHidden = true
        contactNode.runAction(SCNAction.waitForDurationThenRunBlock(duration: 60) {
          (node: SCNNode!) -> Void in
          node.isHidden = false
          })
        game.collectCoin()
      }
  }
  
  func physicsWorld(_ world: SCNPhysicsWorld,
    didEnd contact: SCNPhysicsContact) {
      guard game.state == .playing else {
        return
      }
      
      var collisionBoxNode: SCNNode!
      if contact.nodeA.physicsBody?.categoryBitMask == BitMaskObstacle {
        collisionBoxNode = contact.nodeB
      } else {
        collisionBoxNode = contact.nodeA
      }
      activeCollisionsBitMask &=
        ~collisionBoxNode.physicsBody!.categoryBitMask
  }
}
