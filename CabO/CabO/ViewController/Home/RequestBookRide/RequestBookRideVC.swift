//
//  RequestBookRideVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class RequestBookRideVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var viewContinue: UIView!
    @IBOutlet weak var btnConinue: UIButton!
    @IBOutlet weak var btnView: UIView!
    
    /// Variables
    var arrCells: [RequestBookRideCellType] = [.seatRequired, .promoCode, .fareDetails, .message]
    var data: RequestBookRideModel = RequestBookRideModel()
    var promoCode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

// MARK: - UI Methods
extension RequestBookRideVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
        registerCells()
        getRequestPrice()
        addKeyboardObserver()
    }
    
    func registerCells() {
        InputCell.prepareToRegisterCells(tableView)
        tableView.reloadData()
    }
}


// MARK: - Actions
extension RequestBookRideVC {
    
    @IBAction func action_continueTap(_ sender: UIButton) {
        let vc = RideRulesVC.instantiate(from: .Home)
        vc.screenType = .book
        vc.bookData = data
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - TableView Methods
extension RequestBookRideVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if cellType == .promoCode {
            return ((data.couponId == nil ? (46 * _widthRatio) : (62 * _widthRatio)) + (50 * _widthRatio))
        } else if cellType == .fareDetails {
            return ( (data.couponId != nil ? (45 * _widthRatio) : 0) + ((44 * _widthRatio) * 3) + (50 * _widthRatio))
        }
        return cellType.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrCells[indexPath.row]
        return tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let _ = arrCells[indexPath.row]
        if let cell = cell as? RequestBookRideCell {
            cell.tag = indexPath.row
            cell.delegate = self
            
            cell.action_plus_minus_seat = { [weak self] (add) in
                guard let self = self else { return }
                self.plusMinusSeat(add == 1)
            }
            cell.action_apply_promo = { [weak self] in
                guard let self = self else { return }
                self.applyPromoCode()
            }
            cell.action_clear_promo = { [weak self] in
                guard let self = self else { return }
                self.clearPromoCode()
            }
        }
        else if let cell = cell as? InputCell {
            cell.tag = indexPath.row
            cell.delegate = self
        }
    }
}

// MARK: - UIKeyboard Observer
extension RequestBookRideVC {
    
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
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
    }
}

// MARK: - API Calls
extension RequestBookRideVC {
    
    private func plusMinusSeat(_ isAdd: Bool) {
        let cell = tableViewCell(index: 0) as! RequestBookRideCell
        if isAdd {
            let seatLeft = data.rideDetails.seatLeft!
            if data.seatsReq < seatLeft {
                data.seatsReq += 1
                cell.labelSeatCount.text = "\(data.seatsReq!)"
                self.getRequestPrice()
            } else {
                ValidationToast.showStatusMessage(message: "Only \(seatLeft) \(seatLeft == 1 ? "seat is" : "seats are") left in this ride", yCord: _navigationHeight)
            }
        } else {
            if data.seatsReq > 1 {
                self.data.seatsReq -= 1
                cell.labelSeatCount.text = "\(data.seatsReq!)"
                self.getRequestPrice()
            }
        }
    }
    
    func getRequestPrice() {
        if data.couponId != nil {
            data.couponId = nil
            promoCode = ""
            tableView.reloadData()
        }
        
        var param: [String: Any] = [:]
        param["no_of_seats"] = data.seatsReq!
        param["miles"] = data.rideDetails.totalMiles
        param["price"] = data.rideDetails.price
        
        let cell = tableViewCell(index: 2) as! RequestBookRideCell
        cell.showSpinnerIn(container: cell.viewPriceDetails, control: cell.lblBasePrice, isCenter: true)
        cell.showSpinnerIn(container: cell.viewPriceDetails, control: cell.lblBookigFee, isCenter: true)
        cell.showSpinnerIn(container: cell.viewPriceDetails, control: cell.lblDiscount, isCenter: true)
//        cell.showSpinnerIn(container: cell.viewPriceDetails, control: cell.lblTip, isCenter: true)
        cell.showSpinnerIn(container: cell.viewPriceDetails, control: cell.lblTotalPrice, isCenter: true)
        
        showSpinnerIn(container: self.btnView, control: self.btnConinue, isCenter: true)
        WebCall.call.getRequestRidePrice(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideSpinnerIn(container: self.btnView, control: self.btnConinue)
            cell.hideSpinnerIn(container: cell.viewPriceDetails, control: cell.lblBasePrice)
            cell.hideSpinnerIn(container: cell.viewPriceDetails, control: cell.lblBookigFee)
            cell.hideSpinnerIn(container: cell.viewPriceDetails, control: cell.lblDiscount)
//            cell.hideSpinnerIn(container: cell.viewPriceDetails, control: cell.lblTip)
            cell.hideSpinnerIn(container: cell.viewPriceDetails, control: cell.lblTotalPrice)
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
                self.data.updatePrice(data)
                self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    func clearPromoCode() {
        data.couponId = nil
        promoCode = ""
        tableView.reloadData()
    }
    
    func applyPromoCode() {
        if promoCode.isEmpty {
            ValidationToast.showStatusMessage(message: "Please enter a valid promo code to apply", yCord: _navigationHeight)
        } else {
            var param: [String: Any] = [:]
            param["coupon_code"] = promoCode
            param["price"] = data.price
            
            showCentralSpinner()
            WebCall.call.applyPromoCode(param) { [weak self] (json, status) in
                guard let self = self else { return }
                self.hideCentralSpinner()
                if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
                    self.data.applyPromo(data)
                    self.tableView.reloadData()
                } else {
                    self.showError(data: json, yCord: _navigationHeight)
                }
            }
        }
    }
}
