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
import Networking
import SDWebImage

class Utility {
    class func convertCLLocationDistanceToMiles ( targetDistance : CLLocationDistance?) -> CLLocationDistance {
        return  targetDistance!*0.00062137
    }
    class func convertCLLocationDistanceToKiloMeters ( targetDistance : CLLocationDistance?) -> CLLocationDistance {
        return  targetDistance!/1000
    }
}


class MyMapView: MKMapView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // set compass position by setting its frame
        if let compassView = self.subviews.filter({ $0.isKind(of: NSClassFromString("MKCompassView")!) }).first {

            compassView.frame = CGRect(x: CGFloat(DEVICE_WIDTH - GAP40 - 10), y: GAP100, width: GAP40, height: GAP40)
        }
    }
}


class HomeViewController: UIViewController {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var steps = [MKRouteStep]()
    
    var mapView : MyMapView = {
        let map = MyMapView()
        return map
    }()
    
    var view_bottom : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.alpha = 0.95
        return view
    }()
    
    lazy var btn_markSpot : UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor.rgb(red: 0, green: 122, blue: 225)
        btn.setTitle("Mark Spot", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.addTarget(self, action: #selector(handleMarkSpot), for: .touchUpInside)
        btn.isEnabled = false
        return btn
    }()
    
    var swipeView: UIView = {
        let swipeView = UIView()
        swipeView.backgroundColor = UIColor.white
        swipeView.alpha = 0.95
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
        return lbl
    }()
    var lbl_distance: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: FONTSIZE15)
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
        img.backgroundColor = UIColor.lightGray
        return img
    }()
    
    lazy var btn_cancel: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "cancel")
        btn.setImage(img, for: .normal)
        btn.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return btn
    }()
    
    var btn_current: MKUserTrackingButton = {
        let btn = MKUserTrackingButton()
        btn.backgroundColor = UIColor.white
        return btn
    }()
    
    var currentLocation: MKUserLocation?
    var spot_Mark: MKPlacemark?
    var spot_cood: CLLocationCoordinate2D?
    var swipeViewTopConstraint: NSLayoutConstraint?
    var spotInfos = [SpotInfo]()
    
    var timer_location : Timer?
    var timerFlag = true
    var updateFlag = false
    
    //MARK:-- ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadMapView()
        self.setupViews()
        self.initializeViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isHidden = true
        
        self.timerFlag = true
        if updateFlag {
            self.getAnotations()
        }
        self.RTUpdate()
    }

    func stopTimer() {
        if let timer = self.timer_location {
            timer.invalidate()
        }
        self.timer_location = nil
    }
    
    func RTUpdate() {
        self.stopTimer()
        self.timer_location = Timer.scheduledTimer(timeInterval: TimeInterval(REFRESHTIME), target: self, selector: #selector(getAnotations), userInfo: nil, repeats: true)
    }
    
    @objc private func getAnotations() {
        
        checkNetwork()
        
        if timerFlag {
            // fetch to the server for annotations
            
            let paramDic = ["latitude": mapView.userLocation.coordinate.latitude,
                            "longitude": mapView.userLocation.coordinate.longitude]
            
            API?.executeHTTPRequest(Post, url: GETSPOTS_URL, parameters: paramDic, completionHandler: { (responseDic) in
                
                if let response = responseDic {
                    self.parseDic(responseDic: response)
                }
                
            }, errorHandler: { (error) in
                if error != nil {
                    print("Network Error ---> ", error ?? "")
                }
            })
        }
    }
    
    private func parseDic(responseDic: [AnyHashable: Any]) {
        
        let status = responseDic["status"] as! String
        if status == "SUCCESS" {
            // get the spotInfos here
            self.spotInfos.removeAll()
            if let pinArray = (responseDic["pin"] as? NSArray) as? [NSDictionary] {
                
                DispatchQueue.main.async {
                    for temp in pinArray {
                        let tempSpot = SpotInfo(dictionary: temp)
                        self.spotInfos.append(tempSpot)
                    }
                    
                    self.addAnnotations()
                }
            }
        }else {
            print("Failed")
        }        
    }
    
    private func addAnnotations() {
        
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        for temp in self.spotInfos {
            
            if let lat = temp.spot_lat, let lon = temp.spot_lon {
                let annotation = CustomAnnotation(info: temp)
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    private func setupViews() {
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(mapView)
        _ = mapView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        view.addSubview(btn_current)
        _ = btn_current.anchor(mapView.topAnchor, left: nil, bottom: nil, right: mapView.rightAnchor, topConstant: GAP30, leftConstant: 0, bottomConstant: 0, rightConstant: GAP05, widthConstant: GAP50, heightConstant: GAP50)
        btn_current.mapView = self.mapView
        
        view.addSubview(view_bottom)
        _ = view_bottom.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: GAP70)
        
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
        _ = btn_cancel.anchor(swipeView.topAnchor, left: nil, bottom: nil, right: swipeView.rightAnchor, topConstant: GAP20, leftConstant: 0, bottomConstant: 0, rightConstant: GAP20, widthConstant: GAP30, heightConstant: GAP30)
        
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
        customMaskWith(object: view_bottom, radious: GAP10, borderWidth: nil, borderColor: nil)
        customMaskWith(object: btn_markSpot, radious: GAP05, borderWidth: nil, borderColor: nil)
        customMaskWith(object: swipeView, radious: GAP10, borderWidth: nil, borderColor: nil)
        customMaskWith(object: img_swipeIndicator, radious: 2, borderWidth: nil, borderColor: nil)
        customMaskWith(object: btn_cancel, radious: GAP10, borderWidth: nil, borderColor: nil)
        customMaskWith(object: btn_direction, radious: GAP05, borderWidth: nil, borderColor: nil)
        customMaskWith(object: img_spot, radious: GAP10, borderWidth: nil, borderColor: nil)
        customMaskWith(object: btn_current, radious: GAP05, borderWidth: nil, borderColor: nil)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(gesture:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(gesture:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.swipeView.addGestureRecognizer(swipeUp)
        self.swipeView.addGestureRecognizer(swipeDown)        
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
}

//MARK:-- CLLocationManager
extension HomeViewController{
    
    private func loadMapView() {
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = true
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true
        mapView.showsBuildings = true
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
        
        if annotation_custom.timeFlag == 1 {
            annotationView?.pinTintColor = UIColor.green
        }else if annotation_custom.timeFlag == 2 {
            annotationView?.pinTintColor = UIColor.yellow
        }else if annotation_custom.timeFlag == 3 {
            annotationView?.pinTintColor = UIColor.red
        }else {
            annotationView?.pinTintColor = UIColor.brown
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard !(view.annotation?.isKind(of: MKUserLocation.self))! else{
            return
        }
        
        UIView.animate(withDuration: 0.5) {
            self.swipeViewTopConstraint?.constant = -GAP100 * 1.35
            self.view.layoutIfNeeded()
            
            self.view_bottom.isHidden = true
            self.btn_markSpot.isHidden = true
        }
        
        self.mapView.annotations.forEach {
            if !($0 .isEqual(view.annotation!) ) {
                self.mapView.removeAnnotation($0)
            }
        }
        
        self.timerFlag = false
        
        // get address or street of selected annotation
        
        if let sp_cood = view.annotation?.coordinate {
            self.mapView.centerCoordinate = sp_cood
            self.spot_cood = sp_cood
            let spot_location = CLLocation(latitude: sp_cood.latitude, longitude: sp_cood.longitude)
            CLGeocoder().reverseGeocodeLocation(spot_location, completionHandler: { (clPlaceMarkers, error) in
                if error != nil {
                    print(error ?? "Error occurs")
                }
                
                if let placeMarkers = clPlaceMarkers {
                    let spotPlace = placeMarkers[0]
                    self.spot_Mark = MKPlacemark(placemark: spotPlace)
                    self.lbl_address.text = self.spot_Mark?.title?.components(separatedBy: ",").first
                }
            })
            if let location = self.currentLocation?.location {
                
                let distance = Utility.convertCLLocationDistanceToMiles(targetDistance: location.distance(from: spot_location))
                self.lbl_distance.text = String(format: "%.3f mile", distance)
            }
        }
       
        let custom_anno = view.annotation as! CustomAnnotation
        if let photoUrl = custom_anno.img_spot_url {
            
            self.img_spot.sd_addActivityIndicator()
            self.img_spot.sd_setImage(with: URL(string: photoUrl), completed: nil)
            
        }
    }

    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        self.btn_markSpot.isEnabled = true
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        self.currentLocation = userLocation
        if !updateFlag {
            updateFlag = true
            let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: center, span: span)
            self.mapView.setRegion(region, animated: false)
            self.getAnotations()
        }
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print("Error --->", error)
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
            self.view_bottom.isHidden = false
            self.btn_markSpot.isHidden = false
            self.swipeViewTopConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
        
        self.timerFlag = true
        self.getAnotations()
    }
    
    @objc func handleDirections() {
        
        if let mark = self.spot_Mark {
            let mapItem = MKMapItem(placemark: mark)
            
            let directionVC = DirectionViewController()
            directionVC.destination = mapItem
            directionVC.desti_cood = self.spot_cood
            self.navigationController?.pushViewController(directionVC, animated: true)
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
        let str_title = "Warning"
        let alert = UIAlertController(title: str_title, message: str_message, preferredStyle: .alert)
        let okeyAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okeyAction)
        self.present(alert, animated: true, completion: nil)        
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
