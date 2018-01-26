//
//  CustomAnnotation.swift
//  StreetPark
//
//  Created by John Nik on 1/20/18.
//  Copyright © 2018 johnik703. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class CustomAnnotation: MKPointAnnotation {
    var img_spot_url: String?
    var timeFlag: Int?
    
    init(info: SpotInfo) {
        super.init()
        timeFlag = info.spot_timeFlag
        img_spot_url = info.spot_image_url
    }
}
