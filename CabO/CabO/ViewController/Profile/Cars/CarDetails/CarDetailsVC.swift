//
//  CarDetailsVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

// MARK: - CarDetail Cell
class CarDetailCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var buttonView: UIButton!
    @IBOutlet weak var viewRejectInfo: UIView!
    @IBOutlet weak var lblRejectInfo: UILabel!
    
    @IBOutlet weak var labeOne: UILabel!
    @IBOutlet weak var labeTwo: UILabel!
    
    @IBOutlet weak var docImageView: UIImageView!
    @IBOutlet weak var viewStatus: NRoundView!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var imgStatus: TintImageView!
    
    /// Variables
    var action_viewTap:(() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewStatus?.setViewHeight(height: (DeviceType.iPad ? 22 : 18) * _widthRatio)
        imgStatus?.setViewHeight(height: (DeviceType.iPad ? 32 : 28) * _widthRatio)
    }
    
    func prepareUI(_ title: String, _ font: UIFont, clr: UIColor) {
        lblTitle.text = title
        lblTitle.font = font
        lblTitle.textColor = clr
    }
    
    func prepareCarStatusUI(_ status: DocStatus?,_ visible: Bool = true) {
        if let status {
            labelStatus.text = status.title
            labelStatus.textColor = status.statusColor
            viewStatus.borderColor = status.statusColor
            imgStatus.image = status.imgStatus
            imgStatus.tintColor = status.statusColor
            viewRejectInfo?.isHidden = status != .rejected
        }
        labelStatus.isHidden = !visible
        viewStatus.isHidden = !visible
        imgStatus.isHidden = !visible
    }
    
    func prepareCarDetailStatusUI(_ status: DocStatus?,_ visible: Bool = true, _ msg: String) {
        if let status {
            labelStatus.text = status.title
            labelStatus.textColor = status.statusColor
            viewStatus.borderColor = status.statusColor
            imgStatus.image = status.imgStatus
            imgStatus.tintColor = status.statusColor
            viewRejectInfo?.isHidden = !(status == .rejected && !msg.isEmpty)
        }
        lblRejectInfo.text = msg
        labelStatus.isHidden = !visible
        viewStatus.isHidden = !visible
        imgStatus.isHidden = !visible
    }
    
    @IBAction func action_buttonViewTap(_ sender: UIButton) {
        action_viewTap?()
    }
}

// MARK: - CarDetailsVC
class CarDetailsVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    /// Variables
    let arrCells: [CarDetailsCellype] = [.images, .name, .makeColor, .licenceAndSeats, .documentTitle, .registration, .insurance] // CarDetailsCellype.allCases
    var carId: String!
    var carData: CarDetailModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getCarDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let cell = tableView?.cellForRow(at: IndexPath(row: 0, section: 0)) as? SliderView {
            cell.startTimer()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let cell = tableView?.cellForRow(at: IndexPath(row: 0, section: 0)) as? SliderView {
            cell.stopTimer()
        }
    }
}

// MARK: - UI Methods
extension CarDetailsVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        btnEdit.isHidden = carData == nil
        btnDelete.isHidden = carData == nil
        
        registerCells()
        addRefresh()
        addObservers()
    }
    
    func addRefresh() {
        refresh.addTarget(self, action: #selector(self.refreshing(_:)), for: .valueChanged)
        self.tableView.refreshControl = refresh
    }
    
    @objc private func refreshing(_ sender: UIRefreshControl) {
        self.getCarDetails()
    }
    
    func registerCells() {
        TitleTVC.prepareToRegisterCells(tableView)
        SliderView.prepareToRegisterCells(tableView)
        CarImageSliderTableCell.prepareToRegisterCells(tableView)
    }
}

// MARK: - Actions
extension CarDetailsVC {
    
    func openFullsScreenDoc(_ cellType: CarDetailsCellype) {
        let vc = KPImagePreview.init(objs: [cellType == .registration ? carData.regImage : carData.insImage], sourceRace: nil, selectedIndex: nil, placeImg: _dummyPlaceImage)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnEditCarTap(_ sender: UIButton) {
        if carData.is_editable {
            let vc = AddCarVC.instantiate(from: .Profile)
            vc.data = AddCarModel(carData)
            vc.isEdit = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            ValidationToast.showStatusMessage(message: "As this car is already in use, it cannot be edited or deleted until the trip is over", yCord: _navigationHeight)
        }
    }
    
    @IBAction func btnDeleteCarTap(_ sender: UIButton) {
        if carData.is_editable {
            showConfirmationPopUpView("Confirmation!", "Are you sure you want to delete this car?", btns: [.cancel, .yes]) { btn in
                if btn == .yes {
                    self.deleteCar()
                }
            }
        } else {
            ValidationToast.showStatusMessage(message: "As this car is already in use, it cannot be edited or deleted until the trip is over", yCord: _navigationHeight)
        }
    }
}

// MARK: - TableView Methods
extension CarDetailsVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carData == nil ? 0 : arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        let contentWidth = _screenSize.width - (40 * _widthRatio)
        if cellType == .images {
            return self.carData.carImage.isEmpty ? 0 : cellType.cellHeight
        } else if cellType == .name {
            return carData.company.heightWithConstrainedWidth(width: contentWidth, font: AppFont.fontWithName(.mediumFont, size: 24 * _fontRatio)) + (8 * _widthRatio)
        } else if cellType == .makeColor {
            return carData.descStr.heightWithConstrainedWidth(width: contentWidth, font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (8 * _widthRatio)
        } else if cellType == .documentTitle {
            return "Car documents".heightWithConstrainedWidth(width: contentWidth, font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (8 * _widthRatio)
        } else if cellType == .registration {
            var height: CGFloat = 88
            if carData.registrationStatus == .rejected && !carData.regRejectStr.isEmpty {
                height += carData.regRejectStr.heightWithConstrainedWidth(width: _screenSize.width - (110 * _widthRatio), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio)) + 32 * _widthRatio
            }
            return height * _widthRatio
        } else if cellType == .insurance {
            var height: CGFloat = 88
            if carData.insuranceStatus == .rejected && !carData.insRejectStr.isEmpty {
                height += carData.insRejectStr.heightWithConstrainedWidth(width: _screenSize.width - (110 * _widthRatio), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio)) + 32 * _widthRatio
            }
            return height * _widthRatio
        }
        return cellType.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrCells[indexPath.row]
        return tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? TitleTVC {
            cell.prepareUI(self.carData.getValue(cellType), cellType.titleFont, clr: AppColor.primaryText)
        }
        else if let cell = cell as? CarDetailCell {
            if cellType == .licenceAndSeats {
                cell.labeOne.text = self.carData.licencePlate
                cell.labeTwo.text = self.carData.availableSeats
            } else if cellType == .registration {
                cell.prepareUI("Registration", AppFont.fontWithName(.mediumFont, size: 14 * _fontRatio), clr: AppColor.primaryText)
                cell.prepareCarDetailStatusUI(self.carData.registrationStatus, true, self.carData.regRejectStr)
            } else if cellType == .insurance {
                cell.prepareUI("Insurance", AppFont.fontWithName(.mediumFont, size: 14 * _fontRatio), clr: AppColor.primaryText)
                cell.prepareCarDetailStatusUI(self.carData.insuranceStatus, true, self.carData.insRejectStr)
            }
            cell.action_viewTap = { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.openFullsScreenDoc(cellType)
            }
        }
        else if let cell = cell as? SliderView {
            if !carData.carImage.isEmpty {
                cell.imgs = self.carData.carImage.compactMap({$0.imgStr})
            }
            cell.selectionCall = { [weak self] (indx) in
                guard let weakSelf = self else { return }
                weakSelf.openCarImages(indx)
            }
        }
        else if let _ = cell as? CarImageSliderTableCell {
//            cell.arrImages = self.carData.carImage
        }
    }
    
    func openCarImages(_ selected: Int?) {
        let vc = KPImagePreview.init(objs: self.carData.carImage.compactMap({$0.imgStr}), sourceRace: nil, selectedIndex: selected, placeImg: _carPlaceImage?.withTintColor(.white))
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

//MARK: - Notification Observers
extension CarDetailsVC {
    
    func addObservers() {
        _defaultCenter.addObserver(self, selector: #selector(carDetailsUpdated(_:)), name: Notification.Name.carDetailsUpdate, object: nil)
    }
    
    @objc func carDetailsUpdated(_ notification: NSNotification){
        getCarDetails()
    }
}


// MARK: - API Call
extension CarDetailsVC {
    
    func getCarDetails() {
        if !refresh.isRefreshing {
            showCentralSpinner()
        }
        self.showCentralSpinner()
        WebCall.call.getCarDetails(carId) { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            self.refresh.endRefreshing()
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
                self.carData = CarDetailModel(data)
                self.btnEdit.isHidden = false
                self.btnDelete.isHidden = false
                self.tableView.reloadData()
            } else {
                self.showError(data: json)
            }
        }
    }
    
    func deleteCar() {
        showCentralSpinner()
        self.showCentralSpinner()
        WebCall.call.deleteCar(carId) { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.showSuccessMsg(data: json)
                self.navigationController?.popViewController(animated: true)
                delay(0.1) {
                    _defaultCenter.post(name: Notification.Name.carListUpdate, object: nil)
                }
            } else {
                self.showError(data: json)
            }
        }
    }
}
