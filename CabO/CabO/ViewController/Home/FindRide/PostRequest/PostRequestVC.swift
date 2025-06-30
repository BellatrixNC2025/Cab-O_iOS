//
//  PostRequestVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

fileprivate enum PostRequestCellType: CaseIterable {
    case startDest, date, seatAvailable, message
    
    var cellId: String {
        switch self {
        case .startDest: return StartDestPickerCell.identifier
        case .date: return DatePickerCell.identifier
        case .seatAvailable: return AvailableSeatsCell.identifier
        case .message: return InputCell.textViewIdentifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .startDest: return StartDestPickerCell.height
        case .date: return DatePickerCell.height
        case .seatAvailable: return AvailableSeatsCell.titleCellHeight
        case .message: return InputCell.textViewHeight
        }
    }
}

class PostRequestVC: ParentVC {
    
    @IBOutlet weak var btnSubmit: UIButton!

    fileprivate let arrCells: [PostRequestCellType] = PostRequestCellType.allCases
    var data = PostRequestModel()
    var isEdit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

// MARK: - UI Methods
extension PostRequestVC {
    
    func prepareUI() {
        if isEdit {
            lblTitle?.text = "Edit request"
            btnSubmit.setTitle("Update", for: .normal)
        }
        tableView.contentInset = UIEdgeInsets(top: (8 * _widthRatio), left: 0, bottom: 50, right: 0)
        registerCells()
        addKeyboardObserver()
    }
    
    func registerCells() {
        StartDestPickerCell.prepareToRegisterCells(tableView)
        DatePickerCell.prepareToRegisterCells(tableView)
        AvailableSeatsCell.prepareToRegisterCells(tableView)
        InputCell.prepareToRegisterCells(tableView)
    }
}


// MARK: - Actions
extension PostRequestVC {
    
    func openLocationPickerFor(_ tag: Int) {
        let vc = SearchVC.instantiate(from: .Home)
        vc.selectionBlock = { [weak self] (address) in
            guard let self = self else { return }
            if tag == 0 {
                if let dest = self.data.dest, dest.formatedAddress == address.formatedAddress {
                    ValidationToast.showStatusMessage(message: "Selected address is already used as destination", yCord: _navigationHeight)
                } else {
                    self.data.start = address
                }
            } else {
                if let source = self.data.start, source.formatedAddress == address.formatedAddress {
                    ValidationToast.showStatusMessage(message: "Selected address is already used as source location", yCord: _navigationHeight)
                } else {
                    self.data.dest = address
                }
            }
            self.tableView.reloadData()
        }
        self.present(vc, animated: true)
    }
    
    @IBAction func buttonSubmitTap(_ sender: UIButton) {
        let valid = data.isValidData()
        if valid.0 {
            postRequest()
        } else {
            ValidationToast.showStatusMessage(message: valid.1, yCord: _navigationHeight)
        }
        
    }
}

// MARK: - TableView Methods
extension PostRequestVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        
        return cellType.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrCells[indexPath.row]
        return tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        _ = arrCells[indexPath.row]
        if let cell = cell as? StartDestPickerCell {
            cell.delegate = self
            cell.locationPickerTap = { [weak self] (tag) in
                guard let `self` = self else { return }
                self.openLocationPickerFor(tag)
            }
        }
        else if let cell = cell as? DatePickerCell {
            cell.lblTitle.text = "Select date"
            cell.lblTitle.font = AppFont.fontWithName(.mediumFont, size: 18 * _fontRatio)
            cell.datePicker.datePickerMode = .date
            
            cell.datePicker.minimumDate = Date()
            cell.datePicker.maximumDate = Date().adding(.day, value: _appDelegator.config.createRideMaxDays)
            
            
            if isEdit {
                if data.isDateChange {
                    cell.datePicker.date = data.rideDate
                } else {
                    cell.datePicker.date = data.rideDate.getUtcDate()!
                }
                cell.datePicker.timeZone = TimeZone(identifier: data.start!.timeZoneId)
            } else {
                cell.datePicker.date = data.rideDate
                cell.datePicker.timeZone = TimeZone.current
            }
            cell.dateChanges = { [weak self] (date) in
                guard let self = self else { return }
                self.data.rideDate = date
                self.data.isDateChange = true
            }
        }
        else if let cell = cell as? AvailableSeatsCell {
            cell.delegate = self
            cell.arrSeats = Array.init(repeating: 1, count: _appDelegator.config.createRideSeatLimit)
            cell.prepareUI("Seats required", hideSubTitle: true, data.seatReq, _appDelegator.config.createRideSeatLimit)
            cell.seatSelectionCallBack = { [weak self] (seat) in
                guard let self = self else { return }
                self.data.seatReq = seat
            }
        }
        else if let cell = cell as? InputCell {
            cell.tag = indexPath.row
            cell.delegate = self
        }
    }
}

// MARK: - UIKeyboard Observer
extension PostRequestVC {
    
    func addKeyboardObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        if let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height + (12 * _widthRatio), right: 0)
        }
        if let fIndex = arrCells.firstIndex(of: .message), let cell = tableViewCell(index: fIndex) as? InputCell, cell.txtView.isFirstResponder {
            scrollToIndex(index: fIndex, animate: true, .top)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification){
        guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        tableView.contentInset = UIEdgeInsets(top: (8 * _widthRatio), left: 0, bottom: 50, right: 0)
    }
}

// MARK: - API Call
extension PostRequestVC {
    
    func postRequest() {
        showCentralSpinner()
        WebCall.call.postRideRequest(data.postReqParam) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.showSuccess()
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    private func showSuccess() {
        if isEdit {
            _defaultCenter.post(name: Notification.Name.requestDetailsUpdate, object: nil)
            _defaultCenter.post(name: Notification.Name.requestListUpdate, object: nil)
            self.navigationController?.popViewController(animated: true)
        } else {
            let success = SuccessPopUpView.initWithWindow("Ride request posted successfully!", "We'll send you a notification when a new trip matches your request.", anim: .requestSent)
            success.callBack = { [weak self] in
                guard let `self` = self else { return }
                self.navigationController?.popToViewController(ofClass: NTabBarVC.self)
            }
        }
    }
}
