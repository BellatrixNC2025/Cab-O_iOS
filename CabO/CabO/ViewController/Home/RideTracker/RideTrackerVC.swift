//
//  RideTrackerVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import GoogleMaps
import MapboxMaps
import MapboxDirections
import MapboxNavigationUIKit
import MapboxNavigationCore
import MapKit

class RideTrackerVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var recenterButton: UIView!
    @IBOutlet weak var btnBack: UIView!
    
    /// Variables
    var rideDetails: RideDetails!
    var isDriver: Bool = true
    
    let locationManager = CLLocationManager()
    var initialZoomSet = false
    var userInteractedWithMap = false
    
    var mapBoxMap: NavigationMapView!
    var driverLocation: [CLLocation] = []
    var latestLocation: CLLocation!
    var trackingId: String!
    var heading: Double?
    var carAnnotation: MKAnnotationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareMapUI()
        getLastLocation()
        joiningRideTracking()
        addSocketNotificationObserver()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view != recenterButton || touches.first?.view != btnBack {
            initialZoomSet = true
            userInteractedWithMap = true
            recenterButton.isHidden = !userInteractedWithMap
        }
    }
    
    deinit {
        _defaultCenter.removeObserver(self)
        leaveRideTracking()
    }
}

// MARK: - UI Methods
extension RideTrackerVC {
    
    func prepareMapUI() {
        if isDriver {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            
//            mapBoxMap = NavigationMapView(frame: .zero)
//            viewMap.addSubview(mapBoxMap)
            mapBoxMap.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
            
            let start = Waypoint(location: rideDetails.start!.location, name: rideDetails.start?.name)
            let dest = Waypoint(location: rideDetails.dest!.location, name: rideDetails.dest?.name)
            var stops: [Waypoint] = []
            rideDetails.arrStopOvers.forEach { stop in
                stops.append(Waypoint(location: stop.start!.location, name: stop.start?.fullName))
            }
            
            var arrWaypoints: [Waypoint] = []
            arrWaypoints.append(start)
            arrWaypoints.append(contentsOf: stops)
            arrWaypoints.append(dest)
            
            let route = NavigationRouteOptions(waypoints: arrWaypoints)

            // Define the Mapbox Navigation entry point.
            let mapboxNavigationProvider = MapboxNavigationProvider(coreConfig: .init())
            lazy var mapboxNavigation = mapboxNavigationProvider.mapboxNavigation
            // Request a route using RoutingProvider
            let request = mapboxNavigation.routingProvider().calculateRoutes(options: route)
            Task {
                switch await request.result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let navigationRoutes):
                    // Pass the generated navigation routes to the the NavigationViewController
                    let navigationOptions = NavigationOptions(mapboxNavigation: mapboxNavigation,
                                                              voiceController: mapboxNavigationProvider.routeVoiceController,
                                                              eventsManager: mapboxNavigationProvider.eventsManager())
                    let navigationViewController = NavigationViewController(navigationRoutes: navigationRoutes,
                                                                            navigationOptions: navigationOptions)
                    navigationViewController.modalPresentationStyle = .fullScreen
                    navigationViewController.showsEndOfRouteFeedback = false
                    navigationViewController.showsSpeedLimits = true
                    navigationViewController.showsContinuousAlternatives = true
                    navigationViewController.delegate = self
                    navigationViewController.navigationMapView?.delegate = self
                    present(navigationViewController, animated: true, completion: nil)
                }
            }
//            Directions.shared.calculate(route) { [weak self] (result) in
//                guard let self = self else { return }
//                switch result {
//                case .failure(let error):
//                    nprint(items: error.localizedDescription)
//                case .success(let response):
//                    self.mapBoxMap.showcase(response.routes ?? [])
//                    
//                    // MARK: - Simulation setup for driver
//                    
//                    let indexedRouteResponse = IndexedRouteResponse(routeResponse: response, routeIndex: 0)
//                    let navigationService = MapboxNavigationService(indexedRouteResponse: indexedRouteResponse,
//                                                                    customRoutingProvider: NavigationSettings.shared.directions,
//                                                                    credentials: NavigationSettings.shared.directions.credentials,
//                                                                    simulating: _hostMode == .dev ? .always : .never)
//                    
//                    let navigationOptions = NavigationOptions(navigationService: navigationService)
//                    let nav = NavigationViewController(for: indexedRouteResponse,
//                                                       navigationOptions: navigationOptions)
//                    nav.showsEndOfRouteFeedback = false
//                    nav.showsSpeedLimits = true
//                    nav.showsContinuousAlternatives = true
//                    nav.modalPresentationStyle = .overFullScreen
//                    nav.delegate = self
//                    nav.navigationMapView?.delegate = self
//                    self.present(nav, animated: true)
//                }
//            }
            
        }
        else {
            mapView.delegate = self
            mapView.showsUserLocation = true
            mapView.mapType = .standard
            mapView.userTrackingMode = .followWithHeading
            calculateRoute()
        }
    }
    
    func zoomToDriverLocation() {
        guard let riderLocation = latestLocation else { return }
        
        if !userInteractedWithMap {
            let region = MKCoordinateRegion(center: riderLocation.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
//    func updateMapCamera() {
//        //        let camera = GMSCameraPosition.camera(withLatitude: latestLocation.coordinate.latitude, longitude: latestLocation.coordinate.longitude, zoom: 17.0)
//        //        mapView.camera = camera
//        //        mapView.clear()
//        //        self.addMarker(coordinate: CLLocationCoordinate2D(latitude: latestLocation.coordinate.latitude, longitude: latestLocation.coordinate.longitude), title: "Driver", icon: UIImage(named: "ic_car_location"))
//    }
    
    func startSendingLocation() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [weak self] (timer) in
            self?.sendRideLocation()
        })
    }
}

//MARK: - Draw on Apple map
extension RideTrackerVC: MKMapViewDelegate {
    
    @IBAction func btn_recenter_tap(_ sender: UIButton) {
        userInteractedWithMap = false
        recenterButton.isHidden = !userInteractedWithMap
        zoomToDriverLocation()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.systemBlue
        renderer.lineWidth = 5
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if let carAnnotationView = carAnnotation, userInteractedWithMap {
            if let heading {
                let angle = (-mapView.camera.heading + heading) * .pi / 180
                carAnnotationView.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
            }
        }
    }
    
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
        
        if annotation.title == "Driver" {
            annotationView?.image = UIImage(named: "ic_track_car")
            carAnnotation = annotationView
            if let heading {
                if userInteractedWithMap {
                    let angle = (-mapView.camera.heading + heading) * .pi / 180
                    annotationView?.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
                } else {
                    annotationView?.transform = CGAffineTransform(rotationAngle: CGFloat(heading * .pi / 180))
                }
            }
        } else if annotation.title == "Start" {
            annotationView?.image = UIImage(named: "ic_ride_start")
        } else if annotation.title == "Destination" {
            annotationView?.image = UIImage(named: "ic_ride_dest")
        }
        return annotationView
    }
    
    func calculateRoute() {
        guard let riderLocation = latestLocation else { return }
        let destinationLocation: CLLocationCoordinate2D = rideDetails.status == .ontheway ? rideDetails.start!.location2D : rideDetails.dest!.location2D
        
        // Create rider's pin
        let riderPin = MKPointAnnotation()
        riderPin.coordinate = riderLocation.coordinate
        riderPin.title = "Driver"
        
        // Remove previous rider pin and add new one
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(riderPin)
        
        // Create destination pin
        let destinationPin = MKPointAnnotation()
        destinationPin.coordinate = destinationLocation
        destinationPin.title = rideDetails.status == .ontheway ? "Start" : "Destination"
        
        mapView.addAnnotation(destinationPin)
        
        // Create MKPlacemark for rider's location
        let riderPlacemark = MKPlacemark(coordinate: riderLocation.coordinate)
        let riderMapItem = MKMapItem(placemark: riderPlacemark)
        
        // Create MKPlacemark for destination location
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // Create MKDirectionsRequest
        let request = MKDirections.Request()
        request.source = riderMapItem
        request.destination = destinationMapItem
        request.transportType = .automobile
        
        // Calculate route
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self else { return }
            
            if let route = response?.routes.first {
                // Remove old route overlay
                self.mapView.removeOverlays(self.mapView.overlays)
                
                // Add new route overlay
                self.mapView.addOverlay(route.polyline)
                
                // Fit route to map view only if initial zoom hasn't been set
                if !self.initialZoomSet {
//                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                    self.zoomToDriverLocation()
                    self.initialZoomSet = true
                }
            }
        }
    }
    
}

//MARK: - MAPBOX Delegate Methods
extension RideTrackerVC: CLLocationManagerDelegate, NavigationViewControllerDelegate, NavigationMapViewDelegate {
    
    func navigationViewController(_ navigationViewController: NavigationViewController, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation){
        if driverLocation.isEmpty {
            driverLocation.append(location)
        } else if driverLocation.last! != location {
            driverLocation.append(location)
        }
    }
    
    func navigationViewController(_ navigationViewController: NavigationViewController, shouldRerouteFrom location: CLLocation) -> Bool {
        return true
    }
    
    // Bottomview cancel button click.
    func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
        DispatchQueue.main.async {
            navigationViewController.dismiss(animated: true, completion: {
                self.navigationController?.popViewController(animated: false)
            })
        }
    }
}

//MARK: - Socket Related API Methods
extension RideTrackerVC {
    
    //Socket Notifiaction Observer Call
    func addSocketNotificationObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.socketConnectionStateChangeNotification(_:)), name: .observerSocketConnectionStateChange, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.socketJoinTracking(_:)), name: .observerSocketJoinRideTracking, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.socketSendRideLocation(_:)), name: .observerSocketSendRideLocation, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(manageWillEnterForgorund(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    //Socket Connection State Change
    @objc func socketConnectionStateChangeNotification(_ sender: Notification) {
        if KSocketManager.shared.socket.status == .connected {
            // socket is connected
            self.joiningRideTracking()
        }
    }
    
    @objc func manageWillEnterForgorund(_ sender: Notification) {
        getLastLocation()
    }
    
    //Socket Chat Join
    @objc func socketJoinTracking(_ sender: Notification) {
        nprint(items: "tracking connected")
    }
    
    //Sockt Send/Receive Msg
    @objc func socketSendRideLocation(_ sender: Notification) {
        if let arr = sender.object as? [[String: Any]], !arr.isEmpty, let dict = arr.first, let data = dict["data"] as? NSDictionary {
            nprint(items: "SOCKET Receive Location : ", data)
            let lat = data.getDoubleValue(key: "latitude").rounded(toPlaces: 7)
            let long = data.getDoubleValue(key: "longitude").rounded(toPlaces: 7)
            self.heading = data.getDoubleValue(key: "heading")
            let rideId = data.getIntValue(key: "ride_id")
            
            if !isDriver && self.rideDetails.id == rideId {
                self.latestLocation = CLLocation(latitude: lat, longitude: long)
                self.calculateRoute()
                self.zoomToDriverLocation()
            }
        }
    }
    
    //Joining Chat Channel Call
    func joiningRideTracking() {
        KSocketManager.shared.joinTracking(id: rideDetails.id)
    }
    
    //Leave Chat Channel Call
    func leaveRideTracking() {
        KSocketManager.shared.leaveTracking(id: rideDetails.id)
    }
    
    //Send Chat Channel Call
    func sendRideLocation() {
        if !driverLocation.isEmpty && trackingId != nil {
            if latestLocation != driverLocation.last! {
                KSocketManager.shared.requestSendRideLocation(rideId: rideDetails.id, location: driverLocation.last!, roomID: trackingId)
            }
        }
    }
}

// MARK: - API Calls
extension RideTrackerVC {
    
    func getLastLocation() {
        
        showCentralSpinner()
        WebCall.call.getRideLatestLocation(rideDetails.id!) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200, let jSon = json as? NSDictionary {
                if let meta = jSon["meta"] as? NSDictionary {
                    self.trackingId = meta.getStringValue(key: "track_room_id")
                    if self.isDriver {
                        self.startSendingLocation()
                    }
                }
                
                if let data = jSon["data"] as? NSDictionary {
                    let lat = data.getDoubleValue(key: "latitude").rounded(toPlaces: 7)
                    let long = data.getDoubleValue(key: "longitude").rounded(toPlaces: 7)
                    let location = CLLocation(latitude: lat, longitude: long)
                    self.latestLocation = location
                    self.driverLocation.append(location)
                    
                    if !isDriver {
                        self.calculateRoute()
                        self.zoomToDriverLocation()
                    }
                }
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
}

// Mark: - Google Map methods
//extension RideTrackerVC {
//func getDirections() {
//    showCentralSpinner()
//    KPAPICalls.shared.getWayPoints(origin: rideDetails.start!.formatedAddress,
//                                   dest: rideDetails.dest!.formatedAddress,
//                                   stopOvers: rideDetails.arrStopOvers.compactMap({$0.start!.formatedAddress})) { [ weak self] (items, errorDescription) in
//        guard let self = self else { return }
//        self.hideCentralSpinner()
//        if let items {
//            //                self.drawRoute(points: items)
//        }
//    }
//}
//
//        func drawRoute(points: WayPoints) {
//            guard let routes = points.routes else {
//                return
//            }
//
//            for route in routes {
//                if let path = route.overviewPolyline {
//                    let polyline = GMSPolyline(path: GMSPath(fromEncodedPath: path.points))
//                    polyline.strokeWidth = 3.0
//                    polyline.strokeColor = UIColor.systemBlue
//                    polyline.map = mapView
//                }
//            }
//
//            addMarker(coordinate: CLLocationCoordinate2D(latitude: rideDetails.start!.lat, longitude: rideDetails.start!.long), title: "Start", icon: UIImage(named: "ic_ride_start"))
//            addMarker(coordinate: CLLocationCoordinate2D(latitude: rideDetails.dest!.lat, longitude: rideDetails.dest!.long), title: "Destinaton", icon: UIImage(named: "ic_ride_dest"))
//
//            if !rideDetails.arrStopOvers.isEmpty {
//                rideDetails.arrStopOvers.forEach { stop in
//                    addMarker(coordinate: CLLocationCoordinate2D(latitude: stop.start!.lat, longitude: stop.start!.long), title: "Stop", icon: UIImage(named: "ic_ride_start"))
//                }
//            }
//
//        }
//
//        func addMarker(coordinate: CLLocationCoordinate2D, title: String, icon: UIImage?) {
//            let marker = GMSMarker()
//            marker.position = coordinate
//            marker.title = title
//            marker.icon = icon
//            marker.map = mapView
//        }
//}
