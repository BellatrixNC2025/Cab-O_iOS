//
//  CreateRideVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

// MARK: - StopOverPriceCell
class StopOverPriceCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var lblDest: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var imgRideStart: UIImageView!
    @IBOutlet weak var imgRideDest: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgRideStart?.setViewHeight(height: (DeviceType.iPad ? 22 : 18) * _widthRatio)
        imgRideDest?.setViewHeight(height: (DeviceType.iPad ? 22 : 18) * _widthRatio)
    }
    
    func prepareWaypointPrice(_ wayPoint: RideStopOver) {
        lblStart.text = wayPoint.start?.customAddress
        lblDest.text = wayPoint.dest?.customAddress
        lblPrice.text = "₹\(wayPoint.totalPrice.stringValues)"
    }
    
    func preparePriceDetails(_ start: String,_ dest: String, price: String) {
        lblStart.text = start
        lblDest.text = dest
        lblPrice.text = "₹\(price)"
    }
}

// MARK: - CreateRideCell
class CreateRideCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var buttonEditStopOver: UIButton!
    @IBOutlet weak var buttonDeleteStopOver: UIButton!
    
    /// Variables
    var action_edit_stopover: (() -> ())?
    var action_delete_stopover: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func action_editStopOver(_ sender: UIButton) {
        action_edit_stopover?()
    }
    
    @IBAction func action_deleteStopOver(_ sender: UIButton) {
        action_delete_stopover?()
    }
}

class CreateRideVC: ParentVC {
    
    /// Outlets
    @IBOutlet var vwProgress: [UIView]!
    @IBOutlet weak var btnConinue: UIButton!
    @IBOutlet weak var btnView: UIView!
    
    /// Variables
    var createRideStep: CreateRideSteps! {
        didSet {
            prepareStepWiseCells()
            updateProgressView()
        }
    }
    var arrCells: [CreateRideCellType]!
    var arrCars: [CarListModel]!
    var data = CreateRideData()
    var isEdit: Bool = false
    var isRestrictEdit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        addKeyboardObserver()
    }
}

// MARK: - UI Methods
extension CreateRideVC {
    
    func prepareUI() {
        createRideStep = .step1
        lblTitle?.text = isEdit ? "Edit ride" : "Create a ride"
        btnConinue.setTitle(isRestrictEdit ? "Update" : "Continue", for: .normal)
        tableView.contentInset = UIEdgeInsets(top: (8 * _widthRatio), left: 0, bottom: 50, right: 0)
        registerCells()
    }
    
    private func prepareStepWiseCells() {
        if isRestrictEdit {
            arrCells = [.selectCarTitle, .selectCarInfo, .car, .availSeats, .rideDescTitle, .rideDescInfo, .rideMessage]
        }
        else if createRideStep == .step1 {
            arrCells = [.startDest, .addStopover, .date, .time]
            for _ in data.arrStopOver {
                arrCells.insert(.stopover, at: 1)
            }
        } else if createRideStep == .step2 {
            arrCells = [.selectCarTitle, .selectCarInfo]
            if let arrCars {
                for _ in arrCars {
                    arrCells.append(.car)
                }
            }
        } else if createRideStep == .step3 {
            arrCells = [.availSeats, .ridePrefs, .luggage]
        } else if createRideStep == .step4 {
            arrCells.removeAll(where: {$0 == .paymentDistribution})
            arrCells = [.everyRiderPayTitle, .everyRiderPayInfo]
            self.data.arrRideWayPoints.forEach { _ in
                arrCells.append(.paymentDistribution)
            }
            arrCells.append(.paymentDistribution)
        } else {
            arrCells = [.rideDescTitle, .rideDescInfo, .rideMessage]
        }
        tableView.reloadData()
    }
    
    func registerCells() {
        TitleTVC.prepareToRegisterCells(tableView)
        StartDestPickerCell.prepareToRegisterCells(tableView)
        DatePickerCell.prepareToRegisterCells(tableView)
        CarListCell.prepareToRegisterCells(tableView)
        AvailableSeatsCell.prepareToRegisterCells(tableView)
        InputCell.prepareToRegisterCells(tableView)
        CreateRidePreferenceCell.prepareToRegisterCells(tableView)
        CreateRideLuggageCell.prepareToRegisterCells(tableView)
        ButtonTableCell.prepareToRegisterCells(tableView)
        NoDataCell.prepareToRegisterCells(tableView)
    }
    
    func updateProgressView() {
        vwProgress.forEach { view in
            if isRestrictEdit {
                view.isHidden = true
            } else {
                view.backgroundColor = view.tag < createRideStep.rawValue ? AppColor.themeGreen : AppColor.placeholderText
            }
        }
    }
}

// MARK: - Actions
extension CreateRideVC {
    
    func openLocationPickerFor(_ tag: Int) {
        let vc = SearchVC.instantiate(from: .Home)
        vc.selectionBlock = { [weak self] (address) in
            guard let self = self else { return }
            if tag == 0 {
                if let dest = self.data.dest, dest.formatedAddress == address.formatedAddress {
                    ValidationToast.showStatusMessage(message: "Selected address is already used as destination", yCord: _navigationHeight)
                }
                else if self.data.arrStopOver.contains(where: {$0.formatedAddress == address.formatedAddress}) {
                    ValidationToast.showStatusMessage(message: "Selected address is already used as stopover", yCord: _navigationHeight)
                }
                else {
                    self.data.start = address
                }
            } else {
                if let source = self.data.start, source.formatedAddress == address.formatedAddress {
                    ValidationToast.showStatusMessage(message: "Selected address is already used as source location", yCord: _navigationHeight)
                }
                else if self.data.arrStopOver.contains(where: {$0.formatedAddress == address.formatedAddress}) {
                    ValidationToast.showStatusMessage(message: "Selected address is already used as stopover", yCord: _navigationHeight)
                }
                else {
                    self.data.dest = address
                }
            }
            self.tableView.reloadData()
        }
        self.present(vc, animated: true)
    }
    
    func openLocationPickerForStopOver(_ indx: Int? = nil) {
        if self.data.start == nil {
            ValidationToast.showStatusMessage(message: "Please select a source address first", yCord: _navigationHeight)
        } else if self.data.dest == nil {
            ValidationToast.showStatusMessage(message: "Please select a destination address first", yCord: _navigationHeight)
        } else {
            let vc = SearchVC.instantiate(from: .Home)
            vc.selectionBlock = { [weak self] (address) in
                guard let self = self else { return }
                if let source = self.data.start, source.formatedAddress == address.formatedAddress {
                    ValidationToast.showStatusMessage(message: "Selected address is already used as source location", yCord: _navigationHeight)
                }else if let dest = self.data.dest, dest.formatedAddress == address.formatedAddress {
                    ValidationToast.showStatusMessage(message: "Selected address is already used as destination", yCord: _navigationHeight)
                } else {
                    if self.data.arrStopOver.contains(where: {$0.formatedAddress == address.formatedAddress}) {
                        ValidationToast.showStatusMessage(message: "Already stopover added with selected address", yCord: _navigationHeight)
                    } else {
                        if let indx {
                            self.data.arrStopOver[indx] = address
                        } else {
                            self.data.arrStopOver.append(address)
                            self.arrCells.insert(.stopover, at: 1)
                        }
                    }
                }
                self.tableView.reloadData()
            }
            self.present(vc, animated: true)
        }
    }
    
    func openChangeCarScreen() {
        let vc = CarListVC.instantiate(from: .Profile)
        vc.isChangeCar = true
        vc.rideData = data
        vc.seatBooked = data.seatBooked
        vc.selectedCar = data.selectedCar
        vc.update_callBack = { [weak self] (car) in
            guard let self = self else { return }
            if let car {                    
                self.data.selectedCar = car
                self.data.availableSeats = nil
                self.tableView.reloadData()
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnContinueTap(_ sender: UIButton) {
        
        func continueNavigate() {
            if createRideStep == .step1 || createRideStep == .step2 {
                checkRidePref { [weak self] (isTrue) in
                    guard let self = self else { return }
                    if isTrue {
                        self.navToNextStep()
                    }
                }
            } else {
                self.navToNextStep()
            }
        }
        
        if isRestrictEdit {
            let valid = data.isValidRestrictData()
            if valid.0 {
                self.updateRide()
            } else {
                ValidationToast.showStatusMessage(message: valid.1, yCord: _navigationHeight)
            }
        } else {
            let valid = data.isValidData(createRideStep)
            if valid.0 {
                continueNavigate()
            } else {
                ValidationToast.showStatusMessage(message: valid.1, yCord: _navigationHeight)
            }
        }
    }
    
    fileprivate func navToNextStep() {
        if createRideStep == .step1 {
            createRideStep = .step2
            getMyCars()
        }
        else if createRideStep == .step2 {
            data.availableSeats = nil
            createRideStep = .step3
        }
        else if createRideStep == .step3 {
            getWaypoints()
        }
        else if createRideStep == .step4 {
            createRideStep = .step5
        }
        else if createRideStep == .step5 {
            if isEdit {
                updateRide()
            } else {
                let vc = RideRulesVC.instantiate(from: .Home)
                vc.createData = data
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        if createRideStep == .step5 {
            if isEdit {
                btnConinue.setTitle(isEdit ? "Update" : "Continue", for: .normal)
            }
        } else {
            btnConinue.setTitle("Continue", for: .normal)
        }
    }
    
    @IBAction func btnBackTap(_ sender: UIButton) {
        if createRideStep != .step1 {
            let step = CreateRideSteps(rawValue: createRideStep.rawValue - 1)!
            self.createRideStep = step
            if step != .step4 {
                btnConinue.setTitle("Continue", for: .normal)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - TableView Methods
extension CreateRideVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if EnumHelper.checkCases(cellType, cases: [.selectCarTitle, .selectCarInfo, .everyRiderPayTitle, .everyRiderPayInfo, .rideDescTitle, .rideDescInfo]) {
            let height = cellType.title.heightWithConstrainedWidth(width: _screenSize.width - (40 * _widthRatio), font: cellType.titleFont) + (12 * _heightRatio)
            return height + (EnumHelper.checkCases(cellType, cases: [.selectCarInfo, .everyRiderPayInfo, .rideDescInfo]) ? 12 * _widthRatio : 0)
        }
        else if cellType == .noCar {
            return (_isLandScape ? tableView.frame.width : tableView.frame.height) - (250 * _heightRatio)
        }
        else if cellType == .ridePrefs {
            let data = _arrPrefs
            let columns: CGFloat = DeviceType.iPad ? 3 : 2
            
            if data.isEmpty {
               return 0
            }
            else {
                let rows = Int(ceil(Double(data.count) / columns))
                let height = data.isEmpty ? 0 : (CreateRidePreferenceCell.prefHeight * CGFloat(rows)) + CGFloat((4 * _widthRatio) * CGFloat(rows))
                return height + cellType.cellHeight
            }
        }
        else if cellType == .luggage {
            if _arrLuggage.isEmpty {
                return 0
            } else {
                let height: CGFloat = CGFloat(_arrLuggage.count) * CreateRideLuggageTableCell.cellHeight
                return height + cellType.cellHeight
            }
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
            if isRestrictEdit {
                cell.btnRight.isHidden = cellType != .selectCarTitle
                cell.action_right_btn = { [weak self] (btn) in
                    guard let self = self else { return }
                    self.openChangeCarScreen()
                }
            }
            cell.prepareUI(cellType.title, cellType.titleFont, clr: AppColor.primaryText)
        }
        else if let cell = cell as? StartDestPickerCell {
            cell.delegate = self
            cell.locationPickerTap = { [weak self] (tag) in
                guard let `self` = self else { return }
                self.openLocationPickerFor(tag)
            }
        }
        else if let cell = cell as? CreateRideCell {
            if cellType == .stopover {
                cell.lblSubTitle.text = "Stopover \(indexPath.row)"
                let stop = self.data.arrStopOver[indexPath.row - 1]
                cell.lblTitle.text = stop.name
            }
            cell.action_edit_stopover = { [weak self] in
                guard let self = self else { return }
                self.openLocationPickerForStopOver(indexPath.row - 1)
            }
            cell.action_delete_stopover = { [weak self] in
                guard let self = self else { return }
                self.data.arrStopOver.remove(at: indexPath.row - 1)
                self.arrCells.remove(at: 1)
                self.tableView.reloadData()
            }
            
        }
        else if let cell = cell as? DatePickerCell {
            cell.lblTitle.text = cellType.title
            cell.lblTitle.font = AppFont.fontWithName(.mediumFont, size: 18 * _fontRatio)
            cell.datePicker.datePickerMode = cellType.datePickerMode
            if cellType == .date {
                cell.datePicker.minimumDate = Date()
                cell.datePicker.maximumDate = Date().adding(.day, value: _appDelegator.config.createRideMaxDays)
            } else {
                if data.rideDate.isToday {
                    cell.datePicker.minimumDate = Date().adding(.minute, value: _appDelegator.config.createRideMinTime)
                } else {
                    cell.datePicker.minimumDate = nil
                }
            }
            
            if isEdit {
                if !data.isTimeChanged {
                    cell.datePicker.date = data.utcRideDate
                    if cell.datePicker.timeZone == nil {
                        cell.datePicker.timeZone = TimeZone(identifier: data.start!.timeZoneId) //TimeZone(identifier: "UTC")
                    }
                } else {
                    cell.datePicker.date = cellType == .date ? data.rideDate : data.rideTime
                    if cell.datePicker.timeZone == nil {
                        cell.datePicker.timeZone = TimeZone(identifier: data.start!.timeZoneId) //TimeZone(identifier: "UTC")
                    }
                }
            } else {
                cell.datePicker.date = cellType == .date ? data.rideDate : data.rideTime
                cell.datePicker.timeZone = TimeZone.current
            }
            
            cell.dateChanges = { [weak self] (date) in
                guard let self = self else { return }
                if cellType == .date {
                    self.data.rideDate = date
                    self.tableView.reloadData()
                } else {
                    self.data.isTimeChanged = true
                    self.data.rideTime = date
                }
            }
        }
        else if let cell = cell as? CenterButtonTableCell {
            cell.btn.setAttributedText(texts: ["Add stopovers"], attributes: [[NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]], state: .normal)
            cell.btn.layoutIfNeeded()
            cell.btnTapAction = { [weak self] in
                guard let self = self else { return }
                if cellType == .addStopover {
                    self.openLocationPickerForStopOver()
                }
            }
            cell.btnInfoTapAction = { [weak self] (btn) in
                guard let self = self else { return }
                self.openPopOver(view: btn, msg: "Let us know where you’re willing to stop for more passengers.")
            }
        }
        else if let cell = cell as? CarListCell {
            if isRestrictEdit {
                cell.prepareUI(data.selectedCar!, false)
            }
            else if let selCar = data.selectedCar {
                let car = arrCars[indexPath.row - 2]
                cell.prepareUI(car, car.id == selCar.id )
            } else {
                if !arrCars.isEmpty {
                    cell.prepareUI(arrCars[indexPath.row - 2], false)
                }
            }
        }
        else if let cell = cell as? NoDataCell {
            cell.prepareUI(img: _carPlaceImage!, title: "No cars to select from.", subTitle: "You don't have any verified cars to select from.")
        }
        else if let cell = cell as? AvailableSeatsCell {
            cell.minAllow = data.bookedSeats
            cell.selectedSeat = data.availableSeats
            cell.prepareUI("Available seats", "Add seats available count, without considering a driver seat.", self.data.availableSeats, data.selectedCar!.availableSeats.integerValue)
            cell.seatSelectionCallBack = { [weak self] (seat) in
                guard let self = self else { return }
                self.data.availableSeats = seat
            }
        }
        else if let cell = cell as? CreateRidePreferenceCell {
            cell.arrPrefs = _arrPrefs
            cell.prepareUI(selectedPref: data.arrPrefs.compactMap({$0.id}))
            cell.selectionCallBack = { [weak self] (pref) in
                guard let self = self else { return }
                if self.data.arrPrefs.contains(pref) {
                    self.data.arrPrefs.remove(pref)
                } else {
                    self.data.arrPrefs.append(pref)
                }
            }
        }
        else if let cell = cell as? CreateRideLuggageCell {
            cell.arrLuggage = data.arrLuggage
        }
        else if let cell = cell as? InputCell {
            cell.tag = indexPath.row
            cell.delegate = self
        }
        else if let cell = cell as? StopOverPriceCell {
            if indexPath.row - 2 == 0 {
                cell.prepareWaypointPrice(self.data.rideWayPoint!)
            } else {
                cell.prepareWaypointPrice(self.data.arrRideWayPoints[indexPath.row - 3])
            }
        }
        else if let cell = cell as? ButtonTableCell {
            cell.btn.setTitle("Continue", for: .normal)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if createRideStep == .step2 {
            if cellType == .car {
                let car = arrCars[indexPath.row - 2]
                if car.carStatus == .verified {
                    if data.selectedCar != arrCars[indexPath.row - 2] {
                        data.selectedCar = arrCars[indexPath.row - 2]
                        self.tableView.reloadData()
                    }
                } else {
                    ValidationToast.showStatusMessage(message: car.carStatusString, yCord: _navigationHeight)
                }
            }
        }
    }
}

// MARK: - UIKeyboard Observer
extension CreateRideVC {
    
    func addKeyboardObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        if let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height + (12 * _widthRatio), right: 0)
        }
        if let fIndex = arrCells.firstIndex(of: .rideMessage), let cell = tableViewCell(index: fIndex) as? InputCell, cell.txtView.isFirstResponder {
            scrollToIndex(index: fIndex, animate: true, .top)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification){
        guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        tableView.contentInset = UIEdgeInsets(top: (8 * _widthRatio), left: 0, bottom: 50, right: 0)
    }
}

// MARK: - API Calls
extension CreateRideVC {
    
    /// Get Car List
    func getMyCars() {
        showCentralSpinner()
        WebCall.call.getMyCarList(param: ["status": DocStatus.verified.apiValue]) { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            self.arrCells.removeAll(where: {$0 == .car})
            self.arrCars = []
            self.arrCells.remove(.noCar)
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? [NSDictionary] {
                for car in data {
                    self.arrCars.append(CarListModel(car))
                    self.arrCells.append(.car)
                }
                if self.arrCars.isEmpty {
                    self.arrCells.append(.noCar)
                }
                if !self.isEdit && self.arrCars.count == 1 && self.data.selectedCar == nil, let car = arrCars.first, car.carStatus == .verified {
                    self.data.selectedCar = arrCars.first!
                }
                self.tableView.reloadData()
            } else {
                self.showError(data: json)
            }
        }
    }
    
    /// Check Ride Date and Car Expiry
    /// - Parameter completion: Completions
    func checkRidePref(_ completion: @escaping ((Bool) -> ())) {
        var param: [ String: Any ] = [:]
        if createRideStep == .step1 {
            param["from_date"] = Date.serverDateString(from: data.rideDate)
        } else if createRideStep == .step2 {
            param["car_id"] = data.selectedCar!.id
            param["from_date"] = Date.serverDateString(from: data.rideDate)
            param["timezone"] = self.data.start?.timeZoneId
        }
        
        showSpinnerIn(container: self.btnView, control: self.btnConinue, isCenter: true)
        WebCall.call.checkRidePrefs(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideSpinnerIn(container: self.btnView, control: self.btnConinue)
            if status == 200 {
                completion(true)
            } else {
                completion(false)
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    /// Get Ride Waypoints
    func getWaypoints() {
        
        showCentralSpinner()
        KPAPICalls.shared.getWayPoints(origin: data.start!.formatedAddress,
                                        dest: data.dest!.formatedAddress,
                                        stopOvers: data.arrStopOver.compactMap({$0.formatedAddress})) { [ weak self] (items, errorDescription) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if let items {
                nprint(items: items.geocodedWaypoints.count)
                self.createStopOverSequence(items: items)
            }
        }
    }
    
    /// Create Sequence of Stopover
    /// - Parameter items: Waypoint Response
    func createStopOverSequence(items : WayPoints){
        var arryForPlce:[SearchAddress] = []
        if items.routes.count > 0 {
            if let routes = items.routes.first {
                if let way_Order = routes.waypointOrder {
                    for orderIndex in way_Order {
                        arryForPlce.append(self.data.arrStopOver[orderIndex])
                    }
                }
            }
        }
        
        var arrayPoints : [RideStopOver] = []
        var stopOrderNumber = 1
        if arryForPlce.count > 0 {
            var miles : Double = 0.0
            var duration : Double = 0.0
            
            for index in 0...arryForPlce.count {
                if index == 0 {
                    let stopOverPoint: RideStopOver = RideStopOver()
                    stopOverPoint.start = self.data.start
                    
                    stopOverPoint.fDate = self.data.rideDateTime
                    stopOverPoint.fUtcDate = self.data.utcRideDate
                    
                    stopOverPoint.dest = arryForPlce[index]
                    stopOverPoint.stopOverOrder = stopOrderNumber
                    stopOrderNumber += 1
                    
                    if items.routes.count > 0 {
                        if let routes = items.routes.first {
                            if let legs = routes.legs {
                                if let objLegs = legs.first {
                                    if let objDuration = objLegs.duration {
                                        duration = duration + objDuration.value
                                        
                                        stopOverPoint.tDate = stopOverPoint.fDate.adding(.second, value: objDuration.value.intValue!)
                                        stopOverPoint.tUtcDate = stopOverPoint.fUtcDate.adding(.second, value: objDuration.value.intValue!)
                                        
                                        stopOverPoint.duration = Int(objDuration.value)
                                        
                                        let (hour,min,_) = secondsToETA(Int(objDuration.value))
                                        stopOverPoint.eta = "\(hour) hour \(min) mins"
                                    }
                                    if let objDistance = objLegs.distance {
                                        miles = miles + objDistance.value
                                        stopOverPoint.miles = (objDistance.value / 1609.344).rounded(toPlaces: 2)
                                    }
                                }
                            }
                        }
                    }
                    arrayPoints.append(stopOverPoint)
                    
                }
                else if index == arryForPlce.count {
                    let stopOverPoint: RideStopOver = RideStopOver()
                    stopOverPoint.start = arryForPlce[index - 1]
                    
                    stopOverPoint.fDate = arrayPoints[index - 1].tDate
                    stopOverPoint.fUtcDate = arrayPoints[index - 1].tUtcDate
                    
                    stopOverPoint.dest = self.data.dest
                    stopOverPoint.stopOverOrder = stopOrderNumber
                    stopOrderNumber += 1
                    
                    if items.routes.count > 0 {
                        if let routes = items.routes.first {
                            if let legs = routes.legs {
                                if let objLegs = legs.last {
                                    if let objDuration = objLegs.duration {
                                        duration = duration + objDuration.value
                                        
                                        stopOverPoint.tDate = stopOverPoint.fDate.adding(.second, value: objDuration.value.intValue!)
                                        stopOverPoint.tUtcDate = stopOverPoint.fUtcDate.adding(.second, value: objDuration.value.intValue!)
                                        stopOverPoint.duration = Int(objDuration.value)
                                        
                                        let (hour,min,_) = secondsToETA(Int(objDuration.value))
                                        stopOverPoint.eta = "\(hour) hour \(min) mins"
                                    }
                                    if let objDistance = objLegs.distance {
                                        miles = miles + objDistance.value
                                        stopOverPoint.miles = (objDistance.value / 1609.344).rounded(toPlaces: 2)
                                    }
                                }
                            }
                        }
                    }
                    arrayPoints.append(stopOverPoint)
                    
                } else {
                    let stopOverPoint: RideStopOver = RideStopOver()
                    stopOverPoint.start = arrayPoints[index - 1].dest
                    
                    stopOverPoint.fDate = arrayPoints[index - 1].tDate
                    stopOverPoint.fUtcDate = arrayPoints[index - 1].tUtcDate
                    
                    stopOverPoint.dest = arryForPlce[index]
                    stopOverPoint.stopOverOrder = stopOrderNumber
                    stopOrderNumber += 1
                    
                    if items.routes.count > 0 {
                        if let routes = items.routes.first {
                            if let legs = routes.legs {
                                let objLegs = legs[index]
                                if let objDuration = objLegs.duration {
                                    duration = duration + objDuration.value
                                    
                                    stopOverPoint.tDate = stopOverPoint.fDate.adding(.second, value: objDuration.value.intValue!)
                                    stopOverPoint.tUtcDate = stopOverPoint.fUtcDate.adding(.second, value: objDuration.value.intValue!)
                                    stopOverPoint.duration = Int(objDuration.value)
                                    
                                    let (hour,min,_) = secondsToETA(Int(objDuration.value))
                                    stopOverPoint.eta = "\(hour) hour \(min) mins"
                                }
                                if let objDistance = objLegs.distance {
                                    miles = miles + objDistance.value
                                    stopOverPoint.miles = (objDistance.value / 1609.344).rounded(toPlaces: 2)
                                }
                            }
                        }
                    }
                    arrayPoints.append(stopOverPoint)
                }
            }
            
            
            let rideInfo: RideStopOver = RideStopOver()
            rideInfo.start = self.data.start
            
            rideInfo.fDate = self.data.rideDateTime
            rideInfo.fUtcDate = self.data.utcRideDate
            
            rideInfo.dest = self.data.dest
            rideInfo.stopOverOrder = -1
            self.data.miles = (miles / 1609.344).rounded(toPlaces: 2)
            rideInfo.miles = self.data.miles
            
            rideInfo.tDate = rideInfo.fDate.adding(.second, value: duration.intValue!)
            rideInfo.tUtcDate = rideInfo.fUtcDate.adding(.second, value: duration.intValue!)
            
            rideInfo.duration = Int(duration)
            self.data.duration = Int(duration)
            
            let (hour,min,_) = secondsToETA(Int(duration))
            self.data.eta = "\(hour) hour \(min) mins"
            rideInfo.eta = self.data.eta
            self.data.rideWayPoint = rideInfo
            
        }
        else{
            let rideInfo: RideStopOver = RideStopOver()
            rideInfo.start = self.data.start
            rideInfo.fDate = self.data.rideDateTime
            rideInfo.fUtcDate = self.data.utcRideDate
            
            rideInfo.dest = self.data.dest
            rideInfo.stopOverOrder = -1
            self.data.rideWayPoint = rideInfo
            
            if items.routes.count > 0 {
                if let routes = items.routes.first {
                    if let legs = routes.legs {
                        if let objLegs = legs.first {
                            if let objDuration = objLegs.duration {
                                let (hour,min,_) = secondsToETA(Int(objDuration.value))
                                self.data.duration = objDuration.value.intValue!
                                
                                rideInfo.tDate = rideInfo.fDate.adding(.second, value: objDuration.value.intValue!)
                                rideInfo.tUtcDate = rideInfo.fUtcDate.adding(.second, value: objDuration.value.intValue!)
                                rideInfo.duration = Int(objDuration.value)
                                
                                self.data.eta = "\(hour) hour \(min) mins"
                                rideInfo.eta = self.data.eta
                            }
                            if let objDistance = objLegs.distance {
                                self.data.miles = (objDistance.value / 1609.344).rounded(toPlaces: 2)
                                rideInfo.miles = self.data.miles
                            }
                        }
                    }
                }
            }
            self.data.rideWayPoint = rideInfo
        }
        self.data.arrRideWayPoints.removeAll()
        self.data.arrRideWayPoints = arrayPoints
        nprint(items: arrayPoints)
        self.getMilesPrice()
    }
    
    /// Get Price based on Miles
    func getMilesPrice() {
        var param: [String:Any] = [:]
        var arrPoints = self.data.arrRideWayPoints.compactMap({$0.requestPriceParam})
        arrPoints.append(self.data.rideWayPoint!.requestPriceParam)
        param["miles_array"] = arrPoints
        showCentralSpinner()
        WebCall.call.getMilesPrice(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? [NSDictionary] {
                var updatedPriceList: [UpdatePriceModel] = []
                data.forEach { price in
                    updatedPriceList.append(UpdatePriceModel(price))
                }
                self.updateRideFare(updatedPriceList)
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    /// Update New Ride
    fileprivate func updateRideFare(_ priceList: [UpdatePriceModel]) {
        let ridePrice = priceList.first(where: {$0.order == -1})!
        self.data.totalPrice = ridePrice.total_price.rounded(toPlaces: 2)
        self.data.rideWayPoint?.totalPrice = self.data.totalPrice
        
        self.data.arrRideWayPoints.forEach { wayPoint in
            let updatedPrice = priceList.first(where: {$0.order == wayPoint.stopOverOrder})!
            wayPoint.totalPrice = updatedPrice.total_price.rounded(toPlaces: 2)
        }
        self.createRideStep = .step4
    }
    
    /// Edit Ride API
    func updateRide() {
        let param = isRestrictEdit ? data.updateRideParam : data.createRideParam
        showCentralSpinner()
        WebCall.call.createRide(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.showSuccessMsg(data: json, yCord: _navigationHeight)
                _defaultCenter.post(name: Notification.Name.rideDetailsUpdate, object: nil)
                _defaultCenter.post(name: Notification.Name.rideListUpdate, object: nil)
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
}
