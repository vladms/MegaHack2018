//
//  ARComparisonScene.swift
//  MegaHack2018
//
//  Created by Vlad Bonta on 10/11/2018.
//  Copyright © 2018 Vlad Bonta. All rights reserved.
//

import Foundation
import ARKit

class ARComparisonScene: NSObject {
    var phones: [ARPhoneModel] = []
    var phoneScenes: [String] = []
    var comparisonSceneNode = SCNNode()
}
