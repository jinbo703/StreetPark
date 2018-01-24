//
//  DetailViewController.swift
//  StreetPark
//
//  Created by John Nik on 1/22/18.
//  Copyright © 2018 johnik703. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class DetailViewController: UIViewController {

    var mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    var img_spot : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        return img
    }()
    
    lazy var btn_postSpot : UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor.rgb(red: 0, green: 122, blue: 225)
        btn.setTitle("Post Spot", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.addTarget(self, action: #selector(handlePostSpot), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViews()
    }
    
    private func setupViews() {
        
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(mapView)
        _ = mapView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.centerYAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        self.view.addSubview(img_spot)
        _ = img_spot.anchor(view.centerYAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0.5 * GAP30, leftConstant: 0.5 * GAP30, bottomConstant: GAP70, rightConstant: 0.5 * GAP30, widthConstant: 0, heightConstant: 0)
        
        self.view.addSubview(btn_postSpot)
        _ = btn_postSpot.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0.5 * GAP30, bottomConstant: 0.5 * GAP30, rightConstant: 0.5 * GAP30, widthConstant: 0, heightConstant: GAP40)

        customMaskWith(object: img_spot, radious: GAP10, borderWidth: nil, borderColor: nil)
        customMaskWith(object: btn_postSpot, radious: GAP05, borderWidth: nil, borderColor: nil)
    }

    @objc func handlePostSpot() {
        // post image and location to the server
        
        // after success post
        self.navigationController?.popViewController(animated: true)
        
    }
}
