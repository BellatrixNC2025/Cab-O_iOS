//
//  SosVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import Lottie

class SosVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var topRightVector: UIImageView!
    @IBOutlet weak var viewAnimation: LottieAnimationView!
    @IBOutlet weak var topRightImage: UIImageView!
    @IBOutlet weak var topHeaderView: UIView!
    @IBOutlet weak var imgBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var animationHeight: NSLayoutConstraint!
    @IBOutlet weak var topRightImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var sosSwipeButton: SlideToActionButton!
    
    /// Variables
    var tableHeaderHeight:CGFloat = 180 * _heightRatio
    var arrCells: [SosCellType] = [.title, .info1, .info2, .emeType, .car, .location]
    var carDetails: CarDetailModel!
    var rideId: Int!
    var bookingId: Int?
    var data = SosModel()
    var arrEmergencyTypes: [EmergencyType] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getTypes()
        getUserLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAnimation(named: .sos)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimation()
    }
}

// MARK: - UI Methods
extension SosVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: tableHeaderHeight, left: 0, bottom: 0, right: 0)
        imgBottomConstraint.constant = (DeviceType.iPad ? 0 : 50) * _heightRatio
        animationHeight.constant = (DeviceType.iPad ? 124 : 114) * _heightRatio
        topRightImageHeight.constant = (DeviceType.iPad ? 124 : 114) * _heightRatio
        sosSwipeButton.delegate = self
        prepareTblHeader()
        TitleTVC.prepareToRegisterCells(tableView)
    }
    
    func prepareTblHeader() {
        tableView.tableHeaderView = nil
        topHeaderView.clipsToBounds = false
        topHeaderView.layer.zPosition = -1
        tableView.addSubview(topHeaderView!)
        tableView.contentInset = UIEdgeInsets(top: (tableHeaderHeight - _statusBarHeight), left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -(tableHeaderHeight + _statusBarHeight))
    }
    
    func loadAnimation(named ani: LottieAnimationName) {
        stopAnimation()
        let animation = LottieAnimation.named(ani.rawValue, bundle: Bundle.main)
        viewAnimation?.contentMode = .scaleAspectFit
        viewAnimation?.animation = animation
        viewAnimation?.play()
        viewAnimation?.loopMode = .loop
    }
    
    func stopAnimation() {
        viewAnimation?.stop()
        viewAnimation?.animation = nil
    }
    
    func getUserLocation() {
        UserLocation.sharedInstance.fetchUserLocationForOnce(controller: self) { (location, error) in
            if let _ = location{
                if isGooleKeyFound{
                    KPAPICalls.shared.getAddressFromLatLong(lat: "\(location!.coordinate.latitude)", long: "\(location!.coordinate.longitude)", block: { (addres) in
                        if let addres{
                            nprint(items: addres.formatedAddress)
                            self.data.location = addres.formatedAddress
                            self.data.lat = addres.lat
                            self.data.long = addres.long
                            self.tableView.reloadData()
                        }
                    })
                } else {
                    KPAPICalls.shared.addressFromlocation(location: location!, block: { (addres) in
                        if let addres{
                            nprint(items: addres.formatedAddress)
                            self.data.location = addres.formatedAddress
                            self.data.lat = addres.lat
                            self.data.long = addres.long
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        }
    }
}

// MARK: - SlideToActionButtonDelegate
extension SosVC: SlideToActionButtonDelegate {
    
    func didFinish() {
        if data.emergencyType == nil {
            ValidationToast.showStatusMessage(message: "Select the type of emergency", yCord: _navigationHeight)
            self.sosSwipeButton.reset()
        }
        else if data.location == nil {
            ValidationToast.showStatusMessage(message: "Location not available", yCord: _navigationHeight)
            self.sosSwipeButton.reset()
        }
        else {
            self.raiseSosAlert()
        }
    }
}

//MARK: - TableView Methods
extension SosVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if cellType == .title || cellType == .info1 || cellType == .info2 {
            let height = cellType.title.heightWithConstrainedWidth(width: _screenSize.width - ((cellType == .title ? 40 : 80) * _widthRatio), font: cellType.font)
            return height + (cellType == .title ? 16 * _heightRatio : 24 * _heightRatio)
        } else if cellType == .car {
            let carDetail = carDetails.company + " - " + carDetails.licencePlate
            return carDetail.heightWithConstrainedWidth(width: _screenSize.width - 100 * _widthRatio, font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + 50 * _heightRatio
        } else if cellType == .location {
            let loc = data.location ?? ""
            return loc.heightWithConstrainedWidth(width: _screenSize.width - (100 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + 58 * _heightRatio
        } else if cellType == .emeType {
            if arrEmergencyTypes.isEmpty {
                return 0
            }
        }
        return arrCells[indexPath.row].cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: arrCells[indexPath.row].cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? TitleTVC {
            cell.prepareUI(cellType.title, cellType.font, clr: AppColor.primaryText)
        }
        else if let cell = cell as? SosCell {
            if cellType == .car {
                cell.imgView.image = cellType.img
                cell.lblTitle.text = cellType.title
                cell.lblDesc.text = carDetails.company + " - " + carDetails.licencePlate
            } else if cellType == .location {
                cell.imgView.image = cellType.img
                cell.lblTitle.text = cellType.title
                cell.lblDesc.text = data.location ?? ""
            } else if cellType == .emeType {
                cell.lblTitle.text = cellType.title
                cell.registerCell()
                cell.arrData = arrEmergencyTypes
                cell.selectionCallBack = { [weak self] (type) in
                    guard let self = self else { return }
                    self.data.emergencyType = type
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var headerRect = CGRect(x: 0, y: -tableHeaderHeight, width: tableView.bounds.width, height: tableHeaderHeight + _statusBarHeight)
        if tableView.contentOffset.y < -tableHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y + _statusBarHeight
        }
        topHeaderView!.frame = headerRect
    }
}

// MARK: - API Call
extension SosVC {
    
    private func getTypes() {
        showCentralSpinner()
        WebCall.call.getEmergecyTypes { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            self.arrEmergencyTypes = []
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? [NSDictionary] {
                data.forEach { eme in
                    self.arrEmergencyTypes.append(EmergencyType(eme))
                }
                self.tableView.reloadData()
            } else {
                showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    private func raiseSosAlert() {
        var param: [String: Any] = [:]
        param.merge(with: data.param)
        param["car_id"] = carDetails.id
        param["ride_id"] = rideId
        param["book_ride_id"] = bookingId
        
        showCentralSpinner()
        WebCall.call.raiseSosAlert(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.openDialer()
//                self.showSucc()
            } else {
                self.sosSwipeButton.reset()
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    private func showSucc() {
        let title: String = "Successfully raised alert to the safety response team"
        let message: String = "The safety response team will contact you immediately"
        let animation: LottieAnimationName = .checkSuccess
        let success = SuccessPopUpView.initWithWindow(title, message, anim: animation)
        success.callBack = { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func openDialer() {
        let phoneNumber = "+1911"
        let numberUrl = URL(string: "tel://\(phoneNumber)")!
        if UIApplication.shared.canOpenURL(numberUrl) {
            UIApplication.shared.open(numberUrl)
        }
        self.navigationController?.popViewController(animated: true)
    }
}
