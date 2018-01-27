//
//  DirectionViewController.swift
//  StreetPark
//
//  Created by PAC on 1/27/18.
//  Copyright © 2018 PAC. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class DirectionViewController: UIViewController {

    var mapView : MyMapView = {
        let map = MyMapView()
        return map
    }()
    
    var btn_current: MKUserTrackingButton = {
        let btn = MKUserTrackingButton()
        btn.backgroundColor = UIColor.white
        return btn
    }()
    
    var view_bottom : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.alpha = 0.95
        return view
    }()
    
    var lbl_distance: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.black
        lbl.font = UIFont.systemFont(ofSize: FONTSIZE17)
        return lbl
    }()
    
    var lbl_expectedTime: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.black
        lbl.font = UIFont.systemFont(ofSize: FONTSIZE17)
        return lbl
    }()
    
    var currentLocation: MKUserLocation?
    var destination: MKMapItem?
    var desti_cood: CLLocationCoordinate2D?
    var updateFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = false
        self.view.backgroundColor = UIColor.white
        
        self.setupViews()
        self.loadMapView()
        
    }

    func setupViews() {
        view.addSubview(mapView)
        _ = mapView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: NAVI_HEIGHT, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        view.addSubview(btn_current)
        _ = btn_current.anchor(mapView.topAnchor, left: nil, bottom: nil, right: mapView.rightAnchor, topConstant: GAP30, leftConstant: 0, bottomConstant: 0, rightConstant: GAP05, widthConstant: GAP50, heightConstant: GAP50)
        btn_current.mapView = self.mapView
        customMaskWith(object: btn_current, radious: GAP10, borderWidth: nil, borderColor: nil)
        
        view.addSubview(view_bottom)
        _ = view_bottom.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: GAP80)
        
        view.addSubview(lbl_distance)
        _ = lbl_distance.anchor(view_bottom.topAnchor, left: view_bottom.leftAnchor, bottom: nil, right: view_bottom.rightAnchor, topConstant: GAP20, leftConstant: GAP20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: GAP20)
        
        view.addSubview(lbl_expectedTime)
        _ = lbl_expectedTime.anchor(nil, left: view_bottom.leftAnchor, bottom: view_bottom.bottomAnchor, right: view_bottom.rightAnchor, topConstant: 0, leftConstant: GAP20, bottomConstant: GAP10, rightConstant: 0, widthConstant: 0, heightConstant: GAP20)
        customMaskWith(object: view_bottom, radious: GAP10, borderWidth: nil, borderColor: nil)
        
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d min", hours, minutes)
    }
    
    private func loadMapView() {
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = true
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        
        
        if let coodinate = self.desti_cood {
            let spot_mark = MKPointAnnotation()
            spot_mark.coordinate = coodinate
            self.mapView.addAnnotation(spot_mark)
        }
    }
    
    func getDirections(destination: MKMapItem) {
        
        let sourcePlacemark = MKPlacemark(coordinate: (self.currentLocation?.coordinate)!)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        let request = MKDirectionsRequest()
        request.source = sourceMapItem
        request.destination = destination
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        
        directions.calculate { (response, error) in
            if error != nil {
                print(error!)
            }else{
                
                guard let response = response else { return }
                guard let primaryRoute = response.routes.first else { return }
                let overlays = self.mapView.overlays
                self.mapView.removeOverlays(overlays)
                
                self.mapView.add(primaryRoute.polyline, level: .aboveRoads)
                
                for next in primaryRoute.steps {
                    print(next.instructions)
                }
                
                let distance = primaryRoute.distance
                self.lbl_distance.text = String(format: "Distance : %.3f mile", Utility.convertCLLocationDistanceToMiles(targetDistance: distance))
                let time = primaryRoute.expectedTravelTime
                self.lbl_expectedTime.text = "Expected Travel Time : " + self.stringFromTimeInterval(interval: time)
                
            }
        }
    }

}

extension DirectionViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        self.currentLocation = userLocation
        if !updateFlag {
            updateFlag = true
            let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: center, span: span)
            self.mapView.setRegion(region, animated: false)
            if let desti = self.destination {
                self.getDirections(destination: desti)
            }
        }
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print("Error --->", error)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .blue
        renderer.lineWidth = 10
        return renderer
        
    }
}


