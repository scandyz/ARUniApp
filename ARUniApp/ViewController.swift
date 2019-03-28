//
//  ViewController.swift
//  ARUniApp
//
//  Created by Никита Бычков on 10/03/2019.
//  Copyright © 2019 Никита Бычков. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let node = SCNNode()
    
    func singleMoveTo(x: CGFloat, y: CGFloat, z: CGFloat) {
        if let shipNode = sceneView.scene.rootNode.childNode(withName: "ship", recursively: true) {
            let move = SCNAction.moveBy(x: x, y: y, z: z, duration: 1)
            shipNode.runAction(move, forKey: "singlemove")
        }
        
    }
    
    func moveTo(x: CGFloat, y: CGFloat, z: CGFloat) {
        if let shipNode = sceneView.scene.rootNode.childNode(withName: "ship", recursively: true) {
            let move = SCNAction.moveBy(x: x, y: y, z: z, duration: 1)
            let moveLoop = SCNAction.repeatForever(move)
            shipNode.runAction(moveLoop, forKey: "moving")
        }

    }
    
    func stopAction(forKey: String) {
        if let shipNode = sceneView.scene.rootNode.childNode(withName: "ship", recursively: true) {
            shipNode.removeAction(forKey: "moving")
        }
    }
    
    @IBOutlet weak var forwardButton: UIButton!
    //    @IBAction func forwardButton(_ sender: UIButton) {
//        moveTo(x: 0, y: 0, z: 0.01)
//
//    }
    
    @IBAction func backButton(_ sender: Any) {
        moveTo(x: 0, y: 0, z: -0.01)
    }
    
    @IBAction func leftButton(_ sender: Any) {
        moveTo(x: 0.01, y: 0, z: 0)
    }
    
    @IBAction func rightButton(_ sender: Any) {
        moveTo(x: -0.01, y: 0, z: 0)
    }
    
    @IBAction func upButton(_ sender: Any) {
        moveTo(x: 0, y: 0.01, z: 0)
    }
    
    @IBAction func downButton(_ sender: Any) {
        moveTo(x: 0, y: -0.01, z: 0)
    }
    
    @objc func normalTap(_ sender: UIGestureRecognizer){
        print("Normal tap")
        singleMoveTo(x: 0, y: 0, z: 0.02)
    }
    
    @objc func longTap(_ sender: UIGestureRecognizer){
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            stopAction(forKey: "moving")
            //Do Whatever You want on End of Gesture
        }
        else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            moveTo(x: 0, y: 0, z: 0.02)
            //Do Whatever You want on Began of Gesture
        }
    }
    
    func moveGesture(for button: UIButton) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(normalTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        forwardButton.addGestureRecognizer(tapGesture)
        button.addGestureRecognizer(tapGesture)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        button.addGestureRecognizer(longGesture)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/GameScene.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        moveGesture(for: forwardButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        guard let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "Photos", bundle: Bundle.main) else {
            print("No images available")
            return
        }
        
        configuration.trackingImages = trackedImages
        configuration.maximumNumberOfTrackedImages = 1

        // Run the view's session 
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        if let imageAnchor = anchor as? ARImageAnchor {
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)


            plane.firstMaterial?.diffuse.contents = UIColor.init(red: 105.0, green: 160.0, blue: 53.0, alpha: 0.0)

            let planeNode = SCNNode(geometry: plane)
            
            //planeNode.eulerAngles.x = -.pi/2
            
            let forestScene = SCNScene(named: "art.scnassets/Cloud.scn")!
            let forestNode = forestScene.rootNode
            forestNode.position = SCNVector3Zero
            
            let shipScene = SCNScene(named: "art.scnassets/ship.scn")!
            let shipNode = shipScene.rootNode.childNodes.first!
            shipNode.position = SCNVector3Zero
            shipNode.position.y = 0.01

            //flight(node: shipNode)
            shipNode.name = "ship"
            
            planeNode.addChildNode(forestNode)
            planeNode.addChildNode(shipNode)
            
            self.node.addChildNode(planeNode)
            
        }
        
        return self.node
    }
    

    
    func flight(node : SCNNode) {
        node.eulerAngles = SCNVector3(0.0, .pi, 0.0)
        let moveUp = SCNAction.moveBy(x: 0.0, y: 0.08, z: 0.0, duration: 2)
        moveUp.timingMode = .easeInEaseOut
        let moveDown = moveUp.reversed()
        let moveSeqeunce = SCNAction.sequence([moveUp, moveDown])
        let moveLoop = SCNAction.repeatForever(moveSeqeunce)
        node.runAction(moveLoop)
    }
    
    
}
