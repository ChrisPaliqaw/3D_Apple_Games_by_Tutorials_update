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
import WatchKit
import Foundation
import SceneKit

class InterfaceController: WKInterfaceController {
  
  @IBOutlet var scnInterface: WKInterfaceSCNScene!
  
  //var scnView: SCNView!
  var scnScene: SCNScene!
  var cameraNode: SCNNode!
  var spawnTime: TimeInterval = 0
  var game = GameHelper.sharedInstance
  var splashNodes: [String: SCNNode] = [:]
  
  func setupView() {
    //scnInterface = self.view as! SCNView
    scnInterface.showsStatistics = true
    //scnView.allowsCameraControl = false
    scnInterface.autoenablesDefaultLighting = true
    scnInterface.delegate = self
    scnInterface.isPlaying = true
  }
  
  func setupScene() {
    scnScene = SCNScene()
    scnInterface.scene = scnScene
    scnScene.background.contents =
      "GeometryFighter.scnassets/Textures/Background_Diffuse.jpg"
  }
  
  func setupCamera() {
    cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)
    scnScene.rootNode.addChildNode(cameraNode)
  }
  
  func setupHUD() {
    game.hudNode.position = SCNVector3(x: 0.0, y: 10.0, z: 0.0)
    scnScene.rootNode.addChildNode(game.hudNode)
  }
  
  func createSplash(name: String, imageFileName: String) -> SCNNode {
    let plane = SCNPlane(width: 5, height: 5)
    let splashNode = SCNNode(geometry: plane)
    splashNode.position = SCNVector3(x: 0, y: 5, z: 0)
    splashNode.name = name
    splashNode.geometry?.materials.first?.diffuse.contents = imageFileName
    scnScene.rootNode.addChildNode(splashNode)
    return splashNode
  }
  
  func showSplash(splashName: String) {
    for (name,node) in splashNodes {
      if name == splashName {
        node.isHidden = false
      } else {
        node.isHidden = true
      }
    }
  }
  
  func setupSplash() {
    splashNodes["TapToPlay"] = createSplash(name: "TAPTOPLAY",
      imageFileName: "GeometryFighter.scnassets/Textures/TapToPlay_Diffuse.png")
    splashNodes["GameOver"] = createSplash(name: "GAMEOVER",
      imageFileName: "GeometryFighter.scnassets/Textures/GameOver_Diffuse.png")
    showSplash(splashName: "TapToPlay")
  }
  
  func setupSounds() {
    game.loadSound("ExplodeGood",
      fileNamed: "GeometryFighter.scnassets/Sounds/ExplodeGood.wav")
    game.loadSound("SpawnGood",
      fileNamed: "GeometryFighter.scnassets/Sounds/SpawnGood.wav")
    game.loadSound("ExplodeBad",
      fileNamed: "GeometryFighter.scnassets/Sounds/ExplodeBad.wav")
    game.loadSound("SpawnBad",
      fileNamed: "GeometryFighter.scnassets/Sounds/SpawnBad.wav")
    game.loadSound("GameOver",
      fileNamed: "GeometryFighter.scnassets/Sounds/GameOver.wav")
  }
  
  override func awake(withContext context: Any?) {
    setupView()
    setupScene()
    setupCamera()
    setupHUD()
    setupSplash()
    setupSounds()
  }
  
  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
  }
  
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }
  
  @IBAction func handleTap(tapGesture: WKTapGestureRecognizer) {
    
    if game.state == .GameOver {
      return
    }
    
    if game.state == .TapToPlay {
      game.reset()
      game.state = .Playing
      showSplash(splashName: "")
      return
    }
    
    let touchLocation = tapGesture.locationInObject()
    let hitResults = self.scnInterface.hitTest(touchLocation, options: [:])
    
    if let result = hitResults.first {
      
      if result.node.name == "HUD" ||
        result.node.name == "GAMEOVER" ||
        result.node.name == "TAPTOPLAY" {
        return
      } else if result.node.name == "GOOD" {
        handleGoodCollision()
      } else if result.node.name == "BAD" {
        handleBadCollision()
      }
      
      createExplosion(geometry: result.node.geometry!,
                      position: result.node.presentation.position,
                      rotation: result.node.presentation.rotation)

      result.node.removeFromParentNode()
    }
  }
  
  func spawnShape() {
    let scale:CGFloat = 1.5
    
    var geometry: SCNGeometry
    switch ShapeType.random() {
    case .box:
      geometry = SCNBox(width: scale, height: scale, length: scale, chamferRadius: 0.0)
    case .sphere:
      geometry = SCNSphere(radius: scale * 0.5)
    case .pyramid:
      geometry = SCNPyramid(width: scale, height: scale, length: scale)
    case .torus:
      geometry = SCNTorus(ringRadius: scale * 0.5, pipeRadius: scale * 0.25)
    case .capsule:
      geometry = SCNCapsule(capRadius: scale * 0.3, height: scale * 2.5)
    case .cylinder:
      geometry = SCNCylinder(radius: scale * 0.3, height: scale * 2.5)
    case .cone:
      geometry = SCNCone(topRadius: scale * 0.25, bottomRadius: scale * 0.5, height: 1.0)
    case .tube:
      geometry = SCNTube(innerRadius: scale * 0.25, outerRadius: scale * 0.5, height: scale * 1.0)
    }
    let color = UIColor.random()
    geometry.materials.first?.diffuse.contents = color
    let geometryNode = SCNNode(geometry: geometry)
    geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
    
    let randomX:Float = Float.random(min: -2, max: 2)
    let randomY:Float = Float.random(min: 10, max: 18)
    let force = SCNVector3(x: randomX, y: randomY , z: 0)
    let position = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
    geometryNode.physicsBody?.applyForce(force, at: position, asImpulse: true)
    
    let trailEmitter = createTrail(color: color, geometry: geometry)
    geometryNode.addParticleSystem(trailEmitter)
    
    if color == UIColor.black {
      geometryNode.name = "BAD"
      game.playSound(scnScene.rootNode, name: "SpawnBad")
    } else {
      geometryNode.name = "GOOD"
      game.playSound(scnScene.rootNode, name: "SpawnGood")
    }
    
    scnScene.rootNode.addChildNode(geometryNode)
  }
  
  func cleanScene() {
    for node in scnScene.rootNode.childNodes {
      if node.presentation.position.y < -2 {
        node.removeFromParentNode()
      }
    }
  }
  
  func createTrail(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem {
    let trail = SCNParticleSystem(named: "Trail.scnp", inDirectory: nil)!
    trail.particleColor = color
    trail.emitterShape = geometry
    return trail
  }
  
  
  func handleGoodCollision() {
    game.score += 1
    game.playSound(scnScene.rootNode, name: "ExplodeGood")
  }
  
  func handleBadCollision() {
    game.lives -= 1
    game.playSound(scnScene.rootNode, name: "ExplodeBad")
    game.shakeNode(cameraNode)
    
    if game.lives <= 0 {
      game.saveState()
      showSplash(splashName: "GameOver")
      game.playSound(scnScene.rootNode, name: "GameOver")
      game.state = .GameOver
      scnScene.rootNode.runAction(SCNAction.waitForDurationThenRunBlock(5) { (node:SCNNode!) -> Void in
        self.showSplash(splashName: "TapToPlay")
        self.game.state = .TapToPlay
        })
    }
  }
  
  func createExplosion(geometry: SCNGeometry, position: SCNVector3,
                       rotation: SCNVector4) {
    let explosion =
      SCNParticleSystem(named: "Explode.scnp", inDirectory:
        nil)!
    explosion.emitterShape = geometry
    explosion.birthLocation = .surface
    let rotationMatrix =
      SCNMatrix4MakeRotation(rotation.w, rotation.x,
                             rotation.y, rotation.z)
    let translationMatrix =
      SCNMatrix4MakeTranslation(position.x, position.y, position.z)
    let transformMatrix =
      SCNMatrix4Mult(rotationMatrix, translationMatrix)
    scnScene.addParticleSystem(explosion, transform: transformMatrix)
  }
  
}

extension InterfaceController: SCNSceneRendererDelegate {
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time:
    TimeInterval) {
    
    if game.state == .Playing {
      if time > spawnTime {
        spawnShape()
        spawnTime = time + TimeInterval(Float.random(min: 0.2, max: 1.5))
      }
      cleanScene()
    }
    game.updateHUD()
  }
}
