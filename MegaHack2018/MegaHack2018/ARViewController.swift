//
//  ViewController.swift
//  MegaHack2018
//
//  Created by Vlad Bonta on 10/11/2018.
//  Copyright © 2018 Vlad Bonta. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

enum ARStatus {
    case notDefined
    case scanning
    case planeScanned
    case comparisonSceneSet
}

let distance: Float = 0.06
let pivotXOfsset: Float = -0.14
let pivotYOfsset: Float = -0.12

class ARViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, MPAREditProductDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak private var productInfoView: ARProductInfoView!
    @IBOutlet weak private var bottomContainerConstraint: NSLayoutConstraint!
    @IBOutlet weak private var productInfoViewBottomConstraint: NSLayoutConstraint!
    
    private var containerNode: SCNNode = SCNNode()
    private var arComparingPhone: ARPhoneModel = ARPhoneModel()
    private var arPersonalPhone: ARPhoneModel = ARPhoneModel()
    private var ARStatus: ARStatus = .notDefined
    private var planeAnchor: ARPlaneAnchor?
    private var hitTestNode: SCNNode?
    private var planeNode: SCNNode?
    private var comparisonScene: ARComparisonScene = ARComparisonScene()
    private var bottomControlVC: ARBottomController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the aview's delegate
        self.sceneView.delegate = self
        self.sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        self.sceneView.showsStatistics = false
        self.sceneView.debugOptions = SCNDebugOptions.showFeaturePoints
        
        self.setupGestures()
        self.setupPhone()
        self.setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedScene(withGestureRecognizer:)))
        self.sceneView.addGestureRecognizer(tap)

        let productInfoTap = UITapGestureRecognizer(target: self, action: #selector(self.closeInfoView))
        self.productInfoView.addGestureRecognizer(productInfoTap)
        
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateNode(_:)))
        self.sceneView.addGestureRecognizer(rotateGesture)
    }
    
    private func setupPhone() {
        var scene = SCNScene(named: "art.scnassets/iPhone7/iPhone7Plus.scn")
        
        if let rootNode = scene?.rootNode {
            rootNode.pivot = SCNMatrix4Translate(SCNMatrix4Identity, pivotXOfsset, pivotYOfsset, 0.0)
            self.arComparingPhone = ARPhoneModel()
            self.arComparingPhone.phoneSceneNode = rootNode
            self.arComparingPhone.phoneVersion = .iPhone7Plus
        }
        
        scene = SCNScene(named: "art.scnassets/iPhone7/iPhone7.scn")
        
        if let rootNode = scene?.rootNode {
            rootNode.pivot = SCNMatrix4Translate(SCNMatrix4Identity, pivotXOfsset, pivotYOfsset, 0.0)
            self.arPersonalPhone = ARPhoneModel()
            self.arPersonalPhone.phoneSceneNode = rootNode
            self.arPersonalPhone.phoneVersion = .iPhone7
        }
    }
    
    
    private func setupScene() {
        self.comparisonScene.phoneScenes.forEach { sceneName in
            let scene = SCNScene(named: sceneName)
            let phone = ARPhoneModel()
            if let rootNode = scene?.rootNode {
                rootNode.pivot = SCNMatrix4Translate(SCNMatrix4Identity, -0.8, -0.5, 0.0)
                
                phone.phoneSceneNode = rootNode
            }
            
            self.comparisonScene.phones.append(phone)
        }
    }
    
    @objc func tappedScene(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        
        switch self.ARStatus {
        case .planeScanned:
            self.comparisonLocationSelected(tapLocation: tapLocation)
        case .comparisonSceneSet:
            self.sceneViewTapped(at: tapLocation)
        default:
            break
        }
        
    }
    
    /// Rotates An SCNNode Around It's YAxis
    ///
    /// - Parameter gesture: UIRotationGestureRecognizer
    @objc func rotateNode(_ gesture: UIRotationGestureRecognizer){
        
        //1. Get The Current Rotation From The Gesture
        let rotation = Float(gesture.rotation)
        
        //2. If The Gesture State Has Changed Set The Nodes EulerAngles.y
        if gesture.state == .changed{
            self.arComparingPhone.isRotating = true
            self.arComparingPhone.phoneSceneNode.eulerAngles.y = self.arComparingPhone.currentAngleY + rotation
            
            self.arPersonalPhone.isRotating = true
            self.arPersonalPhone.phoneSceneNode.eulerAngles.y = self.arPersonalPhone.currentAngleY + rotation
            
        }
        //3. If The Gesture Has Ended Store The Last Angle Of The Cube
        if(gesture.state == .ended) {
            self.arComparingPhone.currentAngleY = self.arComparingPhone.phoneSceneNode.eulerAngles.y
            self.arComparingPhone.isRotating = false
            
            self.arPersonalPhone.currentAngleY = self.arPersonalPhone.phoneSceneNode.eulerAngles.y
            self.arPersonalPhone.isRotating = false
        }
    }
    
    private func comparisonLocationSelected(tapLocation: CGPoint) {
        if self.arComparingPhone.phoneNode.parent != nil {
            self.arComparingPhone.phoneNode.removeFromParentNode()
            self.setupPhone()
        }
        
        if self.arPersonalPhone.phoneNode.parent != nil {
            self.arPersonalPhone.phoneNode.removeFromParentNode()
            self.setupPhone()
        }
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
        self.arComparingPhone.phoneNode.position = SCNVector3(x,y,z)
        
        var cameraYAngle = self.sceneView.session.currentFrame?.camera.eulerAngles.y ?? 0.0
        cameraYAngle += Float.pi
        
        self.arComparingPhone.phoneNode.eulerAngles = SCNVector3Make(self.arComparingPhone.phoneNode.eulerAngles.x, cameraYAngle, self.arComparingPhone.phoneNode.eulerAngles.z)
        self.arComparingPhone.originalAngleY = cameraYAngle
        self.arComparingPhone.phoneNode.localTranslate(by: SCNVector3Make(-distance, 0.0, 0.0))
        
        self.arComparingPhone.phoneNode.addChildNode(self.arComparingPhone.phoneSceneNode)
        
        self.arComparingPhone.animate(type: .presentationRotation)
        
        
        
        self.arPersonalPhone.phoneNode.position = SCNVector3(x,y,z)
        
        self.arPersonalPhone.phoneNode.eulerAngles = SCNVector3Make(self.arPersonalPhone.phoneNode.eulerAngles.x, cameraYAngle, self.arPersonalPhone.phoneNode.eulerAngles.z)
        self.arPersonalPhone.originalAngleY = cameraYAngle
        self.arPersonalPhone.phoneNode.localTranslate(by: SCNVector3Make(distance, 0.0, 0.0))
        
        self.arPersonalPhone.phoneNode.addChildNode(self.arPersonalPhone.phoneSceneNode)
        
        self.arPersonalPhone.animate(type: .presentationRotation)
        
        self.containerNode.addChildNode(self.arPersonalPhone.phoneNode)
        self.containerNode.addChildNode(self.arComparingPhone.phoneNode)
        self.sceneView.scene.rootNode.addChildNode(self.containerNode)
        
        
        self.ARStatus = .comparisonSceneSet
        
        self.bottomContainerConstraint.constant = 0.0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func sceneViewTapped(at tapLocation: CGPoint) {
        let hitTestOptions: [SCNHitTestOption : Any] = [SCNHitTestOption.rootNode: self.containerNode, SCNHitTestOption.boundingBoxOnly: true]
        let testResults = sceneView.hitTest(tapLocation, options: hitTestOptions)
        
        if testResults.count > 0 {
            
            let hitTestNode = testResults.first?.node
            var phoneNode = hitTestNode
            
            if let phoneNode = phoneNode, self.arComparingPhone.checkpoints.contains(phoneNode) {
                switch phoneNode.name {
                case "ScreenCheckpoint":
                    self.bottomControlVC?.changeBottomActions(type: .display(size1: self.arPersonalPhone.phoneModel.display.diagonal, size2: self.arComparingPhone.phoneModel.display.diagonal))
                    self.arComparingPhone.animateScreen(distance: CGFloat(distance), right: true)
                    self.arPersonalPhone.animateScreen(distance: CGFloat(distance), right: false)

                    case "BatteryCheckpoint":
                    self.playPerformaceTest()
                    self.arPersonalPhone.hideCheckpoints(hide: true)
                    self.arComparingPhone.hideCheckpoints(hide: true)
                default:
                    break
                }
            } else {
                while !(phoneNode?.isKind(of: MHPhoneNode.self) ?? false) {
                    phoneNode = phoneNode?.parent
                }
                
                    self.arComparingPhone.animate(type: .still)
                    self.arPersonalPhone.animate(type: .still)

                self.arPersonalPhone.hideCheckpoints(hide: false)
                self.arComparingPhone.hideCheckpoints(hide: false)
                
                self.bottomControlVC?.changeBottomActions(type: .buy)
            }
            //A phone was tapped
            
            //TODO - Check the hitted point: if something from phone or the phone
            
        } else {
            self.bottomControlVC?.changeBottomActions(type: .buy)
            self.arPersonalPhone.hideCheckpoints(hide: false)
            self.arComparingPhone.hideCheckpoints(hide: false)
        }
        
    }
    
    
    
    private func planeDetected() {
        self.ARStatus = .planeScanned
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor.isKind(of: ARPlaneAnchor.self) {
            //            planeAnchor = anchor as? ARPlaneAnchor
            //            let planeGridMaterial = SCNMaterial()
            //            planeGridMaterial.diffuse.contents = UIImage(named: "planeGrid")
            //
            //            let planeMaterial2 = SCNMaterial()
            //            planeMaterial2.diffuse.contents = UIColor.red
            //            planeMaterial2.isDoubleSided = true
            //
            //            let plane = SCNPlane(width: CGFloat((planeAnchor?.extent.x)!), height: CGFloat((planeAnchor?.extent.z)!))
            //
            //            plane.materials = [planeMaterial2]
            //
            //            planeNode = SCNNode(geometry: plane)
            //            planeNode?.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1.0, 0.0, 0.0)
            ////            planeNode?.position = SCNVector3.init((planeAnchor?.center)!)
            ////            self.sceneView.scene.rootNode.addChildNode(planeNode!)
            //            node.addChildNode(planeNode!)
            
            
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            
            let width = CGFloat(planeAnchor.extent.x)
            let height = CGFloat(planeAnchor.extent.z)
            let plane = SCNPlane(width: width, height: height)
            
            plane.materials.first?.diffuse.contents = UIColor.red.withAlphaComponent(0.5)
            
            let planeNode = SCNNode(geometry: plane)
            
            let x = CGFloat(planeAnchor.center.x)
            let y = CGFloat(planeAnchor.center.y)
            let z = CGFloat(planeAnchor.center.z)
            planeNode.position = SCNVector3(x,y,z)
            planeNode.eulerAngles.x = -.pi / 2
            
            node.addChildNode(planeNode)
            
            self.planeDetected()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        // 1
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func editProductActionTapped(_ action: MHAREditProductAction) {
        switch action {
        case .buy:
            
            break
            
        case .compare:
            self.showProductInfo(show: true)
            break
            
        case .changeColor:
            self.bottomControlVC?.changeBottomActions(type: .changeColor)
        case .changePhone:
            break
            
        default:
            break
        }
    }
    
    private func playPerformaceTest() {
        if let videoURL = Bundle.main.url(forResource: "Antutu", withExtension: "mp4"){
            self.setupVideoOnNode(self.arComparingPhone.screenNode, fromURL: videoURL)
        }
        
        if let videoURL = Bundle.main.url(forResource: "AntutuSlow", withExtension: "mp4"){
            self.setupVideoOnNode(self.arPersonalPhone.screenNode, fromURL: videoURL)

        }
        
    }
    
    func setupVideoOnNode(_ node: SCNNode, fromURL url: URL){
        var videoPlayerNode: SKVideoNode!
        
        let videoPlayer = AVPlayer(url: url)
        videoPlayerNode = SKVideoNode(avPlayer: videoPlayer)
        videoPlayerNode.yScale = -1
        
        let spriteKitScene = SKScene(size: CGSize(width: 600, height: 300))
        spriteKitScene.scaleMode = .aspectFit
        videoPlayerNode.position = CGPoint(x: spriteKitScene.size.width/2, y: spriteKitScene.size.height/2)
        videoPlayerNode.size = spriteKitScene.size
        spriteKitScene.addChild(videoPlayerNode)
        
      
        node.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
        
        videoPlayerNode.play()
    }
    
    func phoneColorChanged(_ phoneColor: PhoneColor) {
        self.bottomControlVC?.resetActionsImages()
        self.arComparingPhone.change(phoneColor: phoneColor)
    }
    
    @objc private func closeInfoView() {
        self.showProductInfo(show: false)
    }
    
    private func showProductInfo(show: Bool) {
        if show {
            self.productInfoViewBottomConstraint.constant = 0.0
        } else {
            self.productInfoViewBottomConstraint.constant = -self.view.frame.size.height
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "EmbedBottomControlViewController") {
            bottomControlVC = segue.destination as? ARBottomController
            bottomControlVC?.delegate = self
        }
    }
}


extension simd_float4x4 {
    var translation: SCNVector3 {
        return SCNVector3Make(self.columns.3.x, self.columns.3.y, self.columns.3.z)
    }
}
