//
//  LocationManager.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import CoreLocation
import MapKit

// MARK: - LocationPermission
enum LocationPermission: Int {
    case Accepted;
    case Denied;
    case Error;
}

// MARK: - UserLocation
class UserLocation: NSObject  {
    
    // MARK: - Variables
    var locationManger: CLLocationManager = {
        let lm = CLLocationManager()
        lm.activityType = .other
        lm.desiredAccuracy = kCLLocationAccuracyBest
        return lm
    }()
    
    // Will be assigned by host controller. If not set can throw Exception.
    typealias LocationBlock = (CLLocation?, NSError?)->()
    var completionBlock : LocationBlock? = nil
    weak var controller: UIViewController!
    
    // MARK: - Init
    static let sharedInstance = UserLocation()
    

    // MARK: - Func
    func fetchUserLocationForOnce(controller: UIViewController, forSos: Bool = false, block: LocationBlock?) {
        self.controller = controller
        locationManger.delegate = self
        completionBlock = block
        if checkAuthorizationStatus(forSos: forSos) {
            locationManger.startUpdatingLocation()
        } else {
            completionBlock?(nil,nil)
        }
    }
    
    func checkAuthorizationStatus(forSos: Bool = false) -> Bool {
        let status = CLLocationManager.authorizationStatus()
        // If status is denied or only granted for when in use
        if status == .denied || status == .restricted {
            let title = "Location services are off"
            let msg = forSos ? "Enabling location permissions is required to use the SOS feature. This will enable us to accurately identify and respond to your emergency needs." : "To use location you must turn on 'WhenInUse' in the location services settings"
            
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let settings = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            })
            
            alert.addAction(cancel)
            alert.addAction(settings)
            controller.present(alert, animated: true, completion: nil)
            return false
        } else if status == .notDetermined {
            locationManger.requestWhenInUseAuthorization()
            return false
        } else if status == .authorizedAlways || status == .authorizedWhenInUse {
            return true
        }
        return false
    }
}

// MARK: - Location manager Delegation
extension UserLocation: CLLocationManagerDelegate {
  
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        DispatchQueue.main.async {
            self.completionBlock?(lastLocation,nil)
            self.locationManger.stopUpdatingLocation()
            self.locationManger.delegate = nil
            self.completionBlock = nil
        }
    }
    
    func addressFromlocation(location: CLLocation, block: @escaping (SearchAddress?)->()) {
        let geoLocation = CLGeocoder()
        geoLocation.reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) -> Void in
            if let pmark = placeMarks, pmark.count > 0 {
                let place :CLPlacemark = pmark.last! as CLPlacemark
                if let addr = place.addressDictionary {
                    
                    DispatchQueue.main.async {
                        block(SearchAddress(dict: addr as NSDictionary))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    block(nil)
                }
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManger.delegate = nil
        DispatchQueue.main.async {
            self.completionBlock?(nil,error as NSError?)
            self.locationManger.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManger.startUpdatingLocation()
    }
}
