//
//  StyleGuideManager.swift
//  StreetPark
//
//  Created by John Nik on 1/19/18.
//  Copyright © 2018 johnik703. All rights reserved.
//

import UIKit

public class StyleGuideManager {
    private init(){}
    
    static let sharedInstance : StyleGuideManager = {
        let instance = StyleGuideManager()
        return instance
    }()
    
    //default
    static let realyfeDefaultGreenColor = UIColor(r: 0, g: 181, b: 172)
    static let realyfeDefaultBlueColor = UIColor(r: 19, g: 163, b: 207)
    
    //intro
    static let signinButtonColor = UIColor(r: 19, g: 163, b: 207)
    static let currentPageIndicatorTintColor = UIColor(r: 247, g: 154, b: 27)
    static let currentPageIndicatorGreenTintColor = UIColor(r: 19, g: 163, b: 207)
    static let defaultGreenTintColor = UIColor(r: 132, g: 152, b: 66)
    
    //intro textcolor
    static let firstTextColor = UIColor(r: 95, g: 123, b: 255)
    static let secondTextColor = UIColor(r: 181, g: 95, b: 255)
    static let thirdTextColor = UIColor(r: 255, g: 95, b: 164)
    
    //button colors
    static let signinButtonBackgroundColor = UIColor(r: 19, g: 163, b: 207)
    
    //status bar colors
    static let loginStatusBarColor = UIColor(r: 215, g: 214, b: 213)
    static let signupStatusBarColor = UIColor(r: 65, g: 65, b: 65)
    
    func loginFontLarge() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 30)!
        
    }
}

