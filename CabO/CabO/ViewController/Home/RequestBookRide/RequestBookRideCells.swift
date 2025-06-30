//
//  RequestBookRideCell.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

class RequestBookRideCell : ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var labelSeatCount: UILabel!
    @IBOutlet weak var buttonPlus: UIButton!
    @IBOutlet weak var buttonMinus: UIButton!
    @IBOutlet weak var textFieldPromoCode: UITextField!
    @IBOutlet weak var buttonApply: UIButton!
    @IBOutlet weak var labelPromoStatus: UILabel!
    @IBOutlet weak var stackPriceDetails: UIStackView!
    @IBOutlet weak var viewPriceDetails: NRoundView!
    
    @IBOutlet weak var lblPromo: UILabel!
    @IBOutlet weak var btnClearPromo: UIButton!
    @IBOutlet weak var viewPromoApplied: UIView!
    @IBOutlet weak var viewPromoInput: UIView!
    
    @IBOutlet weak var viewBasePrice: UIView!
    @IBOutlet weak var viewBookingFee: UIView!
    @IBOutlet weak var viewPromoFee: UIView!
    @IBOutlet weak var vwTip: UIView!
    @IBOutlet weak var viewTotalPrice: UIView!
    
    @IBOutlet weak var lblBasePriceTitle: UILabel!
    @IBOutlet weak var lblBasePrice: UILabel!
    @IBOutlet weak var lblBookigFee: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var lblTip: UILabel!
    @IBOutlet weak var lblBookingTitle: UILabel!
    @IBOutlet weak var lblTotalPriceTitle: UILabel!
    @IBOutlet weak var lblTotalPrice: UILabel!
    
    @IBOutlet weak var btnCancelChargeInfo: UIButton!
    @IBOutlet weak var btnPaymentInfo: UIButton!
    
    @IBOutlet weak var lblPaymentCardTitle: UILabel!
    @IBOutlet weak var imgCardType: UIImageView!
    @IBOutlet weak var lblCardNum: UILabel!
    
    /// Variables
    weak var delegate: ParentVC! {
        didSet {
            prepareUI()
        }
    }
    
    var action_plus_minus_seat:((Int) -> ())?
    var action_apply_promo:(() -> ())?
    var action_clear_promo:(() -> ())?
    var info_cancel_cahrge_callback: (() -> ())?
    var info_payment_info_callback: ((AnyObject) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textFieldPromoCode?.font = AppFont.fontWithName(.mediumFont, size: 14 * _fontRatio)
    }
}

// MARK: - UI Methods
extension RequestBookRideCell {
    
    func prepareUI() {
        if let parent = delegate as? RequestBookRideVC {
            prepareUI(parent)
        }
        else if let parent = delegate as? PaymentDetailVC {
            prepareUI(parent)
        }
    }
    
    func prepareUI(_ parent: RequestBookRideVC) {
        let data = parent.data
        let cellType = parent.arrCells[self.tag]
        if cellType == .seatRequired {
            labelSeatCount.text = "\(data.seatsReq!)"
        }
        else if cellType == .promoCode {
            lblPromo.text = parent.promoCode
            textFieldPromoCode.text = parent.promoCode
            viewPromoInput.isHidden = data.couponId != nil
            viewPromoApplied.isHidden = data.couponId == nil
        }
        else if cellType == .fareDetails {
            viewPromoFee.isHidden = data.couponId == nil
            lblBasePrice.text = "₹\(data.price.stringValues)"
            lblBookigFee.text = "₹\(data.bookingFee.stringValues)"
            lblDiscount.text = "-₹\(data.discountAmount.stringValues)"
            lblTotalPrice.text = "₹\(data.couponId == nil ? data.totalPrice.stringValues : data.finalPrice.stringValues)"
        }
        textFieldPromoCode?.returnKeyType = .done
    }
    
    func prepareUI(_ parent: PaymentDetailVC) {
        let data = parent.data!
//        let isCancel: Bool = EnumHelper.checkCases(parent.screenType, cases: [.myrideCancel, .bookingCancel, .bookingCancel])
        let cellType = parent.arrCells[self.tag]
        if cellType == .fareDetails {
            viewPromoFee.isHidden = data.discountPrice == 0
            vwTip.isHidden = data.tipAmount == 0
            btnCancelChargeInfo.isHidden = !data.isRefund || self.tag == 0
            lblTotalPriceTitle.text = self.tag == 0 ? "Total paid" : "Total refundable"
            
            if self.tag == 1 {
                viewBasePrice.isHidden = true
                viewPromoFee.isHidden = true
                vwTip.isHidden = true
                
                lblBookingTitle.text = "Cancellation charges"
                
                lblBookigFee.text       = "₹\(data.cancelCharge.stringValues)"
                lblTotalPrice.text      = "₹\(data.refund.stringValues)"
            } else {
                
                lblBasePrice.text       = "₹\(data.price.stringValues)"
                lblBookigFee.text       = "₹\(data.bookingFee.stringValues)"
                lblTip.text             = "₹\(data.tipAmount.stringValues)"
                lblDiscount.text        = "-₹\(data.discountPrice.stringValues)"
                lblTotalPrice.text      = "₹\(data.finalPrice.stringValues)"
            }
        } else if cellType == .cardDetail {
            btnPaymentInfo?.isHidden = !data.isRefund
            lblPaymentCardTitle?.text = data.isRefund ? "Refund to" : "Payment via"
            imgCardType?.image = CardType(data.cardType).image
            lblCardNum?.text = data.cardNum.stringValue
        }
    }
}

// MARK: - Button Actions
extension RequestBookRideCell {
    
    @IBAction func buttonPlusMinusTap(_ sender: UIButton) {
        action_plus_minus_seat?(sender.tag)
    }
    
    @IBAction func buttonApplyTap(_ sender: UIButton) {
        action_apply_promo?()
    }
    
    @IBAction func btn_clearPromo(_ sender: UIButton) {
        action_clear_promo?()
    }
    
    @IBAction func action_cancel_charge_info(_ sender: UIButton) {
        info_cancel_cahrge_callback?()
    }
    
    @IBAction func action_payment_info(_ sender: UIButton) {
        info_payment_info_callback?(sender)
    }
}

// MARK: - UITextFieldDelegate
extension RequestBookRideCell: UITextFieldDelegate {
    
    @IBAction func promoCodeChanged(_ sender: UITextField) {
        if let parent = delegate as? RequestBookRideVC {
            parent.promoCode = sender.text!.trimmedString()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
