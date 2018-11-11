//
//  MHPhoneModel.swift
//  MegaHack2018
//
//  Created by Vlad Bonta on 10/11/2018.
//  Copyright © 2018 Vlad Bonta. All rights reserved.
//

import Foundation

class MHPhoneModel: NSObject {
    var name: String = ""
    var phoneDescription: String = ""
    var capacity: MHCapacityModel = MHCapacityModel()
    var display: MHDisplayModel = MHDisplayModel()
    var size: MHSizeModel = MHSizeModel()
    var frontCamera: MHFrontCameraModel = MHFrontCameraModel()
    var backCamera: MHBackCameraModel = MHBackCameraModel()
    var connections: MHConnectionsModel = MHConnectionsModel()
    var chip: MHChipModel = MHChipModel()
    var authentications: MHAuthenticationModel = MHAuthenticationModel()
    var battery: MHBatteryModel = MHBatteryModel()
    var sensors: MHSensorsModel = MHSensorsModel()
    var simCard: MHSimCardModel = MHSimCardModel()
    var connectors: MHConnectorModel = MHConnectorModel()
    
}
