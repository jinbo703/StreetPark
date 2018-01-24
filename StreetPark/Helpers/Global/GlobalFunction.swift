//
//  GlobalFunction.swift
//  StreetPark
//
//  Created by John Nik on 1/19/18.
//  Copyright © 2018 johnik703. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

func customMaskWith(object : AnyObject, radious : CGFloat, borderWidth: CGFloat?, borderColor: CGColor?){
    object.layer.cornerRadius = radious
    if let width = borderWidth {
        object.layer.borderWidth = width
    }
    if let color = borderColor {
        object.layer.borderColor = color
    }
    object.layer.masksToBounds = true
}


