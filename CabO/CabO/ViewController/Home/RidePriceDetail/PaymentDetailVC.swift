//
//  PaymentDetailVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

// MARK: - PaymentDetail ScreenType
enum PaymentDetailScreenType {
    case myrideComplete, myrideCancel
    case bookingComplete, bookingCancel, bookingReject
    
    var paymentAddMinus: String {
        switch self {
        case .myrideCancel: return "-"
        case .bookingComplete: return ""
        default: return "+"
        }
    }
}

// MARK: - PaymentDetailVC
class PaymentDetailVC: ParentVC {
    
    /// Variables
    var arrCells: [RequestBookRideCellType]!
    var data: RideTransactionDetail!
    var screenType: PaymentDetailScreenType!
    
    var tripCode: String!
    var arrPayments: [RideUserPaymentDetails]!
    var platformFee: Double!
    var totalCount: Int!
    var totalPrice: Double!
    var totalRefund: Double!
    
    var rideId: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        if EnumHelper.checkCases(screenType, cases: [.myrideComplete, .myrideCancel]) {
            getPaymentDetails()
        }
    }
}

// MARK: - UI Methods
extension PaymentDetailVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12 * _widthRatio, left: 0, bottom: 50, right: 0)
        tableView.layoutMargins = UIEdgeInsets(top: 0, left: 25 * _widthRatio, bottom: 50, right: 25 * _widthRatio)
        if let data {
            arrCells = data.isRefund ? [.fareDetails, .fareDetails, .cardDetail] : [.fareDetails, .cardDetail]
        }
        tableView.reloadData()
        
        NoDataCell.prepareToRegisterCells(tableView)
    }
}

// MARK: - TableView Methods
extension PaymentDetailVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if EnumHelper.checkCases(screenType, cases: [.bookingComplete, .bookingCancel]) {
            return 1
        }
        else if EnumHelper.checkCases(screenType, cases: [.myrideComplete, .myrideCancel]) {
            if arrPayments == nil {
                return 0
            } else {
                return arrPayments.isEmpty ? 1 : (totalPrice == 0 ? 1 : 2)
            }
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if EnumHelper.checkCases(screenType, cases: [.bookingComplete, .bookingCancel]) {
            return data.isRefund ? 3 : 2
        }
        else if EnumHelper.checkCases(screenType, cases: [.myrideComplete, .myrideCancel]) {
            if arrPayments.isEmpty {
                return 1
            } else {
                if section == 1 {
                    return arrPayments.count
                } else {
                    return 1
                }
            }
        } else {
            return arrCells.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if EnumHelper.checkCases(screenType, cases: [.bookingComplete, .bookingCancel]) {
            if indexPath.row == 0 {
                return ((data.discountPrice != 0 ? 35 : 0) + (data.cancelCharge != 0 ? 35 : 0) + (35 * 3) + 35) * _widthRatio
            } else if indexPath.row == 1 && data.isRefund {
                return ((35 * 2) + 32) * _widthRatio
            }
            return UITableView.automaticDimension
        }
        else {
            if arrPayments.isEmpty {
                return tableView.frame.height
            } else {
                return UITableView.automaticDimension
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16 * _widthRatio
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if EnumHelper.checkCases(screenType, cases: [.bookingComplete, .bookingCancel]) {
            if indexPath.row == 0 || (data.isRefund && indexPath.row == 1) {
                return tableView.dequeueReusableCell(withIdentifier: "fareDetails", for: indexPath)
            } else {
                return tableView.dequeueReusableCell(withIdentifier: "cardDetails", for: indexPath)
            }
        }
        else {
            if arrPayments.isEmpty {
                return tableView.dequeueReusableCell(withIdentifier: NoDataCell.identifier, for: indexPath)
            } else {
                if indexPath.section == 0 {
                    return tableView.dequeueReusableCell(withIdentifier: "totalEarning", for: indexPath)
                }
                else {
                    return tableView.dequeueReusableCell(withIdentifier: "userPayCell", for: indexPath)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? RequestBookRideCell {
            cell.tag = indexPath.row
            cell.delegate = self
            
            cell.info_cancel_cahrge_callback = { [weak self]  in
                guard let self = self else { return }
                let vc = CmsVC.instantiate(from: .CMS)
                vc.screenType = .cancellationPolicy
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            cell.info_payment_info_callback = { [weak self] (btn) in
                guard let self = self else { return }
                self.openPopOver(view: btn, msg: "It will take 2-3 working days to refund amount in your card.")
            }
        }
        else if let cell = cell as? NoDataCell {
            cell.prepareUI()
        }
        else if let cell = cell as? RideUserPaymentDetailsCell {
            
            cell.info_cancel_tap = { [weak self] (btn) in
                guard let self = self else { return }
                self.openPopOver(view: btn, msg: "According to the Eco Carpool clause, as per the earlier ride RideID: \(tripCode!) has been cancelled by you. Consequently, your account will be debited with penalty charges.")
            }
            
            cell.backgroundColor = AppColor.headerBg
            
            if indexPath.section == 0 {
                cell.lblTitle?.text = "Total earning"
                cell.lblDesc?.text = "It will take 2-3 working days to transfer amount in your bank account."
                cell.lblPrice?.text = "₹\(screenType == .myrideCancel ? "0.0" : totalPrice.stringValues)"
            }
            else {
                
                let user = arrPayments[indexPath.row]
                cell.imgVeiew?.loadFromUrlString(user.userImage, placeholder: _userPlaceImage)
                cell.lblTitle?.text = "Payment from:"
                
                let seatText = " (\(user.seatCount.stringValue) \(user.seatCount > 1 ? "Seats" : "Seat"))"
                
                cell.lblDesc.text = user.userName + seatText
                cell.lblPrice.text = "₹\(user.price.stringValues)"
                
                if user.isRefund {
                    cell.lblTip.isHidden = user.refundAmount == nil || user.refundAmount == 0
                    if user.refundAmount != nil {
                        cell.lblTip.text = "- ₹\(user.refundAmount.stringValues) Refund"
                        cell.lblTip.textColor = UIColor.red
                    }
                } else {
                    cell.lblTip.isHidden = user.tip == nil || user.tip == 0
                    if user.tip != nil {
                        cell.lblTip.text = "+ ₹\(user.tip.stringValues) Tip"
                        cell.lblTip.textColor = AppColor.themeGreen
                    }
                }
            }
        }
    }
}

// MARK: - API Calls
extension PaymentDetailVC {
    
    func getPaymentDetails() {
        
        showCentralSpinner()
        WebCall.call.getMyRideTransactionDetails(rideId) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            self.arrPayments = []
            self.totalCount = 0
            if status == 200, let dict = json as? NSDictionary{
                self.totalCount = dict.getIntValue(key: "total_count")
                self.totalPrice = dict.getDoubleValue(key: "total_price")
                self.totalRefund = dict.getDoubleValue(key: "total_refund")
                
                if let data = dict["data"] as? [NSDictionary] {
                    data.forEach { pay in
                        self.arrPayments.append(RideUserPaymentDetails(pay))
                    }
                }
                self.tableView.reloadData()
            } else {
                self.tableView.reloadData()
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
}
