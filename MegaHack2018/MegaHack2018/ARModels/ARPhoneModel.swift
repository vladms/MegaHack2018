//
//  File.swift
//  MegaHack2018
//
//  Created by Vlad Bonta on 10/11/2018.
//  Copyright © 2018 Vlad Bonta. All rights reserved.
//

import Foundation
import ARKit

enum AnimationType {
    case still
    case presentationRotation
    
}

enum PhoneVersion {
    case iPhone7
    case iPhone7Plus
    case iPhone8
    case iPhone8Plus
    case iPhoneX
    case iPhoneXS
}

class ARPhoneModel: NSObject {
    var phoneModel: MHPhoneModel!
    var phoneNode: MHPhoneNode!
    
    var phoneSceneNode: SCNNode! {
        didSet {
            self.setup()
        }
    }
    
    var backCaseNode: SCNNode!
    var frontCaseNode: SCNNode!
    var bottomTrimNode: SCNNode!
    var topTrimNode: SCNNode!
    var screenNode: SCNNode!
    var checkpoints: [SCNNode]! = []
    
    var screenNodeDefaultGeometry: SCNGeometry!
    var nodeSize: CGSize!
    var animationType: AnimationType = .still
    var currentAngleY: Float = 0.0
    var phoneVersion: PhoneVersion = .iPhone7 {
        didSet{
            self.setupPhoneDetails()
        }
    }
    var originalAngleY: Float = 0.0 {
        didSet {
            self.currentAngleY = originalAngleY
        }
    }
    var isRotating = false
    var checkpointsVisible = true
    
    override init() {
        self.phoneModel = MHPhoneModel()
        self.phoneSceneNode = SCNNode()
        self.phoneNode = MHPhoneNode()
        self.nodeSize = CGSize(width: 0.0, height: 0.0)
    }
    
    func setup() {
        self.backCaseNode = self.phoneSceneNode.childNode(withName: "BackCase", recursively: true)
        self.frontCaseNode = self.phoneSceneNode.childNode(withName: "FrontCase", recursively: true)
        self.bottomTrimNode = self.phoneSceneNode.childNode(withName: "TrimBottom", recursively: true)
        self.topTrimNode = self.phoneSceneNode.childNode(withName: "TrimTop", recursively: true)
        self.screenNode = self.phoneSceneNode.childNode(withName: "Screen", recursively: true)
        let screenCheckpoint = self.phoneSceneNode.childNode(withName: "ScreenCheckpoint", recursively: true)
        let batteryCheckpoint = self.phoneSceneNode.childNode(withName: "BatteryCheckpoint", recursively: true)
        self.checkpoints.append(screenCheckpoint!)
        self.checkpoints.append(batteryCheckpoint!)
        
        self.screenNodeDefaultGeometry = self.screenNode.geometry
        self.hideCheckpoints(hide: true)
    }
    
    func setupPhoneDetails() {
        switch self.phoneVersion {
        case .iPhone7:
            self.phoneModel.name = "iPhone 7"
            self.phoneModel.display.diagonal = 11.938
            self.phoneModel.battery.talkTime = 14
            self.phoneModel.battery.internetUse = 12
            self.phoneModel.battery.videoPlayback = 13
            self.phoneModel.battery.audioPlayback = 40
            self.phoneModel.battery.chargingTime = 2.08
            self.phoneModel.battery.usageTime = 12.0
            self.phoneModel.chip.name = "A10 Fusion Chip"
            self.phoneModel.chip.benchmarkScore = 176342
            self.checkpoints.forEach { node in
                node.removeFromParentNode()
            }
        
        case .iPhone7Plus:
            self.phoneModel.name = "iPhone 7 Plus"
            self.phoneModel.display.diagonal = 13.97
            self.phoneModel.battery.talkTime = 21
            self.phoneModel.battery.internetUse = 13
            self.phoneModel.battery.videoPlayback = 14
            self.phoneModel.battery.audioPlayback = 60
            self.phoneModel.battery.chargingTime = 2.08
            self.phoneModel.battery.usageTime = 13.0
            self.phoneModel.chip.name = "A10 Fusion Chip"
            self.phoneModel.chip.benchmarkScore = 183701
        case .iPhoneXS:
            self.phoneModel.name = "iPhone XS"
            self.phoneModel.display.diagonal = 14.732
            break
        default: break
        }
    }
    
    func animate(type: AnimationType) {
        switch type {
        case .still:
            self.phoneNode.eulerAngles = SCNVector3Make(0.0, self.originalAngleY, self.phoneNode.eulerAngles.z)
            self.phoneNode.removeAllActions()
            self.hideCheckpoints(hide: false)
        case .presentationRotation:
            self.phoneNode.eulerAngles = SCNVector3Make(Float.pi / 20.0, self.phoneNode.eulerAngles.y, self.phoneNode.eulerAngles.z)
            let rotateAction = SCNAction.rotateBy(x: 0.0, y: CGFloat(self.phoneNode.eulerAngles.y) + CGFloat.pi, z: 0.0, duration: 5.0)
            self.phoneNode.runAction(SCNAction.repeatForever(rotateAction))
        default:
            break
        }
    }
    
    func change(phoneColor: PhoneColor) {
        switch phoneColor {
        case .silver:
            self.backCaseNode.geometry?.firstMaterial?.diffuse.contents = UIColor.silverColor
            self.frontCaseNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            self.bottomTrimNode.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
            self.topTrimNode.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray

        case .spaceGray:
            self.backCaseNode.geometry?.firstMaterial?.diffuse.contents = UIColor.spaceGrayColor
            self.frontCaseNode.geometry?.firstMaterial?.diffuse.contents = UIColor.spaceGrayColor
            self.bottomTrimNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
            self.topTrimNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black

        case .gold:
            self.backCaseNode.geometry?.firstMaterial?.diffuse.contents = UIColor.goldColor
            self.frontCaseNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            self.bottomTrimNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            self.topTrimNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        }
    }
    
    func hideCheckpoints(hide: Bool) {
        if hide && checkpointsVisible {
            self.checkpoints.forEach { node in
                node.isHidden = true
            }
            checkpointsVisible = !hide
        } else if !hide && !checkpointsVisible {
            self.checkpoints.forEach { node in
                node.isHidden = !true
            }
            self.screenNode.position = SCNVector3Zero
            self.screenNode.geometry = screenNodeDefaultGeometry
            checkpointsVisible = !hide
        }
    }
    
    func animateScreen(distance: CGFloat, right: Bool) {
        var XMovement = distance + self.currentScreenSize().width / 2.0
        XMovement = right ? XMovement: -XMovement
        let yOffset = right ? 0.0 : 1.0
        self.screenNode.runAction(SCNAction.moveBy(x: XMovement, y: CGFloat(-3.0 + yOffset), z: 0.0, duration: 1.0))
        self.hideCheckpoints(hide: true)
    }
    
    func currentSize() -> CGSize {
        let (minExtents, maxExtents) = self.phoneSceneNode.boundingBox
        let width = (maxExtents.x - minExtents.x) * phoneSceneNode.scale.x
        let height = (maxExtents.y - minExtents.y) * phoneSceneNode.scale.y
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }

    func currentScreenSize() -> CGSize {
        let (minExtents, maxExtents) = self.screenNode.boundingBox
        let width = (maxExtents.x - minExtents.x) * screenNode.scale.x
        let height = (maxExtents.y - minExtents.y) * screenNode.scale.y
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
    
}
