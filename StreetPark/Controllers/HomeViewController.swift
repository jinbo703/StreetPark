//
//  HomeViewController.swift
//  StreetPark
//
//  Created by John Nik on 1/21/18.
//  Copyright © 2018 johnik703. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class Utility {
    class func convertCLLocationDistanceToMiles ( targetDistance : CLLocationDistance?) -> CLLocationDistance {
        return  targetDistance!*0.00062137
    }
    class func convertCLLocationDistanceToKiloMeters ( targetDistance : CLLocationDistance?) -> CLLocationDistance {
        return  targetDistance!/1000
    }
}


class HomeViewController: UIViewController {
    
    var mapView : MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    lazy var btn_markSpot : UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor.rgb(red: 0, green: 122, blue: 225)
        btn.setTitle("Mark Spot", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.addTarget(self, action: #selector(handleMarkSpot), for: .touchUpInside)
        return btn
    }()
    
    var swipeView: UIView = {
        let swipeView = UIView()
        swipeView.backgroundColor = UIColor.white
        return swipeView
    }()
    
    var img_swipeIndicator: UIImageView = {
        let imgView = UIImageView()
        imgView.backgroundColor = UIColor.rgb(red: 191, green: 191, blue: 191)
        return imgView
    }()
    
    var lbl_address: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: FONTSIZE17)
        lbl.text = "Address"
        return lbl
    }()
    var lbl_distance: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: FONTSIZE15)
        lbl.text = "15 mile"
        return lbl
    }()
    
    lazy var btn_direction: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor.rgb(red: 0, green: 122, blue: 225)
        btn.setTitle("Direction", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.addTarget(self, action: #selector(handleDirections), for: .touchUpInside)
        return btn
    }()
    
    var img_spot: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.backgroundColor = UIColor.gray
        return img
    }()
    
    lazy var btn_cancel: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "cancel")
        btn.setImage(img, for: .normal)
        btn.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return btn
    }()
    
    var currentLocation: CLLocation?
    var spot_Mark: MKPlacemark?
    var swipeViewTopConstraint: NSLayoutConstraint?
    var locationManager = CLLocationManager()
    var spotInfos = [SpotInfo]()
//    let dictionary:[[String: AnyObject]] = [["spot_lat": 39.62866 as AnyObject, "spot_lon": 116.321019 as AnyObject, "spot_timeFlag": 1 as AnyObject],
//                                            ["spot_lat": 39.63066 as AnyObject, "spot_lon": 116.318019 as AnyObject, "spot_timeFlag": 1 as AnyObject],
//                                            ["spot_lat": 39.63266 as AnyObject, "spot_lon": 116.321019 as AnyObject, "spot_timeFlag": 1 as AnyObject],
//                                            ["spot_lat": 39.62866 as AnyObject, "spot_lon": 116.317019 as AnyObject, "spot_timeFlag": 1 as AnyObject],
//                                            ["spot_lat": 39.62266 as AnyObject, "spot_lon": 116.315019 as AnyObject, "spot_timeFlag": 3 as AnyObject],
//                                            ["spot_lat": 39.64666 as AnyObject, "spot_lon": 116.325019 as AnyObject, "spot_timeFlag": 3 as AnyObject],
//                                            ["spot_lat": 39.63166 as AnyObject, "spot_lon": 116.317019 as AnyObject, "spot_timeFlag": 2 as AnyObject],
//                                            ["spot_lat": 39.62966 as AnyObject, "spot_lon": 116.327019 as AnyObject, "spot_timeFlag": 2 as AnyObject],
//                                            ["spot_lat": 39.62966 as AnyObject, "spot_lon": 116.328019 as AnyObject, "spot_timeFlag": 3 as AnyObject],
//                                            ["spot_lat": 39.62866 as AnyObject, "spot_lon": 116.308019 as AnyObject, "spot_timeFlag": 3 as AnyObject]]
    
    let dictionary:[[String: AnyObject]] = [["spot_lat": 3.130134 as AnyObject, "spot_lon": 101.721735 as AnyObject, "spot_timeFlag": 1 as AnyObject],
                                            ["spot_lat": 3.120134 as AnyObject, "spot_lon": 101.709735 as AnyObject, "spot_timeFlag": 1 as AnyObject],
                                            ["spot_lat": 3.138134 as AnyObject, "spot_lon": 101.722735 as AnyObject, "spot_timeFlag": 1 as AnyObject],
                                            ["spot_lat": 3.118134 as AnyObject, "spot_lon": 101.702735 as AnyObject, "spot_timeFlag": 1 as AnyObject],
                                            ["spot_lat": 3.133134 as AnyObject, "spot_lon": 101.709735 as AnyObject, "spot_timeFlag": 3 as AnyObject],
                                            ["spot_lat": 3.134134 as AnyObject, "spot_lon": 101.712735 as AnyObject, "spot_timeFlag": 3 as AnyObject],
                                            ["spot_lat": 3.117134 as AnyObject, "spot_lon": 101.715735 as AnyObject, "spot_timeFlag": 2 as AnyObject],
                                            ["spot_lat": 3.131134 as AnyObject, "spot_lon": 101.719335 as AnyObject, "spot_timeFlag": 2 as AnyObject],
                                            ["spot_lat": 3.120134 as AnyObject, "spot_lon": 101.720135 as AnyObject, "spot_timeFlag": 3 as AnyObject],
                                            ["spot_lat": 3.135134 as AnyObject, "spot_lon": 101.723335 as AnyObject, "spot_timeFlag": 3 as AnyObject]]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        self.getAnotations()
        self.loadMapView()
        self.setupViews()
        self.initializeViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    private func getAnotations() {
        
        checkNetwork()
        
        // fetch to the server for annotations
        
        
        
        // get the spotInfos here
        self.spotInfos.removeAll()
        
        for temp in dictionary {
            let spot = SpotInfo.init(dictionary: temp)
            self.spotInfos.append(spot)
        }
        
        self.addAnnotations()
        
    }
    
    private func addAnnotations() {
        for temp in self.spotInfos {
            
            if let lat = temp.spot_lat, let lon = temp.spot_lon {
                let annotation = CustomAnnotation(info: temp)
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                self.mapView.addAnnotation(annotation)
            }
            
//            if let lat = temp.spot_lat, let lon = temp.spot_lon {
//                let spot = CLLocation(latitude: lat, longitude: lon)
//                CLGeocoder().reverseGeocodeLocation(spot, completionHandler: { (placemarks, error) in
//                    if error != nil {
//                        print(error ?? "")
//                    }
//                    if let clPlacemarks = placemarks {
//                        let spotPlace = clPlacemarks[0]
//                        let placemark: MKPlacemark = MKPlacemark(placemark: spotPlace)
//                        let annotation = CustomAnnotation()
//                        annotation.coordinate = placemark.coordinate
////                        annotation.image = temp.spot_image
//
//                        self.mapView.addAnnotation(annotation)
//                    }
//                })
//            }
        }
    }
    
    private func setupViews() {
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(mapView)
        _ = mapView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: GAP70, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        view.addSubview(btn_markSpot)
        _ = btn_markSpot.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0.5 * GAP30, bottomConstant: 0.5 * GAP30, rightConstant: 0.5 * GAP30, widthConstant: 0, heightConstant: GAP40)
        
        view.addSubview(swipeView)
        swipeViewTopConstraint = swipeView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        swipeViewTopConstraint?.isActive = true
        _ = swipeView.anchor(view.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: GAP10, bottomConstant: 0, rightConstant: GAP10, widthConstant: 0, heightConstant: 4 * GAP100)
    
        view.addSubview(img_swipeIndicator)
        _ = img_swipeIndicator.anchor(swipeView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: GAP05, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: GAP40, heightConstant: GAP05)
        img_swipeIndicator.centerXAnchor.constraint(equalTo: swipeView.centerXAnchor).isActive = true
        
        view.addSubview(btn_cancel)
        _ = btn_cancel.anchor(swipeView.topAnchor, left: nil, bottom: nil, right: swipeView.rightAnchor, topConstant: GAP20, leftConstant: 0, bottomConstant: 0, rightConstant: GAP20, widthConstant: GAP20, heightConstant: GAP20)
        
        view.addSubview(lbl_address)
        _ = lbl_address.anchor(swipeView.topAnchor, left: swipeView.leftAnchor, bottom: nil, right: swipeView.rightAnchor, topConstant: GAP20, leftConstant: 0.5 * GAP30, bottomConstant: 0, rightConstant: GAP60, widthConstant: 0, heightConstant: GAP20)
        
        view.addSubview(lbl_distance)
        _ = lbl_distance.anchor(lbl_address.bottomAnchor, left: swipeView.leftAnchor, bottom: nil, right: swipeView.rightAnchor, topConstant: 0, leftConstant: 0.5 * GAP30, bottomConstant: 0, rightConstant: 0.5 * GAP30, widthConstant: 0, heightConstant: GAP20)
        
        view.addSubview(btn_direction)
        _ = btn_direction.anchor(lbl_distance.bottomAnchor, left: swipeView.leftAnchor, bottom: nil, right: swipeView.rightAnchor, topConstant: GAP20, leftConstant: 0.5 * GAP30, bottomConstant: 0, rightConstant: 0.5 * GAP30, widthConstant: 0, heightConstant: GAP50)
        
        view.addSubview(img_spot)
        _ = img_spot.anchor(btn_direction.bottomAnchor, left: swipeView.leftAnchor, bottom: nil, right: swipeView.rightAnchor, topConstant: GAP05, leftConstant: GAP10, bottomConstant: 0, rightConstant: GAP10, widthConstant: 0, heightConstant: 2.5 * GAP100)
        
        
    }

    private func initializeViews() {
        customMaskWith(object: btn_markSpot, radious: GAP05, borderWidth: nil, borderColor: nil)
        customMaskWith(object: swipeView, radious: GAP10, borderWidth: nil, borderColor: nil)
        customMaskWith(object: img_swipeIndicator, radious: 2, borderWidth: nil, borderColor: nil)
        customMaskWith(object: btn_cancel, radious: GAP10, borderWidth: nil, borderColor: nil)
        customMaskWith(object: btn_direction, radious: GAP05, borderWidth: nil, borderColor: nil)
        customMaskWith(object: img_spot, radious: GAP10, borderWidth: nil, borderColor: nil)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(gesture:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(gesture:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.swipeView.addGestureRecognizer(swipeUp)
        self.swipeView.addGestureRecognizer(swipeDown)
        
    }
    
    func checkNetwork() {
        if !Reachability.isConnectedToNetwork(){
            self.showJHTAlerttOkayWithIcon(message: "Connection Error!\nPlease check your internet connection")
            return
        }
    }
}

//MARK:-- MapviewDelegate Methods
extension HomeViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else{
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKPinAnnotationView
    
        let annotation_custom = annotation as! CustomAnnotation
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation_custom, reuseIdentifier: "myAnnotation")
            
        } else {
            annotationView?.annotation = annotation_custom
        }
        
        annotationView?.isDraggable = true
        annotationView?.animatesDrop = true
        
        if annotation_custom.timeFlag == 1 {
            annotationView?.pinTintColor = UIColor.green
        }else if annotation_custom.timeFlag == 2 {
            annotationView?.pinTintColor = UIColor.yellow
        }else if annotation_custom.timeFlag == 3 {
            annotationView?.pinTintColor = UIColor.red
        }
        
        return annotationView
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard !(view.annotation?.isKind(of: MKUserLocation.self))! else{
            return
        }
        
        UIView.animate(withDuration: 0.5) {
            self.swipeViewTopConstraint?.constant = -GAP100 * 1.35
            self.view.layoutIfNeeded()
        }
        
        self.mapView.annotations.forEach {
            if !($0 .isEqual(view.annotation!) ) {
                self.mapView.removeAnnotation($0)
            }
        }
        
        // get address or street of selected annotation
        if let sp_cood = view.annotation?.coordinate {
            self.mapView.centerCoordinate = sp_cood
            let spot_location = CLLocation(latitude: sp_cood.latitude, longitude: sp_cood.longitude)
            CLGeocoder().reverseGeocodeLocation(spot_location, completionHandler: { (clPlaceMarkers, error) in
                if error != nil {
                    print(error ?? "Error occurs")
                }
                
                if let placeMarkers = clPlaceMarkers {
                    let spotPlace = placeMarkers[0]
                    self.spot_Mark = MKPlacemark(placemark: spotPlace)
                    print("This is the placeMark info --->", self.spot_Mark?.description ?? "")
                    self.lbl_address.text = self.spot_Mark?.title?.components(separatedBy: ",").first
                }
            })
            
            let distance = Utility.convertCLLocationDistanceToMiles(targetDistance: self.currentLocation?.distance(from: spot_location))
            self.lbl_distance.text = String(format: "%.1f mile", distance)
        }
        
        
        
        let annotation_custom = view.annotation as! CustomAnnotation
//        self.img_spot.image = annotation_custom.image
        
        if annotation_custom.timeFlag == 1 {
            self.img_spot.backgroundColor = UIColor.green
        }else if annotation_custom.timeFlag == 2 {
            self.img_spot.backgroundColor = UIColor.yellow
        }else if annotation_custom.timeFlag == 3 {
            self.img_spot.backgroundColor = UIColor.red
        }
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        
        switch mode.rawValue {
        case 0:
            DispatchQueue.main.async {
                mapView.setUserTrackingMode(.followWithHeading, animated: false)
            }
            break
        case 1:
            DispatchQueue.main.async {
                mapView.setUserTrackingMode(.followWithHeading, animated: false)
            }
            break
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .ending, .canceling:
            view.dragState = .none
        default: break
        }
    }
    

    
}

//MARK:-- CLLocationManager
extension HomeViewController: CLLocationManagerDelegate {
    
    private func loadMapView() {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
        }
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = true
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true
        mapView.showsBuildings = true
//        mapView.userTrackingMode = .followWithHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentLocation = location
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let span = MKCoordinateSpanMake(0.03, 0.03)
            let region = MKCoordinateRegion(center: center, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error --->" , error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedAlways {
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.requestLocation()
        }
    }
}

//MARK:-- handles

extension HomeViewController {
    
    @objc func handleSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            
            case UISwipeGestureRecognizerDirection.down:
                UIView.animate(withDuration: 0.3) {
                    self.swipeViewTopConstraint?.constant = -GAP100 * 1.35
                    self.view.layoutIfNeeded()
                }
                
            case UISwipeGestureRecognizerDirection.up:
                UIView.animate(withDuration: 0.5) {
                    self.swipeViewTopConstraint?.constant = -GAP100 * 4
                    self.view.layoutIfNeeded()
                }
            default:
                break
            }
        }
    }
    
    @objc func handleCancel() {
        UIView.animate(withDuration: 0.5) {
            self.swipeViewTopConstraint?.constant = 0
            self.view.layoutIfNeeded()
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations)
        }
        
        // reload mapview
        
    }
    
    @objc func handleDirections() {
//        if let lat = spot_coordinate?.latitude, let lon = spot_coordinate?.longitude {
//            let spot = CLLocation(latitude: lat, longitude: lon)
//            CLGeocoder().reverseGeocodeLocation(spot, completionHandler: { (clPlaceMarkers, error) in
//                if error != nil {
//                    print(error ?? "Error occurs")
//                }
//
//                if let placeMarkers = clPlaceMarkers {
//                    let spotPlace = placeMarkers[0]
//                    let spotMark: MKPlacemark = MKPlacemark(placemark: spotPlace)
//                    let mapItem = MKMapItem(placemark: spotMark)
//                    let launchOption = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
//                    mapItem.openInMaps(launchOptions: launchOption)
//                }
//            })
//        }
        
        if let mark = self.spot_Mark {
            let mapItem = MKMapItem(placemark: mark)
            let launchOption = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOption)
            
        }
    }
    
    @objc func handleMarkSpot() {
        self.handleCamera()
    }
}

//MARK:-- Camera

extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate{
    
    func handleCamera() {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            
            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
                
                picker.modalPresentationStyle = .popover
                picker.popoverPresentationController?.delegate = self
                
                self.navigationController?.present(picker, animated: true, completion: nil)
                
            } else {
                self.navigationController?.present(picker, animated: true, completion: nil)
            }
            
        } else {
            self.noCamera()
        }
    }
    
    func noCamera() {
        
        let str_message = "Sorry, this device has no camera"
        
        showJHTAlerttOkayWithIcon(message: str_message)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImmageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImmageFromPicker = editedImage
            
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImmageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImmageFromPicker {
            
            //???
            let detailVC = DetailViewController()
            detailVC.img_spot.image = selectedImage
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
}
