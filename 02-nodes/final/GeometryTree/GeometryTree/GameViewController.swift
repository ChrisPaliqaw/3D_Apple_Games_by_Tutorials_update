import UIKit
import SceneKit
class GameViewController: UIViewController {
    // MARK: - Nodes
    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
        setupCamera()
        spawnShape()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Setup
    
    func setupView() {
        scnView = self.view as? SCNView
        // 1
        scnView.showsStatistics = true
        // 2
        scnView.allowsCameraControl = true
        // 3
        scnView.autoenablesDefaultLighting = true
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnScene.background.contents =
            "GeometryFighter.scnassets/Textures/Background_Diffuse.jpg"
    }
    
    func setupCamera() {
        // 1
        cameraNode = SCNNode()
        // 2
        cameraNode.camera = SCNCamera()
        // 3
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        // 4
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    func spawnShape() {
        var geometry:SCNGeometry
        switch ShapeType.random() {
        case .box:
            geometry = SCNBox(width: 1.0,
                              height: 1.0,
                              length: 1.0,
                              chamferRadius: 0.0)
        case .sphere:
            geometry = SCNSphere(radius: 0.5)
        case .pyramid:
            geometry = SCNPyramid(width: 1.0,
                                  height: 1.0,
                                  length: 1.0)
        case .torus:
            geometry = SCNTorus(ringRadius: 0.5,
                                pipeRadius: 0.25)
        case .capsule:
            geometry = SCNCapsule(capRadius: 0.25,
                                  height: 1)
        case .cylinder:
            geometry = SCNCylinder(radius: 0.5,
                                   height: 1.0)
        case .cone:
            geometry = SCNCone(topRadius: 0.0,
                               bottomRadius: 0.5,
                               height: 1.0)
        case .tube:
            geometry = SCNTube(innerRadius: 0.25,
                               outerRadius: 0.5,
                               height: 1.0)
        }
        let geometryNode = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(geometryNode)
    }
}
