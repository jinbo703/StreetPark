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
import SVProgressHUD

class DetailViewController: UIViewController {

    var mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    var img_spot : UIImageView = {
        let img = UIImageView()
        let image = UIImage(named: "trackMe")
        img.image = image
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
    
    var btn_user : MKUserTrackingButton = {
        let btn = MKUserTrackingButton()
        btn.backgroundColor = UIColor.white
        return btn
    }()
    
    var currentLocation: MKUserLocation?
    var userIdentifier = "defaultUser_simulater"
    var spotLocation: CLLocationCoordinate2D?
    var updateFlag = false
    
    //MARK: -- ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViews()
        self.loadMapView()
    }
  
    private func setupViews() {
        
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(mapView)
        _ = mapView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.centerYAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        view.addSubview(btn_user)
        _ = btn_user.anchor(nil, left: nil, bottom: self.mapView.bottomAnchor, right: self.mapView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: GAP20, rightConstant: GAP05, widthConstant: GAP50, heightConstant: GAP50)
        btn_user.mapView = self.mapView
        
        self.view.addSubview(img_spot)
        _ = img_spot.anchor(view.centerYAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0.5 * GAP30, leftConstant: 0.5 * GAP30, bottomConstant: GAP70, rightConstant: 0.5 * GAP30, widthConstant: 0, heightConstant: 0)
        
        self.view.addSubview(btn_postSpot)
        _ = btn_postSpot.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0.5 * GAP30, bottomConstant: 0.5 * GAP30, rightConstant: 0.5 * GAP30, widthConstant: 0, heightConstant: GAP40)

        customMaskWith(object: btn_user, radious: GAP10, borderWidth: nil, borderColor: nil)
        customMaskWith(object: img_spot, radious: GAP10, borderWidth: nil, borderColor: nil)
        customMaskWith(object: btn_postSpot, radious: GAP05, borderWidth: nil, borderColor: nil)
    }
    
    private func loadMapView() {
        
        mapView.delegate = self
        mapView.isUserInteractionEnabled = true
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true
        mapView.showsBuildings = true
    }
    
    func checkNetwork() {
        if !Reachability.isConnectedToNetwork(){
            let str_title = "Warning"
            let str_message = "Connection Error!\nPlease check your internet connection"
            let alert = UIAlertController(title: str_title, message: str_message, preferredStyle: .alert)
            let okaction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okaction)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func resizeImage(image: UIImage) -> UIImage {
        var actualHeight: Float = Float(image.size.height)
        var actualWidth: Float = Float(image.size.width)
        let maxHeight: Float = Float(DEVICE_HEIGHT) / 2
        let maxWidth: Float = Float(DEVICE_WIDTH) / 2
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 1.0
        //50 percent compression
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        
        let rect = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImageJPEGRepresentation(img!,CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!)!
    }
}

extension DetailViewController {
    
    @objc func handlePostSpot() {
        
        self.checkNetwork()
        
        if let userId = UIDevice.current.identifierForVendor?.uuidString {
            self.userIdentifier = userId
        }
        
        if let coodi = self.spotLocation {
            
            SVProgressHUD.show()
            
            let spotImage = UIImageJPEGRepresentation(resizeImage(image: self.img_spot.image!), 1.0)?.base64EncodedString(options: .lineLength64Characters)
            
            let timeStamp = Int(NSDate().timeIntervalSince1970)
            
            let paramDic = ["photo": spotImage!,
                            "userid": self.userIdentifier,
                            "latitude": coodi.latitude,
                            "longitude":coodi.longitude,
                            "timestamp": timeStamp] as [String : Any]
            
            API?.executeHTTPRequest(Post, url: UPLOADSPOT_URL, parameters: paramDic, completionHandler: { (responseDic) in
                if let response = responseDic {
                    self.parseData(responseDic: response)
                }
            }, errorHandler: { (error) in
                if error != nil {

                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()

                        let str_title = "Warning"
                        let str_message = "Something went wrong. Please try again."
                        let alert = UIAlertController(title: str_title, message: str_message, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
        }
    }
    
    private func parseData(responseDic: [AnyHashable: Any]) {
        if let status = responseDic["status"] as? String, status == "SUCCESS" {
            SVProgressHUD.dismiss()
            self.navigationController?.popViewController(animated: true)
        }
    }
}


extension DetailViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
        case .starting:
            print("Start")
        case .ending:
            if let cood = view.annotation?.coordinate {
                self.spotLocation = cood
            }
        case .canceling:
            print("Canceled")
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
       
        self.currentLocation = userLocation
        self.spotLocation = userLocation.coordinate
        
        if !updateFlag {
            updateFlag = true
            
            let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            let span = MKCoordinateSpanMake(0.005, 0.005)
            let region = MKCoordinateRegion(center: center, span: span)
            self.mapView.setRegion(region, animated: true)
            
            let spot_mark = MKPointAnnotation()
            spot_mark.coordinate = userLocation.coordinate
            self.mapView.addAnnotation(spot_mark)
            
//            mapView.showsUserLocation = false
        }
    }

    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print("This is map loading error -->", error)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        view.setDragState(.dragging, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            self.mapView.showsUserLocation = false
            return nil
        }

        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.isDraggable = true
        }
        else {
            pinView?.annotation = annotation
        }

        pinView?.canShowCallout = false
        return pinView
    }
}
