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
    var spot_image_url: String?
    var spot_timeFlag: Int?
    
    init(dictionary: NSDictionary) {
        super.init()
        
        spot_lat = (dictionary["lat"] as? NSString)?.doubleValue
        spot_lon = (dictionary["lon"] as? NSString)?.doubleValue
        spot_timeFlag = dictionary["flag"] as? Int
        
        // convert NSData to image here
        spot_image_url = dictionary["photo"] as? String
        
    }
}
