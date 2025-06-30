//
//  SearchVC.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit
import CoreLocation
import Alamofire
import GooglePlaces

enum SearchType {
    case location
    case user
    
    var screenTitle: String {
        switch self {
        case .location: return "Select a location"
        case .user: return "Search"
        }
    }
    
    var placeHolder: String {
        switch self {
        case .location: return "Search for location"
        case .user: return "Search for user"
        }
    }
}

class LocationAddressCell: UITableViewCell {
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblSecondaryName: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnClear: UIButton!
    
    var action_clear_tap: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func btnClearTap(_ sender: UIButton) {
     action_clear_tap?()
    }
}

class SearchVC: ParentVC {
    
    /// Outlets
    @IBOutlet var tfSearch: UITextField!
    @IBOutlet weak var vwCurrentLocation: UIView!
    
    /// Variables
    var isLoading: Bool = false
    var isNoResult: Bool = false
    var screenType: SearchType = .location
    var sessionDataTask: URLSessionDataTask!
    var arrSearchHistory: [SearchAddress] = []
    var arrData :[SearchAddress] = []
    var loadType : ResponceType!
    var selectionBlock: ((_ add: SearchAddress) -> Void)!
    
    var arrChatHistory: [ChatHistory]!
    var loadMore = LoadMore()
    var requestTask: DataRequest?
    var chatSelectBlock: ((_ chat: ChatHistory) -> Void)!
    
    var searchStr: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        prepareForkeyboardNotification()
    }
}

// MARK: - UI Methods
extension SearchVC {
    
    func prepareUI() {
        lblTitle?.text = screenType.screenTitle
        
        tfSearch.clearButtonMode = .whileEditing
        tfSearch.placeholder = screenType.placeHolder
        tfSearch.font = AppFont.fontWithName(.regular, size: 14 * _fontRatio)
        tfSearch.autocorrectionType = .no
        tfSearch.returnKeyType = .search
        tfSearch.becomeFirstResponder()
        
        loadType = .success
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tfSearch.addTarget(self, action: #selector(SearchVC.searchTextDidChange), for: .editingChanged)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
        
        vwCurrentLocation.isHidden = screenType != .location
        
        if screenType == .location {
            getSearchHistory()
        }
        NoDataCell.prepareToRegisterCells(tableView)
    }
    
    func getSearchHistory() {
        if let data = _userDefault.value(forKey: _locationSearchHistory) as? [NSDictionary] {
            data.forEach { loc in
                self.arrSearchHistory.append(SearchAddress(history: loc))
            }
            tableView.reloadData()
        }
    }
    
    func updateSearchHistory(_ location: SearchAddress) {
        if !arrSearchHistory.isEmpty && arrSearchHistory.count == 10 {
            if !arrSearchHistory.contains(where: {$0.placeId == location.placeId}) {
                arrSearchHistory.removeLast()
            }
        }
        if !arrSearchHistory.contains(where: {$0.placeId == location.placeId}) {
            arrSearchHistory.insert(location, at: 0)
        }
        _userDefault.removeObject(forKey: _locationSearchHistory)
        _userDefault.set(arrSearchHistory.compactMap({$0.jsonData as NSDictionary}), forKey: _locationSearchHistory)
        _userDefault.synchronize()
    }
    
    func locationSelection(_ address: SearchAddress?,_ error: NSError?) {
        if error == nil, let address {
            self.getTimeZone(address)
        } else {
            self.showError(data: error)
        }
    }
    
    func getTimeZone(_ address: SearchAddress) {
        KPAPICalls.shared.getLocationTimeZone(address) { [weak self] (addrs) in
            guard let self = self else { return }
            nprint(items: addrs)
            self.updateSearchHistory(addrs)
            self.selectionBlock?(addrs)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func cityFromlocation(location: CLLocation, block: @escaping (_ place: CLPlacemark?, _ address: SearchAddress?)->()){
        let geoLocation = CLGeocoder()
        
        geoLocation.reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) -> Void in
            if let pmark = placeMarks, pmark.count > 0 {
                let place :CLPlacemark = pmark.last! as CLPlacemark
                let address = SearchAddress(geoCodeData: place)
                var cityName: String = ""
                if let locality = place.locality, !locality.isEmpty {
                    cityName = locality
                }
                if let subAdministrativeArea = place.administrativeArea, !subAdministrativeArea.isEmpty {
                    if cityName.isEmpty {
                        cityName = subAdministrativeArea
                    } else {
                        cityName.append(", \(subAdministrativeArea)")
                    }
                }
                if let country = place.country, !country.isEmpty {
                    if cityName.isEmpty {
                        cityName = country
                    } else {
                        cityName.append(", \(country)")
                    }
                }
                address.fullName = address.name.appending(", \(cityName)")
                
                block(place, address)
            }else{
                block(nil, nil)
            }
        })
    }
}

//MARK: - search and textfield
extension SearchVC: UITextFieldDelegate {
    
    @objc func textFieldClear(sender: UIButton) {
        tfSearch.text = ""
        searchStr = ""
        self.searchTextDidChange(textField: tfSearch)
    }
    
    @objc func searchTextDidChange(textField: UITextField) {
        if sessionDataTask != nil {
            sessionDataTask.cancel()
        }
        
        self.arrData = []
        loadType = .loading
        self.tableView.reloadData()
        
        let str = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        searchStr = str!
        
        if str!.count > 2 {
            if screenType == .location {
                if isGooleKeyFound{
                    sessionDataTask = KPAPICalls.shared.getReferenceFromSearchText(text: str!, block: { (addresses, resType) in
                        self.loadType = resType
                        self.arrData = addresses
                        self.tableView.reloadData()
                    })
                } else {
                    KPAPICalls.shared.searchAddressBygeocode(str: str!, block: { (adds, restype) in
                        self.loadType = restype
                        self.arrData = adds
                        self.tableView.reloadData()
                    })
                }
            } else {
                getChatHistory(str!)
            }
        } 
        else {
            loadMore = LoadMore()
            requestTask?.cancel()
            self.arrChatHistory = nil
            
            self.loadType = .success
            self.arrData = []
            self.tableView.reloadData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tfSearch.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}

// MARK: - Actions
extension SearchVC {
    
    @IBAction func btnCurrentLocationTap(_ sender: UIButton) {
        showCentralSpinner()
        weak var controller: UIViewController! = self
        UserLocation.sharedInstance.fetchUserLocationForOnce(controller: controller) { [weak self] (location, error) in
            guard let weakSelf = self else { return }
            weakSelf.hideCentralSpinner()
            if let _ = location{
                weakSelf.showCentralSpinner()
                KPAPICalls.shared.getPlaceIdFromLatLong(lat: "\(location!.coordinate.latitude)", long: "\(location!.coordinate.longitude)", block: { [weak self] (addres) in
                    guard let weakObj = self else { return }
                    weakObj.hideCentralSpinner()
                    if let addres {
                        weakObj.showCentralSpinner()
                        KPAPICalls.shared.getLocationFromPlaceId(placeId: addres, block: { [weak self] (address, error) in
                            guard let self = self else { return }
                            self.hideCentralSpinner()
                            self.locationSelection(address, error)
                        })
                    }
                })
            }
        }
    }
    
    func action_clear_history() {
        _userDefault.removeObject(forKey: _locationSearchHistory)
        _userDefault.synchronize()
        self.arrSearchHistory.removeAll()
        self.tableView.reloadData()
    }
    
}

// MARK: - Tableview methods
extension SearchVC: UITableViewDelegate,UITableViewDataSource {
   
    func numberOfSections(in tableView: UITableView) -> Int {
        if screenType == .user {
            return arrChatHistory == nil ? 0 : 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if screenType == .user {
            return arrChatHistory.isEmpty ? 1 : arrChatHistory.count
        } else {
            return (arrData.isEmpty && searchStr.count > 3) ? 1 : !arrData.isEmpty ? arrData.count + 1 : arrSearchHistory.count
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if screenType == .user {
            return arrChatHistory.isEmpty ? tableView.frame.height : 74 * _widthRatio
        } else {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    return 0.0
                } else {
                    return 40.0
                }
            } else {
                return 40.0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if screenType == .user {
            if arrChatHistory.isEmpty {
                return tableView.frame.height
            } else {
                return 74 * _widthRatio
            }
        }
        else {
            if (arrData.isEmpty && searchStr.count > 3) {
                return tableView.frame.height
            }
            else if indexPath.row == 0 && !arrData.isEmpty {
                if loadType == ResponceType.success {
                    return 0.0
                } else {
                    return 40.0
                }
            } else {
                if !arrData.isEmpty {
                    let height = arrData[indexPath.row - 1].name.heightWithConstrainedWidth(width: _screenSize.width - (72 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (6 * _heightRatio)
                    let secHeight = arrData[indexPath.row - 1].secondryText.heightWithConstrainedWidth(width: _screenSize.width - (72 * _widthRatio), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio)) + (6 * _heightRatio)
                    return height + secHeight + 6 * _widthRatio
                } else {
                    if arrSearchHistory.isEmpty {
                        return 0.0
                    }
                    let height = arrSearchHistory[indexPath.row].name.heightWithConstrainedWidth(width: _screenSize.width - (72 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (6 * _heightRatio)
                    let secHeight = arrSearchHistory[indexPath.row].secondryText.heightWithConstrainedWidth(width: _screenSize.width - (72 * _widthRatio), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio)) + (6 * _heightRatio)
                    return height + secHeight + 6 * _widthRatio
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if screenType == .user {
            return .leastNonzeroMagnitude
        } else {
            return 24 * _widthRatio
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if screenType == .user {
            return nil
        } else {
            if (arrData.isEmpty && searchStr.count > 3) {
                return nil
            }
            let view = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! LocationAddressCell
            if !arrData.isEmpty {
                view.lblName.text = "Search result"
                view.btnClear?.isHidden = true
            } else if !arrSearchHistory.isEmpty {
                view.lblName.text = "Search history"
                view.btnClear?.isHidden = false
                view.action_clear_tap = { [weak self] in
                    guard let self = self else { return }
                    self.action_clear_history()
                }
                
            } else {
                view.lblName.text = ""
                view.btnClear?.isHidden = true
            }
            view.lblName.font = AppFont.fontWithName(.regular, size: 10 * _fontRatio)
            view.lblName.textColor = AppColor.primaryText
            return view
        }
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if screenType == .user {
            if arrChatHistory.isEmpty {
                return tableView.dequeueReusableCell(withIdentifier: NoDataCell.identifier, for: indexPath)
            } else {
                return tableView.dequeueReusableCell(withIdentifier: "chatListCell", for: indexPath)
            }
        } else {
            if (arrData.isEmpty && searchStr.count > 3) {
                return tableView.dequeueReusableCell(withIdentifier: NoDataCell.identifier, for: indexPath)
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LocationAddressCell
            if indexPath.section == 0 {
                if !arrData.isEmpty {
                    if indexPath.row == 0 {
                        cell.selectionStyle = .none
                        if loadType == ResponceType.loading{
                            cell.lblName.text = "Loading..."
                        } else if loadType == ResponceType.noResult {
                            cell.lblName.text = "No result found"
                        } else {
                            cell.lblName.text = "Please try again"
                        }
                    } else {
                        cell.selectionStyle = .default
                        cell.imgView.image = UIImage(systemName: "pin.fill")
                        cell.lblName.text = arrData[indexPath.row - 1].name
                        cell.lblSecondaryName.text = arrData[indexPath.row - 1].secondryText
                    }
                } else if !arrSearchHistory.isEmpty {
                    cell.imgView.image = UIImage(systemName: "clock")
                    cell.lblName.text = arrSearchHistory[indexPath.row].name
                    cell.lblSecondaryName.text = arrSearchHistory[indexPath.row].secondryText
                }
            }
            cell.lblName.numberOfLines = 0
            cell.lblName.font = AppFont.fontWithName(.regular, size: 14 * _fontRatio)
            cell.lblSecondaryName.font = AppFont.fontWithName(.regular, size: 12 * _fontRatio)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? NoDataCell {
            cell.prepareUI(title: "No data found")
        }
        else if let cell = cell as? ChatHistoryCell {
            cell.prepareUI(arrChatHistory[indexPath.row])
            
            if indexPath.row == arrChatHistory.count - 1 && !loadMore.isLoading && !loadMore.isAllLoaded {
                if searchStr.count > 3 {
                    getChatHistory(searchStr)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if screenType == .user {
            if !arrChatHistory.isEmpty {
                self.dismiss(animated: false) {
                    self.chatSelectBlock?(self.arrChatHistory[indexPath.row])
                }
            }
        } else {
            self.view.endEditing(true)
            if indexPath.section == 0 {
                if loadType == .success {
                    if !arrData.isEmpty {
                        if isGooleKeyFound{
                            showCentralSpinner()
                            KPAPICalls.shared.getLocationFromPlaceId(placeId: arrData[indexPath.row - 1].placeId, block: { [weak self] (address, error) in
                                guard let self = self else { return }
                                self.hideCentralSpinner()
                                address?.secondryText = self.arrData[indexPath.row - 1].secondryText
                                self.locationSelection(address, error)
                            })
                        } else {
                            self.locationSelection(arrData[indexPath.row - 1], nil)
                        }
                    } else {
                        self.locationSelection(arrSearchHistory[indexPath.row], nil)
                    }
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

// MARK: - Keyboard Extension
extension SearchVC {
    
    func prepareForkeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(SearchVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
}

// MARK: - API Calls
extension SearchVC {
    
    func getChatHistory(_ str: String) {
        if !WebCall.call.isInternetAvailable() {
            return
        }
        loadMore.isLoading = true
        requestTask?.cancel()
        
        var param: [String: Any] = [:]
        param["offset"] = loadMore.offset
        param["limit"] = loadMore.limit
        param["search"] = str
        
        requestTask = WebCall.call.getChatHistory(param) { [weak self] (json, status) in
            guard let weakSelf = self else { return }
            weakSelf.loadMore.isLoading = false
            
            if status == 200 {
                if let data = json as? NSDictionary, let meta = data["meta"] as? NSDictionary ,let dataDict = data["data"] as? [NSDictionary] {
                    let totalCount = meta.getIntValue(key: "total_user")
                    
                    if weakSelf.loadMore.index == 0 {
                        weakSelf.arrChatHistory = []
                    }
                    
                    dataDict.forEach { (dict) in
                        weakSelf.arrChatHistory.append(ChatHistory(dict: dict))
                    }
                    
                    if dataDict.isEmpty || weakSelf.arrChatHistory.count == totalCount {
                        weakSelf.loadMore.isAllLoaded = true
                    } else {
                        weakSelf.loadMore.index += 1
                    }
                    weakSelf.tableView.reloadData()
                } else {
                    if weakSelf.loadMore.index == 0 {
                        weakSelf.arrChatHistory = []
                    }
                    weakSelf.loadMore.isAllLoaded = true
                    weakSelf.tableView.reloadData()
                }
            } else if status != 15 {
                
            }
        }
    }
}

// MARK: - GMSAutocompleteViewControllerDelegate
//extension SearchVC : GMSAutocompleteViewControllerDelegate {
//
//    func openAddressPlacePicker(country : String){
//
//        let placePickerController = GMSAutocompleteViewController()
//        placePickerController.modalPresentationStyle = .fullScreen
//        placePickerController.delegate = self
//        placePickerController.primaryTextColor = AppColor.primaryText
//        placePickerController.secondaryTextColor = AppColor.placeholderText
//        placePickerController.primaryTextHighlightColor = AppColor.primaryText
//        placePickerController.tableCellBackgroundColor = AppColor.appBg
//        placePickerController.tintColor = AppColor.primaryText
//        placePickerController.tableCellSeparatorColor = AppColor.placeholderText
//        placePickerController.view.backgroundColor = AppColor.appBg
//
//        if _appTheme != .system {
//            placePickerController.overrideUserInterfaceStyle = appTheme
//        }
//
//        present(placePickerController, animated: true, completion: nil)
//
//    }
//    // Handle the user's selection.
//    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
//
//        print("Place name: \(String(describing: place.name))")
//        print("Place address: \(String(describing: place.formattedAddress))")
//        print("Place attributions: \(String(describing: place.attributions))")
//
//        KPAPICalls.shared.getLocationFromPlaceId(placeId: place.placeID!) { [weak self] (address, error) in
//            guard let self = self else { return }
//            nprint(items: address?.name)
//            nprint(items: address?.fullName)
//            nprint(items: address?.formatedAddress)
//            nprint(items: address?.city)
//            nprint(items: address?.state)
//            nprint(items: address?.country)
//            nprint(items: address?.customAddress)
//        }
//
////        self.callGooglePlaceInfo(placeID: place.placeID!) { (placeInfo) in
////
////            if self.googlePlacePickerType == .country {
////                if self._block_getCountry != nil {
////                    self._block_getCountry!(placeInfo!)
////                }
////                viewController.dismiss(animated: true, completion: nil)
////
////            }
////        }
//    }
//
//    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
//        print("Error: ", error.localizedDescription)
//    }
//
//    // User canceled the operation.
//    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
//        viewController.dismiss(animated: true, completion: nil)
//    }
//
//    // Turn the network activity indicator on and off again.
//    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//    }
//
//    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//    }
//
//}
