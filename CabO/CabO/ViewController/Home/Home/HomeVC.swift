//
//  HomeVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import SwiftUI
import WidgetKit
import BackgroundTasks
import MapKit

var _arrPrefs: [RidePrefModel] = []
var _arrLuggage: [RidePrefModel] = []

//MARK: - Home VC
class HomeVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var imgUserProfile: NRoundImageView!

    @IBOutlet weak var vwUnreadCount: UIView!
    @IBOutlet weak var lblUnreadCount: UILabel!
    @IBOutlet weak var unreadCountTop: NSLayoutConstraint!
    @IBOutlet weak var unreadCountBottom: NSLayoutConstraint!
    @IBOutlet weak var unreadCountLeading: NSLayoutConstraint!
    @IBOutlet weak var unreadCountTrainling: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    /// Variables
    var arrCells: [HomeCellType] = [.taxi, .carpool, .postRide]
    var unreadCount: Int = 0 {
        didSet {
            updateUnreadCount(unreadCount)
        }
    }
    var adView: SliderView?
    
    var manager: CLLocationManager?
    var newPin = MKPointAnnotation()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
//        getRidePrefs()
        
//        saveRides()
//        showAdvView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.getUnreadCount()
    }
    
    /// Show Adverisement Slider
    func showAdvView() {
//        adView = SliderView.initView()
//        adView!.prepareAdUI(ads: [AdDetails(), AdDetails(), AdDetails()])
//        adView!.frame = CGRect(x: 0, y: _screenSize.height - (((52 + _bottomBarHeight) * _heightRatio)) - 74 * _widthRatio, width: _screenSize.width, height: (74 * _widthRatio))
//
//        self.view.addSubview(adView!)
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: (12 + 74) * _widthRatio, right: 0)
        adView!.layer.zPosition = 1
    }
    
    func updateUnreadCount(_ count: Int) {
        if count > 0 {
            vwUnreadCount?.isHidden = false
            lblUnreadCount?.text = count > 99 ? "99+" : count.stringValue
            unreadCountTop.constant = 2 //unreadCount > 9 ? 4 : 2
            unreadCountBottom.constant = 2 //unreadCount > 9 ? 4 : 2
            unreadCountLeading.constant = (count > 9 ? 4 : 6) * _widthRatio
            unreadCountTrainling.constant = (count > 9 ? 4 : 6) * _widthRatio
        } else {
            vwUnreadCount?.isHidden = true
        }
    }
}

// MARK: - UI Methods
extension HomeVC {
    
    func prepareUI() {
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
//        if _user?.role == .driver {
            self.collectionHeight.constant = 113 * _widthRatio
//        }else{
//            self.collectionHeight.constant = 175 * _widthRatio
//        }
//        labelUserName.text = getTimeOfDay() + "\n" + (_user?.fullName ?? "")
//        labelUserName.setAttributedText(texts: [(getTimeOfDay() + "\n") , (_user?.fullName ?? "")], attributes: [ [NSAttributedString.Key.font : AppFont.fontWithName(.regular, size: (14 * _fontRatio))],[NSAttributedString.Key.font : AppFont.fontWithName(.mediumFont, size: (16 * _fontRatio))]])
//        imgUserProfile.loadFromUrlString(_user?.profilePic ?? "", placeholder: _userPlaceImage)
        addObservers()
        registerCells()
        
        //Map View
        manager = CLLocationManager()
        manager!.delegate = self

        mapView.delegate = self // map is being set from another controller
        mapView.showsUserLocation = true
        mapView.mapType = .standard
        mapView.userTrackingMode = .followWithHeading
        manager!.requestWhenInUseAuthorization()
//        view.addSubview(mapView)
    }
    func loadMapView() {
        // Map view setup
        let mapView = MKMapView()
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        mapView.layoutIfNeeded()
        // Reverse geocoding map region center
        let location = CLLocation(
            latitude: mapView.region.center.latitude,
            longitude: mapView.region.center.longitude
        )
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
//            self.didDetectCountryCode?(placemarks?.first?.isoCountryCode)
        }
    }

    func registerCells() {
        
    }
}


// MARK: - Actions
extension HomeVC {
    
    @IBAction func btnNotificationListTap(_ sender: UIButton) {
        let vc = NotificationListVC.instantiate(from: .Home)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func buttonMenuTap(_ sender: UIButton) {
        let vc = SideMenuVC.instantiate(from: .Profile)
        vc.navigaton_controller = self.navigationController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(vc, animated: true)
    }
}

// MARK: - Collectionview Methods
extension HomeVC : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if DeviceType.iPad {
            let box = (_screenSize.height / 2) - 148
            return CGSize(width: _screenSize.width - 148, height: box)
        } else {
            let totalCount : CGFloat = CGFloat(arrCells.count)
            let height = collectionView.frame.size.height
            let space : CGFloat = (10 * _widthRatio) * (totalCount-1)
            let width = ((collectionView.frame.size.width - ((50 * _widthRatio) + space)) / totalCount)
            return CGSize(width: width, height: height)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0 //10 * _widthRatio)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return (10 * _widthRatio)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "rideCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? HomeCreateRideCVC {
            cell.prepareUI(cellType.title, cellType.desc, cellType.img)
            cell.toggleSwitch = { [weak self] (isOn) in
                guard let `self` = self else { return }
                if cellType == .carpool {
                    if isOn {
                        self.arrCells.append(.postRide)
                    }else{
                        self.arrCells.remove(.postRide)
                    }
                    self.collectionView.reloadData()
                }else{
                    //                self.toggleSwitchActions(cellType, isOn)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
//        if cellType == .taxi {
//            self.getCreateRideConfig()
//        } else {
//            let vc = FindRideVC.instantiate(from: .Home)
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
}

//MARK: - Notification Observers
extension HomeVC {
    
    func addObservers() {
        _defaultCenter.addObserver(self, selector: #selector(userProfileEdited(_:)), name: Notification.Name.userProfileUpdate, object: nil)
    }
    
    @objc func userProfileEdited(_ notification: NSNotification){
        _appDelegator.getUserProfile { [weak self] (succ, json) in
            guard let weakSelf = self else { return }
            if succ {
//                weakSelf.labelUserName.text = weakSelf.getTimeOfDay() + "\n" + (_user?.fullName ?? "")
                if let profileImg = _user?.profilePic, !profileImg.isEmpty {
                    weakSelf.imgUserProfile.loadFromUrlString( profileImg, placeholder: _userPlaceImage)
                } else {
                    weakSelf.imgUserProfile.image = _userPlaceImage
                }
            }
        }
    }
    
}

// MARK: - API Call
extension HomeVC {
    
    func getCreateRideConfig() {
        showCentralSpinner()
        WebCall.call.getRideConfig { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {

                let allow = data.getBooleanValue(key: "is_allow_create_ride")
                let msg = data.getStringValue(key: "message")
                let redirectKey = CreateRideRediration(rawValue: data.getStringValue(key: "redirection_key"))
                
                if allow {
                    let vc = CreateRideVC.instantiate(from: .Home)
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let btns : [ButtonType] = [.custom(title: redirectKey?.buttonTitle ?? "OK"), .cancel]
                    self.showConfirmationPopUpView("", msg, btns: btns) { btn in
                        if btn != .cancel {
                            self.redirectUser(redirectKey!)
                        }
                    }
                }
            } else {
                
            }
        }
    }
    
    /// Create Ride Restriction
    fileprivate func redirectUser(_ type: CreateRideRediration) {
        
        if type == .offerRide || type == .carVerify {
            if let tab = self.tabBarController as? NTabBarVC {
                tab.setSelectedIndex(2)
            }
        } else if type == .carDocReject || type == .carDocExpire {
            if let tab = self.tabBarController as? NTabBarVC {
                tab.setSelectedIndex(2)
            }
            let vc = CarListVC.instantiate(from: .Profile)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if type == .idVerification {
            if let tab = self.tabBarController as? NTabBarVC {
                tab.setSelectedIndex(2)
            }
            let vc = IdVerificationVC.instantiate(from: .Profile)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            if let tab = self.tabBarController as? NTabBarVC {
                tab.setSelectedIndex(2)
            }
            let vc = BankDetailsVC.instantiate(from: .Profile)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func getRidePrefs() {
        WebCall.call.getRidePrefs { [weak self] (json, status) in
            guard let self = self else { return }
            _arrPrefs = []
            _arrLuggage = []
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
                var arrPrefs : [RidePrefModel] = []
                var arrLuggage : [RidePrefModel] = []
                
                if let prefs = data["preferences"] as? [NSDictionary] {
                    prefs.forEach { pref in
                        arrPrefs.append(RidePrefModel(pref))
                    }
                }
                if let luggages = data["luggages"] as? [NSDictionary] {
                    luggages.forEach { lugg in
                        arrLuggage.append(RidePrefModel(lugg))
                    }
                }
                
                _arrPrefs = arrPrefs
                _arrLuggage = arrLuggage
            } else {
                self.getRidePrefs()
            }
        }
    }
    
    func getUnreadCount() {
        WebCall.call.getUnReadCount { [weak self] (json, status) in
            guard let self = self else { return }
            if status == 200, let dict = json as? NSDictionary {
                _appDelegator.getTabBarVc()?.updateUnreadCount(dict.getIntValue(key: "unread_message"))
                self.updateUnreadCount(dict.getIntValue(key: "unread_notification"))
            }
        }
    }
}
extension HomeVC : MKMapViewDelegate,  CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        nprint(items: "permisison did change")
        if(manager.authorizationStatus == CLAuthorizationStatus.authorizedWhenInUse || manager.authorizationStatus == CLAuthorizationStatus.authorizedAlways) {
            mapView.showsUserLocation = true
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in (locations as Array) {
            mapView.removeAnnotation(newPin)

            let loc = location
            nprint(items:loc.coordinate.latitude)
            
            let region = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            //               let region = MKCoordinateRegion(center: loc.coordinate, span: MKCoordinateSpanMake(0.05, 0.05))
            mapView.setRegion(region, animated: true)
            newPin = MKPointAnnotation()
            newPin.coordinate = location.coordinate
            newPin.title = "CurrentLocation"
            mapView.addAnnotation(newPin)

            
            let camera = MKMapCamera()
                camera.centerCoordinate = loc.coordinate
                
                // Adjust the pitch if needed
                camera.pitch = 0
                
                // Add vertical offset (latitudeDelta) to move map upward visually
                let offset = -0.002 // You can tweak this value
                let adjustedCoordinate = CLLocationCoordinate2D(
                    latitude: loc.coordinate.latitude + offset,
                    longitude: loc.coordinate.longitude
                )
                
                mapView.setCenter(adjustedCoordinate, animated: true)
            
            manager.stopUpdatingLocation()
        }
    }
    
//    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
//        mapView.removeAnnotation(newPin)
//        for location in (locations as Array) {
//            let loc = (location as! CLLocation)
//            nprint(items:loc.coordinate.latitude)
//            
//            let region = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: 0.05, longitudinalMeters: 0.05)
//            //               let region = MKCoordinateRegion(center: loc.coordinate, span: MKCoordinateSpanMake(0.05, 0.05))
//            mapView.setRegion(region, animated: true)
//            newPin = MKPointAnnotation()
//            newPin.coordinate = location.coordinate
//            mapView.addAnnotation(newPin)
//        }
//    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        let identifier = "customAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        if annotation.title == "CurrentLocation" {
            annotationView?.image = UIImage(named: "ic_current_location")

        }
//        guard !(annotation is MKUserLocation) else {
//            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userLocation")
//            annotationView.image = UIImage(named:"ic_current_locationg")
//            return annotationView
//        }
        return annotationView
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        nprint(items:"fail , Error - \(error.localizedDescription)")
    }
    
}
