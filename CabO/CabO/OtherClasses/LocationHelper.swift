//
//  LocationHelper.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

// MARK: - SearchAddress
class SearchAddress{
    
    // For google search
    var placeId: String!
    var name: String!
    var secondryText: String!
    
    var refCode: String!
    var fullName: String = ""
    var timeZoneId: String = ""
    var timeZoneName: String = ""
    
    // For Geocode search
    var lat: Double = 0.0
    var long: Double = 0.0
    
    var location: CLLocation {
        return CLLocation(latitude: lat, longitude: long)
    }
    
    var location2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    var address1: String = ""
    var address2: String = ""
    var address: String = ""
    var customAddress: String = ""
    var street: String = ""
    var city: String = ""
    var state: String = ""
    var country: String = ""
    var countryShortName: String = ""
    var zipcode: String = ""
    var formatedAddress: String = ""
    
    var addressComponents: [AddressComponent] = []
    
    init() {}
    
    init(googleData: NSDictionary) {
        placeId = googleData.getStringValue(key: "place_id")
        name = googleData.getStringValue(key: "description")
        refCode = googleData.getStringValue(key: "reference")
        
        if let data = googleData["structured_formatting"] as? NSDictionary {
            name = data.getStringValue(key: "main_text")
            secondryText = data.getStringValue(key: "secondary_text")
        }
    }

    init(geoCodeData: CLPlacemark) {
        refCode = ""
        name = ""
        fullName = ""
        timeZoneId = geoCodeData.timeZone?.identifier ?? ""
        timeZoneName = geoCodeData.timeZone?.abbreviation() ?? ""
        zipcode = geoCodeData.isoCountryCode ?? ""
        
        if let addDict = geoCodeData.addressDictionary as NSDictionary? {
            nprint(items: addDict)
            if let arr = addDict["FormattedAddressLines"] as? NSArray {
                formatedAddress = arr.componentsJoined(by: ", ")
            }
            name = addDict.getStringValue(key: "Name")
            address1 = addDict.getStringValue(key: "Name")
            street = addDict.getStringValue(key: "Street")
            city = addDict.getStringValue(key: "City")
            state = addDict.getStringValue(key: "State")
            country = addDict.getStringValue(key: "Country")
            
            if address1 == street {
                street = ""
            }
            
            if city.isEmpty {
                city = addDict.getStringValue(key: "SubAdministrativeArea")
            }
            
            if !name.isEmpty {
                fullName = name
            }
            if !city.isEmpty {
                if fullName.isEmpty {
                    fullName = city
                } else {
                    fullName.append(", \(city)")
                }
            }
            if !state.isEmpty {
                if fullName.isEmpty {
                    fullName = state
                } else {
                    fullName.append(", \(state)")
                }
            }
        }
        
        if let loc = geoCodeData.location{
            lat = loc.coordinate.latitude
            long = loc.coordinate.longitude
        }
    }
    
    init(dict: NSDictionary) {
        name = dict.getStringValue(key: "name")
        fullName = dict.getStringValue(key: "fullName")
        formatedAddress = dict.getStringValue(key: "formatted_address")
        zipcode = dict.getStringValue(key: "zip")
        timeZoneId = dict.getStringValue(key: "timeZoneId")
        timeZoneName = dict.getStringValue(key: "timeZoneName")
        if let geo = dict["geometry"] as? NSDictionary, let loc = geo["location"] as? NSDictionary {
            lat = loc.getDoubleValue(key: "lat")
            long = loc.getDoubleValue(key: "lng")
        } else if let lat = dict["lat"] as? Double, let long = dict["long"] as? Double{
            self.lat = lat
            self.long = long
        }
    }
    
    init(googledict dict: NSDictionary) {
        
        placeId = dict.getStringValue(key: "place_id")
        name = dict.getStringValue(key: "name")
        formatedAddress = dict.getStringValue(key: "formatted_address")
        refCode = dict.getStringValue(key: "reference")
        
        if let geo = dict["geometry"] as? NSDictionary, let loc = geo["location"] as? NSDictionary {
            lat = loc.getDoubleValue(key: "lat")
            long = loc.getDoubleValue(key: "lng")
        }
        
        addressComponents = [AddressComponent]()
        if let addDict = dict["address_components"] as? [NSDictionary] {
            for dic in addDict{
                let value = AddressComponent(dic)
                addressComponents.append(value)
            }
        }
        
        for add in self.addressComponents {
            if add.types.contains("country") {
                self.country = add.longName
                self.countryShortName = add.shortName
            } else if add.types.contains("administrative_area_level_1") {
                self.state = add.longName
            } else if add.types.contains("sublocality_level_1") {
                self.address1 = add.longName
            } else if add.types.contains("locality") {
                self.city = add.longName
            } else if add.types.contains("postal_code") {
                self.zipcode = add.longName
            }
        }
        
        let acity = self.city
        let aState = self.state
        
        if ((acity == "") || (aState == "") ){
            if (city.isEmpty && !state.isEmpty && self.name! != state) {
                self.address =  "\(self.name!), \(self.state)"
            }else if (!city.isEmpty && state.isEmpty && city != name!) {
                self.address =  "\(self.name!), \(self.city)"
            }else{
                self.address =  "\(self.name!)"
            }
        } else {
            
            if name! != city {
                name.append(", \(city)")
            }
            if name! != state {
                name.append(", \(state)")
            }
            self.address = name
        }
        
        if self.name != ""{
            self.customAddress = self.name!
        }
        if self.address1 != ""{ // sub_locality_1
            self.customAddress = "\(self.customAddress), \(self.address1)"
        }
        if self.city != ""{ // locality
            self.customAddress = "\(self.customAddress), \(self.city)"
        }
        if self.state != ""{ // administrative_area_level_1
            self.customAddress = "\(self.customAddress), \(self.state)"
        }
        if self.country != ""{
            self.customAddress = "\(self.customAddress), \(self.country)"
        }
        if self.zipcode != ""{
            self.customAddress = "\(self.customAddress), \(self.zipcode)"
        }
        
    }
    
    init(history dict: NSDictionary) {
        placeId = dict.getStringValue(key: "place_id")
        name = dict.getStringValue(key: "name")
        secondryText = dict.getStringValue(key: "secondryText")
        fullName = dict.getStringValue(key: "fullName")
        formatedAddress = dict.getStringValue(key: "formatted_address")
        customAddress = dict.getStringValue(key: "custom_address")
        address1 = dict.getStringValue(key: "address1")
        address = dict.getStringValue(key: "address")
        city = dict.getStringValue(key: "city")
        state = dict.getStringValue(key: "state")
        country = dict.getStringValue(key: "country")
        zipcode = dict.getStringValue(key: "zip_code")
        timeZoneId = dict.getStringValue(key: "timeZoneId")
        timeZoneName = dict.getStringValue(key: "timeZoneName")
        lat = dict.getDoubleValue(key: "lat")
        long = dict.getDoubleValue(key: "long")
    }
    
    init(fromDict: NSDictionary) {
        name = fromDict.getStringValue(key: "from_location")
        formatedAddress = fromDict.getStringValue(key: "from_formatted_address")
        customAddress = fromDict.getStringValue(key: "from_location")
        city = fromDict.getStringValue(key: "from_city")
        state = fromDict.getStringValue(key: "from_state")
        country = fromDict.getStringValue(key: "from_county")
        timeZoneId = fromDict.getStringValue(key: "from_time_zone_id")
        timeZoneName = fromDict.getStringValue(key: "from_time_zone_name")
        zipcode = fromDict.getStringValue(key: "from_zipcode")
        lat = fromDict.getDoubleValue(key: "from_latitude")
        long = fromDict.getDoubleValue(key: "from_longitude")
    }
    
    init(toDict: NSDictionary) {
        name = toDict.getStringValue(key: "to_location")
        formatedAddress = toDict.getStringValue(key: "to_formatted_address")
        customAddress = toDict.getStringValue(key: "to_location")
        city = toDict.getStringValue(key: "to_city")
        state = toDict.getStringValue(key: "to_state")
        country = toDict.getStringValue(key: "to_county")
        timeZoneId = toDict.getStringValue(key: "to_time_zone_id")
        timeZoneName = toDict.getStringValue(key: "to_time_zone_name")
        zipcode = toDict.getStringValue(key: "to_zipcode")
        lat = toDict.getDoubleValue(key: "to_latitude")
        long = toDict.getDoubleValue(key: "to_longitude")
    }
    init(homeDict: NSDictionary) {
        name = homeDict.getStringValue(key: "home_address")
        formatedAddress = homeDict.getStringValue(key: "home_address")
        customAddress = homeDict.getStringValue(key: "home_address")
        city = homeDict.getStringValue(key: "city")
        state = homeDict.getStringValue(key: "state")
        country = homeDict.getStringValue(key: "county")
//        timeZoneId = homeDict.getStringValue(key: "to_time_zone_id")
//        timeZoneName = homeDict.getStringValue(key: "to_time_zone_name")
        zipcode = homeDict.getStringValue(key: "zipcode")
        lat = homeDict.getDoubleValue(key: "latitude")
        long = homeDict.getDoubleValue(key: "longitude")
    }
    init(stop: StopoverDetail) {
        fullName = stop.fromLocation
        formatedAddress = stop.fromLocation
    }
    
    func copy() -> SearchAddress {
        let data: SearchAddress = SearchAddress()
        data.name = self.name
        data.customAddress = self.customAddress
        data.refCode = self.refCode
        data.fullName = self.fullName
        data.timeZoneId = self.timeZoneId
        data.timeZoneName = self.timeZoneName
        
        data.lat = self.lat
        data.long = self.long
        
        data.address1 = self.address1
        data.address2 = self.address2
        data.street = self.street
        data.city = self.city
        data.state = self.state
        data.country = self.country
        data.zipcode = self.zipcode
        data.formatedAddress = self.formatedAddress
        
        return data
    }
    
    var jsonData: [String: Any] {
        var param: [String: Any] = [:]
        param["place_id"] = placeId
        param["name"] = name
        param["secondryText"] = secondryText
        param["fullName"] = fullName
        param["formatted_address"] = formatedAddress
        param["custom_address"] = customAddress
        param["address1"] = address1
        param["address"] = address
        param["city"] = city
        param["state"] = state
        param["country"] = country
        param["zip_code"] = zipcode
        param["timeZoneId"] = timeZoneId
        param["timeZoneName"] = timeZoneName
        param["lat"] = lat.rounded(toPlaces: 7)
        param["long"] = long.rounded(toPlaces: 7)
        return param
    }
    
    var fromParam: [String: Any] {
        var param: [String: Any] = [:]
        param["from_location"] = name
        param["from_formatted_address"] = formatedAddress
        param["from_city"] = city
        param["from_state"] = state
        param["from_county"] = country
        param["from_zipcode"] = zipcode
        param["from_time_zone_id"] = timeZoneId
        param["from_time_zone_name"] = timeZoneName
        param["from_latitude"] = lat.rounded(toPlaces: 7)
        param["from_longitude"] = long.rounded(toPlaces: 7)
        return param
    }
    
    var toParam: [String: Any] {
        var param: [String: Any] = [:]
        param["to_location"] = name
        param["to_formatted_address"] = formatedAddress
        param["to_city"] = city
        param["to_state"] = state
        param["to_county"] = country
        param["to_zipcode"] = zipcode
        param["to_time_zone_id"] = timeZoneId
        param["to_time_zone_name"] = timeZoneName
        param["to_latitude"] = lat.rounded(toPlaces: 7)
        param["to_longitude"] = long.rounded(toPlaces: 7)
        return param
    }
    
    func isValidLocation() -> Bool {
        if city.isEmpty {
            return false
        } else if city == name! {
            return false
        } else if state.isEmpty {
            return false
        }
        return true
    }
}

// MARK: - AddressComponent
class AddressComponent : NSObject{
    
    var longName : String! = ""
    var shortName : String! = ""
    var types : [String]! = []
    
    init(_ dict: NSDictionary){
        longName = dict.getStringValue(key: "long_name")
        shortName = dict.getStringValue(key: "short_name")
        types = []
        
        if let typesArray = dict["types"] as? [String]{
            for dic in typesArray{
                types.append(dic)
            }
        }
    }
}

// MARK: - ResponceType
enum ResponceType:Int {
    case success = 0
    case loading
    case noResult
    case netWorkError
}

// MARK: - KPAPICalls
class KPAPICalls: NSObject {
    
    static let shared = KPAPICalls()
    let geoLocation = CLGeocoder()
    
    // Google API
    /// Search location by name and returns custom address with reference code
    ///
    /// - Parameters:
    ///   - text: Search Text
    ///   - block: Returns search addresses and responce type enum like(noResult, network error)
    /// - Returns: URLSessionDataTask for cancel previous request
    func getReferenceFromSearchText(text: String, block:@escaping (([SearchAddress],ResponceType)->())) -> URLSessionDataTask{
        let str = text.addingPercentEncoding(withAllowedCharacters: CharacterSet.letters)
        
        var url: URL!
        if _hostMode == .production {
            url = URL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(str!)&sensor=false&key=\(googleKey)&components=country:CA")!
        } else {
            url = URL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(str!)&sensor=false&key=\(googleKey)")!
        }
        
//        let url = URL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(str!)&location=52.136436,-0.460739&radius=500000&strictbounds&key=\(googleKey)")!
        
        let req = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: req, completionHandler: { (dataObj, urlRes, err) in
            var resType = ResponceType.success
            var arrAddress: [SearchAddress] = []
            if let res = urlRes as? HTTPURLResponse, dataObj != nil {
                if res.statusCode == 200 {
                    let objJson = try! JSONSerialization.jsonObject(with: dataObj!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let json = objJson as! NSDictionary
                    nprint(items: json)
                    if json["status"] as! String == "OK" {
                        if let data = json["predictions"] as? NSDictionary {
                            let add = SearchAddress(googleData: data)
                            arrAddress.append(add)
                        } else if let dataArr = json["predictions"] as? [NSDictionary] {
                            for data in dataArr {
                                let add = SearchAddress(googleData: data)
                                arrAddress.append(add)
                            }
                        }
                        resType = .success
                    } else if json["status"] as! String == "ZERO_RESULTS" {
                        resType = .noResult
                    } else {
                        resType = .success
                    }
                } else {
                    resType = .netWorkError
                }
            } else {
                if (err! as NSError).code != -999 {
                    resType = .netWorkError
                }
            }
            
            DispatchQueue.main.async {
                block(arrAddress, resType)
            }
        })
        task.resume()
        return task
    }
    
    // Google API
    /// Get Location with lat, logn and formatted address.
    ///
    /// - Parameters:
    ///   - ref: reference id of location
    ///   - block: return fullAddress structure and error.
    func getLocationFromPlaceId(placeId: String, block:@escaping ((SearchAddress?, NSError?)->())) {
//        let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?reference=\(ref)&sensor=false&key=\(googleKey)")
        
        var params: [String: String] = [:]
        params["placeid"] = placeId
        params["key"] = googleKey
        
        var queryString = ""
        for (key, value) in params {
            if queryString == "" {
                queryString = key + "=" + value
            }
            else {
                queryString = queryString + "&" + key + "=" + value
            }
        }
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?" + queryString)
        let req = URLRequest(url: url!)
        URLSession.shared.dataTask(with: req) { (data, resObj, error) in
            if let res = resObj as? HTTPURLResponse, data != nil {
                if res.statusCode == 200 {
                    var tmpAddress: SearchAddress?
                    let jsonObj = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let json = jsonObj as! NSDictionary
                    if let data = json["result"] as? NSDictionary {
                        tmpAddress = SearchAddress(googledict: data)
                    } else if let data = json["result"] as? [NSDictionary] {
                        tmpAddress = SearchAddress(googledict: data[0])
                    }
                    DispatchQueue.main.async {
                        block(tmpAddress, error as NSError?)
                    }
                } else {
                    DispatchQueue.main.async {
                        block(nil, error as NSError?)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    block(nil, error as NSError?)
                }
            }
            }.resume()
    }
    
    // Google API
    /// Get Location with lat, logn and formatted address.
    ///
    /// - Parameters:
    ///   - ref: reference id of location
    ///   - block: return fullAddress structure and error.
    func getLocationFromReference(ref: String, block:@escaping ((SearchAddress?, NSError?)->())) {
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?reference=\(ref)&sensor=false&key=\(googleKey)")
        let req = URLRequest(url: url!)
        URLSession.shared.dataTask(with: req) { (data, resObj, error) in
            if let res = resObj as? HTTPURLResponse, data != nil {
                if res.statusCode == 200 {
                    var tmpAddress: SearchAddress?
                    let jsonObj = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let json = jsonObj as! NSDictionary
                    if let data = json["result"] as? NSDictionary {
                        tmpAddress = SearchAddress(dict: data)
                    } else if let data = json["result"] as? [NSDictionary] {
                        tmpAddress = SearchAddress(dict: data[0])
                    }
                    DispatchQueue.main.async {
                        block(tmpAddress, error as NSError?)
                    }
                } else {
                    DispatchQueue.main.async {
                        block(nil, error as NSError?)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    block(nil, error as NSError?)
                }
            }
            }.resume()
    }
    
    // // Google API
    /// Fetch address from lat, long
    ///
    /// - Parameters:
    ///   - lat: latitite
    ///   - long: longitute
    ///   - block: return formatted address string
    func getPlaceIdFromLatLong(lat: String, long: String, block:@escaping ((String?)->())) {
        let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(long)&,sensor=true&key=\(googleKey)")
        let req = URLRequest(url: url!)
        URLSession.shared.dataTask(with: req) { (data, resObj, error) in
            if let res = resObj as? HTTPURLResponse, data != nil {
                if res.statusCode == 200 {
                    var tmpAddress: String?
                    let jsonObj = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let json = jsonObj as! NSDictionary
                    nprint(items: json)
                    if json["status"] as! String == "OK" {
                        if let data = json["results"] as? NSDictionary {
                            tmpAddress = data.getStringValue(key: "place_id")
                        } else if let data = json["results"] as? [NSDictionary] {
                            tmpAddress = data[0].getStringValue(key: "place_id")
                        }
                    }
                    DispatchQueue.main.async {
                        block(tmpAddress)
                    }
                } else {
                    DispatchQueue.main.async {
                       block(nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    block(nil)
                }
            }
            }.resume()
    }
    
    // // Google API
    /// Fetch address from lat, long
    ///
    /// - Parameters:
    ///   - lat: latitite
    ///   - long: longitute
    ///   - block: return formatted address string
    func getAddressFromLatLong(lat: String, long: String, block:@escaping ((SearchAddress?)->())) {
//

//        let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(long)&key=\(googleKey))")
        let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(long)&,sensor=true&key=\(googleKey)")
        
        let req = URLRequest(url: url!)
        URLSession.shared.dataTask(with: req) { (data, resObj, error) in
            if let res = resObj as? HTTPURLResponse, data != nil {
                if res.statusCode == 200 {
                    var tmpAddress: SearchAddress?
                    let jsonObj = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let json = jsonObj as! NSDictionary
                    nprint(items: json)
                    if json["status"] as! String == "OK" {
                        if let data = json["results"] as? NSDictionary {
                            tmpAddress = SearchAddress(dict: data)
                        } else if let data = json["results"] as? [NSDictionary] {
                            tmpAddress = SearchAddress(dict: data[0])
                        }
                    }
                    DispatchQueue.main.async {
                        block(tmpAddress)
                    }
                } else {
                    DispatchQueue.main.async {
                       block(nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    block(nil)
                }
            }
            }.resume()
    }
    
    
    // Geo Code
    /// address from CLLocation
    ///
    /// - Parameters:
    ///   - location: CLLocation object
    ///   - block: return formatted address string
    func addressFromlocation(location: CLLocation, block: @escaping (SearchAddress?)->()) {
        geoLocation.cancelGeocode()
        geoLocation.reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) -> Void in
            if let pmark = placeMarks, pmark.count > 0 {
                let address: SearchAddress?
                let place :CLPlacemark = pmark.last! as CLPlacemark
                address = SearchAddress(geoCodeData: place)
                DispatchQueue.main.async {
                    block(address)
                }
            } else {
                DispatchQueue.main.async {
                    block(nil)
                }
            }
        })
    }
    
    func getLocationTimeZone(_ address: SearchAddress, block: @escaping (SearchAddress)->()) {
        var params: [String: String] = [:]
        params["location"] = "\(address.lat),\(address.long)"
        params["timestamp"] = "\(Date().timeIntervalSince1970)"
        params["key"] = googleKey
        var queryString = ""
        for (key, value) in params {
            if queryString == "" {
                queryString = key + "=" + value
            }
            else {
                queryString = queryString + "&" + key + "=" + value
            }
        }
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/timezone/json?" + queryString)
        let req = URLRequest(url: url!)
        URLSession.shared.dataTask(with: req) { (data, resObj, error) in
            if let res = resObj as? HTTPURLResponse, data != nil {
                if res.statusCode == 200 {
                    let jsonObj = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let json = jsonObj as! NSDictionary
                    let tId: String = json.getStringValue(key: "timeZoneId")
                    let tName: String = json.getStringValue(key: "timeZoneName")
                    address.timeZoneId = tId
                    address.timeZoneName = tName
                    DispatchQueue.main.async {
                        block(address)
                    }
                } else {
                    DispatchQueue.main.async {
                        block(address)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    block(address)
                }
            }
            }.resume()
    }
    
    func getLocationTimeZone(_ lat: Double, _ long: Double, block: @escaping (String?, String?)->()) {
        var params: [String: String] = [:]
        params["location"] = "\(lat),\(long)"
        params["timestamp"] = "\(Date().timeIntervalSince1970)"
        params["key"] = googleKey
        var queryString = ""
        for (key, value) in params {
            if queryString == "" {
                queryString = key + "=" + value
            }
            else {
                queryString = queryString + "&" + key + "=" + value
            }
        }
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/timezone/json?" + queryString)
        let req = URLRequest(url: url!)
        URLSession.shared.dataTask(with: req) { (data, resObj, error) in
            if let res = resObj as? HTTPURLResponse, data != nil {
                if res.statusCode == 200 {
                    let jsonObj = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let json = jsonObj as! NSDictionary
                    let tId: String = json.getStringValue(key: "timeZoneId")
                    let tName: String = json.getStringValue(key: "timeZoneName")
                    DispatchQueue.main.async {
                        block(tId, tName)
                    }
                } else {
                    DispatchQueue.main.async {
                        block(nil, nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    block(nil, nil)
                }
            }
            }.resume()
    }

    // Geocode
    /// Search address with geocode
    ///
    /// - Parameters:
    ///   - str: Search string
    ///   - block: Returns search addresses and responce type enum like(noResult, network error)
    func searchAddressBygeocode(str: String, block:@escaping (([SearchAddress],ResponceType)->())) {
        geoLocation.cancelGeocode()
        geoLocation.geocodeAddressString(str) { (placeMarks, error) in
            if let pmark = placeMarks, pmark.count > 0 {
                var arrPlace:[SearchAddress] = []
                for place in pmark{
                    let add = SearchAddress(geoCodeData: place)
                    arrPlace.append(add)
                }
                
                DispatchQueue.main.async {
                    block(arrPlace, ResponceType.success)
                }
            } else {
                if let err = error as NSError?{
                    if err.code != 10 {
                        DispatchQueue.main.async {
                            block([], ResponceType.noResult)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        block([], ResponceType.netWorkError)
                    }
                }
            }
        }
    }
    
    // MARK: - GET PLACEInfo
    func getWayPoints(origin: String, dest: String, stopOvers : [String], block : @escaping (_ items : WayPoints?, _ errorDescription : String?) -> Void) {
        
        var params: [String: String] = [:]
        params["origin"] = origin//.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)//"place_id:\(originPlaceId)"
        params["destination"] = dest//.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)//"place_id:\(destPlaceId)"
        params["key"] = googleKey
        params["mode"] = "driving"
        params["sensor"] = "false"
        
        if stopOvers.count > 0 {
            let wayPonts = stopOvers.joined(separator: "|")
            params["waypoints"] = "optimize:true|\(wayPonts)"//"optimize:true|\(wayPonts.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
        }
        
        var queryString = ""
        for (key, value) in params {
            if queryString == "" {
                queryString = key + "=" + value
            }
            else {
                queryString = queryString + "&" + key + "=" + value
            }
        }
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?" + queryString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)
        
//            let objPlaceInfo = WayPoints(fromDictionary: dict! as! [String:AnyObject?])

            let req = URLRequest(url: url!)
        URLSession.shared.dataTask(with: req) { (data, resObj, error) in
            if let res = resObj as? HTTPURLResponse, data != nil {
                if res.statusCode == 200 {
                    let jsonObj = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let json = jsonObj as! NSDictionary
                    nprint(items: json)
                    
                    DispatchQueue.main.async {
                        block(WayPoints(json), nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        block(nil, error?.localizedDescription)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    block(nil, error?.localizedDescription)
                }
            }
            }.resume()
    }
}

// MARK: - WayPoints
class WayPoints : NSObject{
    
    var geocodedWaypoints : [GeocodedWaypoint]! = []
    var routes : [RouteModel]! = []
    var status : String!  = ""
        
    var jsonData: [String: Any] {
        var param: [String: Any] = [:]
        param["status"] = status
        if geocodedWaypoints != nil{
            var dictionaryElements = [NSDictionary]()
            for geocodedWaypointsElement in geocodedWaypoints {
                dictionaryElements.append(geocodedWaypointsElement.jsonData as NSDictionary)
            }
            param["geocodedWaypoints"] = dictionaryElements
        }
        if routes != nil{
            var dictionaryElements = [NSDictionary]()
            for routesElement in routes {
                dictionaryElements.append(routesElement.jsonData as NSDictionary)
            }
            param["routes"] = dictionaryElements
        }
        return param
    }
    
    override init() { }
    
    init(_ dict: NSDictionary){
        status = dict.getStringValue(key: "status")
        geocodedWaypoints = [GeocodedWaypoint]()
        if let geocodedWaypointsArray = dict["geocoded_waypoints"] as? [NSDictionary]{
            for dic in geocodedWaypointsArray{
                let value = GeocodedWaypoint(dic)
                geocodedWaypoints.append(value)
            }
        }
        routes = [RouteModel]()
        if let routesArray = dict["routes"] as? [NSDictionary]{
            for dic in routesArray{
                let value = RouteModel(dic)
                routes.append(value)
            }
        }
    }
}

// MARK: - RouteModel
class RouteModel : NSObject{
    
    var legs : [Leg]! = []
    var overviewPolyline : OverviewPolyline!
    var waypointOrder : [Int]! = []
    
    var jsonData: [String: Any] {
        var param: [String: Any] = [:]
        param["waypoint_order"] = waypointOrder
        param["overview_polyline"] = overviewPolyline.jsonData
        if legs != nil{
            var dictionaryElements = [NSDictionary]()
            for legsElement in legs {
                dictionaryElements.append(legsElement.jsonData as NSDictionary)
            }
            param["legs"] = dictionaryElements
        }
        return param
    }
    
    override init() { }
    
    init(_ dict: NSDictionary){
        waypointOrder = []
        if let typesArray = dict["waypoint_order"] as? [Int]{
            for dic in typesArray{
                waypointOrder.append(dic)
            }
        }
        if let overviewPolylineData = dict["overview_polyline"] as? NSDictionary{
            overviewPolyline = OverviewPolyline(overviewPolylineData)
        }
        legs = [Leg]()
        if let legsArray = dict["legs"] as? [NSDictionary]{
            for dic in legsArray{
                let value = Leg(dic)
                legs.append(value)
            }
        }
    }
}

// MARK: - LocationLatLong
class LocationLatLong : NSObject{
    
    var lat : Double! = 0.0
    var lng : Double! = 0.0
    
    var jsonData: [String: Any] {
        var param: [String: Any] = [:]
        param["lat"] = lat
        param["lng"] = lng
        return param
    }
    
    init(_ dict: NSDictionary){
        lat = dict.getDoubleValue(key: "lat")
        lng = dict.getDoubleValue(key: "lng")
    }
}

// MARK: - OverviewPolyline
class OverviewPolyline : NSObject{
    
    var points : String!  = ""
    
    var jsonData: [String: Any] {
        var param: [String: Any] = [:]
        param["points"] = points
        return param
    }
    
    override init() { }
    
    init(_ dict: NSDictionary){
        points = dict.getStringValue(key: "points")
    }
}

// MARK: - Duration
class Duration : NSObject{
    
    var text : String!  = ""
    var value : Double! = 0.0
    
    var jsonData: [String: Any] {
        var param: [String: Any] = [:]
        param["text"] = text
        param["value"] = value
        return param
    }
    
    override init() { }
    
    init(_ dict: NSDictionary){
        text = dict.getStringValue(key: "text")
        value = dict.getDoubleValue(key: "value")
    }
}

// MARK: - Step
class Step : NSObject{
    
    var distance : Duration!
    var duration : Duration!
    var endLocation : LocationLatLong!
    var htmlInstructions : String!  = ""
    var maneuver : String!  = ""
    var polyline : OverviewPolyline!
    var startLocation : LocationLatLong!
    var travelMode : String!  = ""
    
    var jsonData: [String: Any] {
        var param: [String: Any] = [:]
        param["html_instructions"] = htmlInstructions
        param["maneuver"] = maneuver
        param["travel_mode"] = maneuver
        param["distance"] = maneuver
        param["duration"] = maneuver
        param["end_location"] = maneuver
        param["polyline"] = maneuver
        param["start_location"] = maneuver
        return param
    }
    
    override init() { }
    
    init(_ dict: NSDictionary){
        htmlInstructions = dict.getStringValue(key: "html_instructions")
        maneuver = dict.getStringValue(key: "points")
        travelMode = dict.getStringValue(key: "travel_mode")
        if let distanceData = dict["distance"] as? NSDictionary{
            distance = Duration(distanceData)
        }
        if let durationData = dict["duration"] as? NSDictionary{
            duration = Duration(durationData)
        }
        if let endLocationData = dict["end_location"] as? NSDictionary{
            endLocation = LocationLatLong(endLocationData)
        }
        if let polylineData = dict["polyline"] as? NSDictionary{
            polyline = OverviewPolyline(polylineData)
        }
        if let startLocationData = dict["start_location"] as? NSDictionary{
            startLocation = LocationLatLong(startLocationData)
        }
    }
}

// MARK: - Leg
class Leg : NSObject{
    
    var distance : Duration!
    var duration : Duration!
    var endAddress : String!  = ""
    var endLocation : LocationLatLong!
    var startAddress : String!  = ""
    var startLocation : LocationLatLong!
    var steps : [Step]!
    
    var jsonData: [String: Any] {
        var param: [String: Any] = [:]
        param["end_address"] = endAddress
        param["start_address"] = startAddress
        param["distance"] = distance.jsonData
        param["duration"] = duration.jsonData
        param["end_location"] = endLocation.jsonData
        param["start_location"] = startLocation.jsonData
        if steps != nil {
            var dictionaryElements = [[String:Any]]()
            for stepsElement in steps {
                dictionaryElements.append(stepsElement.jsonData)
            }
            param["steps"] = dictionaryElements
        }
        return param
    }
    
    override init() { }
    
    init(_ dict: NSDictionary){
        endAddress = dict.getStringValue(key: "end_address")//dictionary["end_address"] as? String
        startAddress = dict.getStringValue(key: "start_address")//dictionary["start_address"] as? String
        if let distanceData = dict["distance"] as? NSDictionary{
            distance = Duration(distanceData)
        }
        if let durationData = dict["duration"] as? NSDictionary{
            duration = Duration(durationData)
        }
        if let endLocationData = dict["end_location"] as? NSDictionary{
            endLocation = LocationLatLong(endLocationData)
        }
        if let startLocationData = dict["start_location"] as? NSDictionary{
            startLocation = LocationLatLong(startLocationData)
        }
        steps = [Step]()
        if let stepsArray = dict["steps"] as? [[String:Any]]{
            for dic in stepsArray{
                let value = Step(dic as NSDictionary)
                steps.append(value)
            }
        }
    }
}

// MARK: - GeocodedWaypoint
class GeocodedWaypoint : NSObject{
    
    var geocoderStatus : String! = ""
    var placeId : String! = ""
    var types : [String]! = []
    
    var jsonData: [String: Any] {
        var param: [String: Any] = [:]
        param["geocoder_status"] = geocoderStatus
        param["place_id"] = placeId
        param["types"] = types
        return param
    }
    
    override init() { }
   
    init(_ dict: NSDictionary){
        geocoderStatus = dict.getStringValue(key: "geocoder_status")
        placeId = dict.getStringValue(key: "place_id")
        types = []
        if let typesArray = dict["types"] as? [String]{
            for dic in typesArray{
                types.append(dic)
            }
        }
    }
}
