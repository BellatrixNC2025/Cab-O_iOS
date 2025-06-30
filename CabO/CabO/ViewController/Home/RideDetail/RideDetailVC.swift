//
//  RideDetailVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import Lottie

// MARK: - RideDetail ScreenType
enum RideDetailScreenType {
    case created, find
    case book, review, detail
}

fileprivate enum UpdateRideStatus: String {
    case start_ride = "start_ride"
    case complete_ride = "complete_ride"
    case cancel_ride = "cancel_ride"
}

// MARK: - RideOptios Button
enum RideOptiosButton {
    case editRide, shareRide, trackRide, ridePrice, support, cancelRide
    case transactions
    
    var title: String {
        switch self {
        case .editRide: return "Edit ride"
        case .shareRide: return "Share ride"
        case .trackRide: return "Track ride"
        case .ridePrice: return "Ride price details"
        case .support: return "Support center"
        case .cancelRide: return "Cancel ride"
        case .transactions: return "Transaction details"
        }
    }
    
    var image: UIImage! {
        switch self {
        case .editRide: return UIImage(named: "ic_edit")!
        case .shareRide: return UIImage(named: "ic_share")!
        case .trackRide: return UIImage(named: "ic_clock")!
        case .ridePrice: return UIImage(named: "ic_dollar")!
        case .support: return UIImage(named: "ic_support_center")!
        case .cancelRide: return UIImage(named: "ic_close")!
        case .transactions: return UIImage(named: "ic_dollar")!
        }
    }
}

// MARK: - RideDetailVC
class RideDetailVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var viewRequestBook: UIView!
    @IBOutlet weak var btnRequestBook: RoundGradientButton!
    @IBOutlet weak var viewContinue: UIView!
    @IBOutlet weak var viewRideStatusButton: UIView!
    @IBOutlet weak var btnStartRide: RoundGradientButton!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnOptions: UIButton!
    @IBOutlet weak var btnSos: UIView!
    @IBOutlet weak var vwSosAnimation: LottieAnimationView!
    
    /// Variables
    var arrCells: [RideDetailCellType]!
    var screenType: RideDetailScreenType! = .book
    var isPastData: Bool = false
    var isReviewScreen: Bool = false
    var rideId: Int!
    var findRide: FindRideListModel!
    var data: RideDetails!
    var tipSelect: Int! = 0
    var tipAmount: String = "5"
    
    var remove_fromList_callback: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        addKeyboardObserver()
        
        if screenType == .review {
            updateUI()
        } else {
            getRideDetails()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAnimation(named: .sos)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimation()
    }
    
    func getRideDetails() {
        if screenType == .created {
            getMyRideDetails()
        } else if screenType == .find {
            getFindRideDetails()
        } else if screenType == .book {
            getBookedRideDetails()
        }
    }
}

// MARK: - UI Methods
extension RideDetailVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 18, left: 0, bottom: 50, right: 0)
        
        lblTitle?.text = screenType == .review ? "Review ride details" : "Ride details"
        btnOptions.isHidden = true
        viewRequestBook?.setViewHeight(height: (DeviceType.iPad ? 84 : 60) * _widthRatio)
        viewRequestBook.isHidden = true
        viewContinue.isHidden = true
        viewRideStatusButton.isHidden = true
        btnSos.isHidden = true
        
        prepareTableCells()
        addObservers()
        addRefresh()
        registerCells()
        
        self.view.layoutIfNeeded()
    }
    
    func addRefresh() {
        refresh.addTarget(self, action: #selector(self.refreshing(_:)), for: .valueChanged)
        self.tableView.refreshControl = refresh
    }
    
    @objc private func refreshing(_ sender: UIRefreshControl) {
        if screenType == .review {
            refresh.endRefreshing()
        } else {
            getRideDetails()
        }
    }
    
    func prepareTableCells() {
        if screenType == .created {
            arrCells = [.detail, .seatBookedCount, .seatListCell, .bookReqCount, .title, .carInfo, .pref, .driverMessage]
            if data != nil && data.status != .pending {
                arrCells.remove(.bookReqCount)
            }
        }
        else if screenType == .find {
            arrCells = [.detail, .seatBookedCount, .seatListCell, .title, .carInfo, .pref, .title, .driverInfo, .driverMessage]
        }
        else if screenType == .review {
            arrCells = [.detail, .title, .driverInfo, .driverMessage]
        } else { //Booked
            arrCells = [.detail, .seatBookedCount, .seatListCell, .title, .carInfo, .pref, .title, .driverInfo, .driverMessage]
        }
        
        tableView.reloadData()
    }
    
    func updateUI() {
        if screenType == .find {
            lblPrice.text = "₹\(data.price!)"
            viewRequestBook.isHidden = false
            viewContinue.isHidden = true
            btnSos.isHidden = true
        } else if screenType == .review {
            viewRequestBook.isHidden = true
            viewContinue.isHidden = false
            btnSos.isHidden = true
        } else if screenType == .created {
            if data.status == .pending && data.showStartButton {
                viewRideStatusButton.isHidden = false
                btnStartRide.setTitle("Start ride", for: .normal)
            } else if data.status == .started {
                viewRideStatusButton.isHidden = false
                btnStartRide.setTitle("End ride", for: .normal)
            } else {
                viewRideStatusButton.isHidden = true
            }
            if data.status == .completed {
                arrCells.remove(.bookReqCount)
            }
            btnSos.isHidden = data.status != .started
        }
        else { //Booked
            btnSos.isHidden = data.status != .started
            viewRequestBook.isHidden = true
            viewContinue.isHidden = true
            viewRideStatusButton.isHidden = true
            
            if data.status == .completed && !data.isTipGiven {
                if !arrCells.contains(.tip) {
                    arrCells.append(.tip)
                }
            } else {
                arrCells.remove(.tip)
            }
            if data.status == .completed && !data.isReviewGiven {
                viewRideStatusButton.isHidden = false
                btnStartRide.setTitle("Rate your driver", for: .normal)
            }
            else if data.review != nil {
                if !arrCells.contains(.review) {
                    arrCells.append(.review)
                }
            } else {
                arrCells.remove(.review)
            }
        }
        if data.arrPrefs.isEmpty && data.arrLuggage.isEmpty {
            arrCells.remove(.pref)
        }
        tableView.reloadData()
        btnOptions.isHidden = screenType == .find || screenType == .review
        prepareOptionsMenu()
    }
    
    func prepareOptionsMenu() {
        var menuElements: [UIAction] = []
        var buttons: [RideOptiosButton] = []
        if isPastData {
            if data.status == .rejected {
                buttons = []
                self.btnOptions.isHidden = true
            } else {
                if screenType == .created && (data.status == .cancelled || data.status == .autoCancelled) && data.bookingList.isEmpty {
                    buttons = []
                    self.btnOptions.isHidden = true
                }
                else if screenType == .book && (data.status == .cancelled || data.status == .autoCancelled || data.status == .rejected) && !data.transation.isRefund && data.transation.txtId.isEmpty {
                    buttons = []
                    self.btnOptions.isHidden = true
                }
                else {
                    buttons = [.transactions]
                }
            }
        } else {
            if screenType == .created {
                switch data.status {
                case .completed:
                    buttons = [.ridePrice]
                case .cancelled, .autoCancelled:
                    buttons = [.transactions]
                case .started:
                    buttons = [.trackRide, .ridePrice]
                default:
                    buttons = [.editRide, .shareRide, .ridePrice, .cancelRide]
                }
            } 
            else if screenType == .book {
                switch data.status {
                case .cancelled, .autoCancelled, .completed:
                    buttons = [.transactions, .support]
                case .rejected:
                    buttons = []
                    self.btnOptions.isHidden = true
                case .ontheway:
                    buttons = [.trackRide, .transactions, .support, .cancelRide]
                case .started:
                    buttons = [.trackRide, .transactions]
                case .pending:
                    buttons = [.cancelRide]
                case .accepted :
                    buttons = [.transactions, .cancelRide]
                default:
                    buttons = [.transactions, .support, .cancelRide]
                }
            }
            else {
                buttons = [.trackRide, .transactions, .support, .cancelRide]
            }
        }
        buttons.forEach { btn in
            menuElements.append(UIAction(title: btn.title, image: btn.image.withTintColor(.black | .white), identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: { [weak self] action in
                guard let `self` = self else { return }
                self.action_rideOptions(btn)
            }))
        }
        btnOptions.menu = UIMenu(title: "", children: menuElements)
    }
    
    func registerCells() {
        RideDetailBookingListTVC.prepareToRegister(tableView)
        RideTipTVC.prepareToRegister(tableView)
        TitleTVC.prepareToRegisterCells(tableView)
        AvailableSeatsCell.prepareToRegisterCells(tableView)
        RideReviewTVC.prepareToRegister(tableView)
    }
    
    func loadAnimation(named ani: LottieAnimationName) {
        stopAnimation()
        let animation = LottieAnimation.named(ani.rawValue, bundle: Bundle.main)
        vwSosAnimation?.contentMode = .scaleAspectFill
        vwSosAnimation?.animation = animation
        vwSosAnimation?.play()
        vwSosAnimation?.loopMode = .loop
    }
    
    func stopAnimation() {
        vwSosAnimation?.stop()
        vwSosAnimation?.animation = nil
    }
    
//    func getTripInfoCellHeight() -> CGFloat {
//        var height: CGFloat = 0
//        let ratio = _widthRatio
//        let addressMinHeight: CGFloat = (DeviceType.iPad ? 36 : 30) * ratio
//        height += data.dateTimeStr.heightWithConstrainedWidth(width: _screenSize.width - (64 * _widthRatio), font: AppFont.fontWithName(.mediumFont, size: 14 * _fontRatio)) + (24 * ratio)
//        
//        let from = data.start!.name.heightWithConstrainedWidth(width: _screenSize.width - (86 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (16 * ratio)
//        let to = data.dest!.name.heightWithConstrainedWidth(width: _screenSize.width - (86 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (12 * ratio)
//        
//        height += from > addressMinHeight ? from : addressMinHeight
//        height += to > addressMinHeight ? to : addressMinHeight
//        
//        let durationWidth: CGFloat = data.getDurationString(screenType).WidthWithNoConstrainedHeight(font: AppFont.fontWithName(.regular, size: 12 * _fontRatio)) + 24 * _widthRatio
//        
//        height += "Average duration".heightWithConstrainedWidth(width: _screenSize.width - ((durationWidth + 74) * _widthRatio), font: AppFont.fontWithName(.mediumFont, size: 14 * _fontRatio)) + (32 * ratio)
//        height += 18 * _widthRatio
//        
//        height -= data.isStopover! ? 0 : (36 * _widthRatio)
//        return height + 28 * ratio
//    }
    
    func getBookingListCellHeight() -> CGFloat {
        var height: CGFloat = 64 * _widthRatio
        
        let status = data.status
        
        if screenType == .find || screenType == .review {
            height = 110 * _widthRatio
        }
        
        if ((status == .pending || status == .cancelled || status == .autoCancelled) && screenType == .book) || status == .rejected {
            height += 0
        } else {
            height += data.bookingList.isEmpty ? 0 : (DeviceType.iPad ? 98 : 90) * _widthRatio
        }

        if (status == .cancelled && screenType == .created) {
            if !data.cancelRideMessage.isEmpty {
                height += data.cancelRideMessage.heightWithConstrainedWidth(width: _screenSize.width - 66 * _widthRatio, font: AppFont.fontWithName(.regular, size: 13 * _fontRatio)) + 24 * _widthRatio
            }
            if !data.canceRideReason.isEmpty {
                height += data.canceRideReason.heightWithConstrainedWidth(width: _screenSize.width - 66 * _widthRatio, font: AppFont.fontWithName(.regular, size: 13 * _fontRatio)) + 24 * _widthRatio
            }
            height += (data.cancelRideMessage.isEmpty && data.canceRideReason.isEmpty) ? 0 : 24 * _heightRatio
        } else if screenType == .book && status == .ontheway {
            let code = data.verificationCode!
            height += code.isEmpty ? 0 : 84 * _widthRatio
        } else {
            if !data.cancelReasonDesc.isEmpty {
                height += data.cancelReasonDesc.heightWithConstrainedWidth(width: _screenSize.width - 66 * _widthRatio, font: AppFont.fontWithName(.regular, size: 13 * _fontRatio)) + 24 * _widthRatio
            }
            if !data.cancelReason.isEmpty {
                height += data.cancelReason.heightWithConstrainedWidth(width: _screenSize.width - 66 * _widthRatio, font: AppFont.fontWithName(.regular, size: 13 * _fontRatio)) + 24 * _widthRatio
            }
            height += (data.cancelReason.isEmpty && data.cancelReasonDesc.isEmpty) ? 0 : 24 * _widthRatio
        }
        
        return height
    }
}

// MARK: - Actions
extension RideDetailVC {
    
    @IBAction func btnBackTap(_ sender: UIButton) {
        if let data {
            if !isPastData && (screenType == .created || screenType == .book) && EnumHelper.checkCases(data.status, cases: [.cancelled, .autoCancelled, .completed, .rejected]) {
                remove_fromList_callback?()
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func openStopoverList() {
        let vc = StopoverListVC.instantiate(from: .Home)
        vc.rideId = self.data.id
        vc.fromTimeZoneId = self.data.start?.timeZoneId
        vc.fromTimeZoneName = self.data.start?.timeZoneName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func action_request_book(_ sender: UIButton) {
        if data.seatLeft == 0 {
            ValidationToast.showStatusMessage(message: "Ride is alredy full", yCord: _navigationHeight)
        } else {
            let vc = RideDetailVC.instantiate(from: .Home)
            vc.screenType = .review
            vc.data = self.data
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func action_review_continue(_ sender: UIButton) {
        let vc = RequestBookRideVC.instantiate(from: .Home)
        vc.data.rideDetails = self.data
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_start_ride(_ sender: UIButton) {
        if screenType == .book {
            if data.status == .completed && !data.isReviewGiven {
                let vc = RateAndReviewVC.instantiate(from: .Home)
                let data = RatingModel()
                data.toBookingId = self.data.book_ride_id
                data.toUserId = self.data.driver?.id
                data.toUserImage = self.data.driver?.img
                data.toUserName = self.data.driver?.fullName
                
                vc.rideId = self.data.id
                vc.data = data
                vc.isForDriver = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if data.status == .pending {
                showConfirmationPopUpView("Confirmation!", "Are you sure you want to start this ride?", btns: [.cancel, .yes]) { btn in
                    if btn == .yes {
                        self.updateRideStatus(.start_ride)
                    }
                }
            } else if data.status == .started {
                showConfirmationPopUpView("Confirmation!", "Are you sure you want to end this ride?", btns: [.cancel, .yes]) { btn in
                    if btn == .yes {
                        self.updateRideStatus(.complete_ride)
                    }
                }
            }
        }
    }
    
    @IBAction func btn_sos_tap(_ sender: UIButton) {
        UserLocation.sharedInstance.fetchUserLocationForOnce(controller: self, forSos: true) { [weak self] (location, error) in
            guard let self = self else { return }
            if let _ = location{
                let vc = SosVC.instantiate(from: .Home)
                vc.carDetails = self.data.car
                vc.rideId = self.data.id
                vc.bookingId = self.data.book_ride_id
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func openRideTracking() {
        let vc = RideTrackerVC.instantiate(from: .Home)
        vc.isDriver = screenType == .created
        vc.rideDetails = data
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func action_rideOptions(_ actions: RideOptiosButton) {
        switch actions {
        case .editRide:
            let vc = CreateRideVC.instantiate(from: .Home)
            vc.isEdit = true
            if data.bookingReq > 0 || data.seatBooked > 0 {
                vc.isRestrictEdit = true
            }
            vc.data = CreateRideData(ride: data)
            self.navigationController?.pushViewController(vc, animated: true)
        case .shareRide:
            self.shareRide()
            
        case .trackRide:
            self.openRideTracking()
            
        case .ridePrice:
            let vc = RidePriceDetailVC.instantiate(from: .Home)
            vc.data = data
            vc.arrStops = data.arrStopOvers
            self.navigationController?.pushViewController(vc, animated: true)
        case .transactions:
            let vc = PaymentDetailVC.instantiate(from: .Home)
            vc.data = data.transation
            vc.tripCode = data.tripCode
            vc.rideId = data.id
            var payScreenType: PaymentDetailScreenType!
            if screenType == .created && data.status == .completed {
                payScreenType = .myrideComplete
            }
            else if screenType == .created && (data.status == .cancelled || data.status == .autoCancelled) {
                payScreenType = .myrideCancel
            }
            else if screenType == .book && (data.status == .cancelled || data.status == .autoCancelled) {
                payScreenType = .bookingCancel
            }
            else if screenType == .book && (data.status == .rejected || data.status == .autoCancelled) {
                payScreenType = .bookingReject
            }
            else {
                payScreenType = .bookingComplete
            }
            vc.screenType = payScreenType
            if EnumHelper.checkCases(payScreenType, cases: [.bookingComplete, .bookingCancel, .bookingReject]) {
                vc.arrPayments = [RideUserPaymentDetails(name: data.driver!.fullName, img: data.driver!.img, price: data.transation.finalPrice, tip: data.transation.tipAmount, seat: data.transation.seatBooked)]
                vc.totalPrice = data.transation.finalPrice
            }
            self.navigationController?.pushViewController(vc, animated: true)
        case .support:
            let vc = AddSupportTicketVC.instantiate(from: .Profile)
            vc.isFromRideDetail = true
            vc.data.rideDetails = self.data
            vc.data.type = 2
            vc.data.toUserId = self.data.driver!.id
            self.navigationController?.pushViewController(vc, animated: true)
        case .cancelRide:
            let vc = CancellationVC.instantiate(from: .Home)
            vc.screenType = screenType == .created ? .cancelRide : .cancelBooking
            vc.rideId = data.id
            vc.bookingId = data.book_ride_id
            self.navigationController?.pushViewController(vc, animated: true)
//        default: break
        }
    }
    
    func openRiderList(_ type: BookingRequestListScreenType) {
        let vc = BookingRequestListVC.instantiate(from: .Home)
        vc.screenType = type
        vc.rideDetails = self.data
        vc.rideId = data.id
        if type == .booked && screenType == .book {
            vc.driverDetails = data.driver
            if data.status == .completed {
                vc.isDriverReviewGiven = data.isReviewGiven
            }
        }
        vc.isRider = screenType == .book
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openRiderBookingDetail(_ index: Int) {
        if screenType == .created {
            let vc = BookingRequestDetailVC.instantiate(from: .Home)
            vc.screenType = .booked
            vc.isRider = false
            vc.rideDetails = self.data
            vc.rideId = self.rideId
            vc.bookRideId = data.bookingList[index].book_ride_id
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UserDetailVC.instantiate(from: .Home)
            vc.userId = data.bookingList[index].id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func openCarImages(_ selected: Int?) {
        let vc = KPImagePreview.init(objs: self.data.car!.carImage.compactMap({$0.imgStr}), sourceRace: nil, selectedIndex: selected, placeImg: _carPlaceImage?.withTintColor(.white))
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func payDriverTip() {
        if tipSelect == 2 && tipAmount.isEmpty {
            ValidationToast.showStatusMessage(message: "Please enter tip amount.", yCord: _navigationHeight)
        } else if tipSelect == 2 && tipAmount.integerValue! > data.price.intValue! {
            ValidationToast.showStatusMessage(message: "Tip amount should be less then ride fare.", yCord: _navigationHeight)
        }else {
            let vc = CardListVC.instantiate(from: .Profile)
            vc.bookRideId = data.book_ride_id
            vc.tipAmount = tipAmount
            vc.screenType = .tip
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func msgDriverTap() {
        self.openChat(ChatHistory(data.driver!))
    }
    
    func shareRide() {
        self.getShareContent()
    }
}

// MARK: - TableView Methods
extension RideDetailVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data == nil ? 0 : arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if cellType == .detail {
            return UITableView.automaticDimension
//            return getTripInfoCellHeight()
        }
        else if cellType == .seatListCell {
            return UITableView.automaticDimension
//            return getBookingListCellHeight()
        }
        else if cellType == .pref {
            if data.arrPrefs.isEmpty && data.arrLuggage.isEmpty {
                return 0
            } else {
                let pref = data.arrPrefs.count
                let lug = data.arrLuggage.count
                let prefHeight: CGFloat = ((CGFloat(pref) * (40 * _widthRatio)) + 10 * _widthRatio)
                let prefTitleHeight = "Prefrences".heightWithConstrainedWidth(width: _screenSize.width - (40 * _widthRatio), font: AppFont.fontWithName(.mediumFont, size: 14 * _fontRatio)) + 12 * _widthRatio
                
                let lugHeight = lug != 0 ? (data.rideLuggageStr.heightWithConstrainedWidth(width: _screenSize.width - (110 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + ("Luggage".heightWithConstrainedWidth(width: _screenSize.width - (110 * _widthRatio), font: AppFont.fontWithName(.mediumFont, size: 14 * _fontRatio)) + 8 * _widthRatio) + 8 * _widthRatio) : 12 * _widthRatio
                return prefHeight + prefTitleHeight + lugHeight + (4 * _widthRatio)
            }
        }
        else if cellType == .driverMessage {
            if data.desc.isEmpty {
                return 0
            } else {
                return UITableView.automaticDimension
                return data.desc.heightWithConstrainedWidth(width: _screenSize.width - (64 * _widthRatio), font: AppFont.fontWithName(.regular, size: 13 * _fontRatio)) + 74 * _widthRatio
            }
        }
        else if cellType == .review {
            if data.review!.review.isEmpty {
                return (64 + 36) * _widthRatio
            } else {
                return data.review!.review.heightWithConstrainedWidth(width: _screenSize.width - (64 * _widthRatio), font: AppFont.fontWithName(.regular, size: 13 * _fontRatio)) + (64 + 36) * _widthRatio
            }
        }
        else if cellType == .tip {
            if tipSelect == 2 {
                return 284 * _widthRatio
            } else {
                return 224 * _widthRatio
            }
        }
        return cellType.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrCells[indexPath.row]
        if EnumHelper.checkCases(cellType, cases: [.detail, .seatBookedCount, .bookReqCount, .carInfo, .driverInfo, .driverMessage]) {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath) as! RideDetailCell
            cell.parent = self
            cell.prepareUI(cellType)
            cell.action_openStopOver = { [weak self] in
                guard let `self` = self else { return }
                self.openStopoverList()
            }
            cell.action_openBookReq = { [weak self] in
                guard let self = self else { return }
                self.openRiderList(.bookingReq)
            }
            cell.action_openInvitations = { [weak self] in
                guard let self = self else { return }
                self.openRiderList(.invites)
            }
            cell.action_openCarImage = { [weak self] (idx) in
                guard let self = self else { return }
                self.openCarImages(idx)
            }
            cell.action_msg_driver = { [weak self] in
                guard let self = self else { return }
                self.msgDriverTap()
            }
            return cell
        }
        else if cellType == .availableSeats {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath) as! AvailableSeatsCell
            cell.arrSeats = Array.init(repeating: 1, count: data.seatTotal)
            cell.prepareSeatLeftUI("Seat left - \(data.seatLeft!)", data.seatBooked, isfromDetails: true)
            return cell
        }
        else if cellType == .seatListCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath) as! RideDetailBookingListTVC
            cell.delegate = self
            return cell
        }
        else if cellType == .pref {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath) as! RideDetailPrefCell
                cell.arrPrefs = data.arrPrefs
                cell.viewLuggage.isHidden = data.arrLuggage.isEmpty
                cell.lblLuggage.text = data.rideLuggageStr
            return cell
        }
        else if cellType == .tip {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath) as! RideTipTVC
            cell.parent = self
            cell.updateTipAmountSelection(tipSelect)
            cell.prepareUI(tipAmount)
            
            cell.action_tipAmount_tap = { [weak self] (tag) in
                guard let self = self else { return }
                if tag == 0 {
                    self.tipAmount = "5"
                } else if tag == 1 {
                    self.tipAmount = "10"
                } else {
                    self.tipAmount = ""
                }
                if self.tipSelect == tag { return }
                self.tipSelect = tag
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
            cell.action_pay_tip = { [weak self] in
                guard let self = self else { return }
                self.payDriverTip()
            }
            return cell
        } else if cellType == .review {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath) as! RideReviewTVC
            if let review = data.review {
                cell.prepareUI(review)
            }
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? TitleTVC {
            if arrCells[indexPath.row + 1] == .carInfo {
                cell.prepareUI("Car details", AppFont.fontWithName(.mediumFont, size: 18 * _fontRatio), clr: AppColor.primaryText)
            } else {
                cell.prepareUI("Driver details", AppFont.fontWithName(.mediumFont, size: 18 * _fontRatio), clr: AppColor.primaryText)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if cellType == .driverInfo {
            let vc = UserDetailVC.instantiate(from: .Home)
            vc.userId = data.driver!.id
            vc.isDriver = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - Notification Observers
extension RideDetailVC {
    
    func addObservers() {
        _defaultCenter.addObserver(self, selector: #selector(rideDetailsUpdate(_:)), name: Notification.Name.rideDetailsUpdate, object: nil)
    }
    
    @objc func rideDetailsUpdate(_ notification: NSNotification){
        getRideDetails()
    }
}

// MARK: - UIKeyboard Observer
extension RideDetailVC {
    
    func addKeyboardObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 10, right: 0)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification){
        guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        tableView.contentInset = UIEdgeInsets.zero
    }
}

// MARK: - API Calls
extension RideDetailVC {
    
    /// My Ride Details
    func getMyRideDetails() {
        if !refresh.isRefreshing {
            showCentralSpinner()
        }
        
        WebCall.call.getMyRideDetails(rideId) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            self.refresh.endRefreshing()
            
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
                self.data = RideDetails(data)
                DispatchQueue.main.async {
                    if !self.isPastData && EnumHelper.checkCases(self.data.status, cases: [.cancelled, .autoCancelled, .completed, .rejected]) {
                        self.remove_fromList_callback?()
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.prepareTableCells()
                        self.updateUI()
                        self.prepareOptionsMenu()
                    }
                }
                self.tableView.reloadData()
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    /// Booked Ride Details
    func getBookedRideDetails() {
        if !refresh.isRefreshing {
            showCentralSpinner()
        }
        WebCall.call.getBookedRideDetails(rideId) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            self.refresh.endRefreshing()
            
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
                self.data = RideDetails(data)
                DispatchQueue.main.async {
                    if !self.isPastData && EnumHelper.checkCases(self.data.status, cases: [.cancelled, .autoCancelled, .completed, .rejected]) {
                        self.remove_fromList_callback?()
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.updateUI()
                    }
                }
                self.tableView.reloadData()
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    /// Find Ride Details
    func getFindRideDetails() {
        var param: [String: Any] = [:]
        param["ride_id"] =  findRide.rideId
        param["from_latitude"] = findRide.start?.lat
        param["from_longitude"] = findRide.start?.long
        param["to_latitude"] = findRide.dest?.lat
        param["to_longitude"] = findRide.dest?.long
        
        if !refresh.isRefreshing {
            showCentralSpinner()
        }
        
        WebCall.call.getFindRideDetails(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            self.refresh.endRefreshing()
            
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
                self.data = RideDetails(data)
                self.tableView.reloadData()
                DispatchQueue.main.async {
                    self.updateUI()
                }
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    fileprivate func updateRideStatus(_ status: UpdateRideStatus) {
        var param:[String: Any] = [:]
        param["ride_id"] = rideId
        param["ride_status"] = status.rawValue
        
        if EnumHelper.checkCases(status, cases: [.start_ride, .complete_ride]) {
            param["date_time"] = Date().converDisplayDateTimeFormet()
        }
        
        showCentralSpinner()
        WebCall.call.updateRideStatus(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.getMyRideDetails()
                _defaultCenter.post(name: Notification.Name.rideListUpdate, object: nil)
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    /// Share ride content
    func getShareContent() {
        showCentralSpinner()
        WebCall.call.getCmsDetails(.shareRide) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
                let data = data.getStringValue(key: "content")
                let share = self.data.getShareString(data)
                let shareStr = share.htmlDecoded
                self.openShareRide(shareStr)
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    fileprivate func openShareRide(_ str: String) {
        let objToShare: [Any] = [str]
        let activityVC = UIActivityViewController(activityItems: objToShare, applicationActivities: nil)
        activityVC.setValue(title, forKey: "Subject")
        activityVC.excludedActivityTypes = [.postToFacebook, .copyToPasteboard, .message]
        self.present(activityVC, animated: true, completion: nil)
    }
}
