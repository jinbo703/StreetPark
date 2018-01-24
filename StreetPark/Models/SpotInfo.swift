//
//  SpotInfo.swift
//  StreetPark
//
//  Created by John Nik on 1/20/18.
//  Copyright © 2018 johnik703. All rights reserved.
//

import UIKit

class SpotInfo: NSObject {

    var spot_lat: Double?
    var spot_lon: Double?
    var spot_image: UIImage?
    var spot_timeFlag: Int?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        spot_lat = dictionary["spot_lat"] as? Double
        spot_lon = dictionary["spot_lon"] as? Double
        spot_timeFlag = dictionary["spot_timeFlag"] as? Int
        
        // convert NSData to image here
        spot_image = dictionary["spot_image"] as? UIImage       
        
    }
}
