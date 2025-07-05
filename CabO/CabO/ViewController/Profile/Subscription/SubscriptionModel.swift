//
//  SubscriptionModel.swift
//  CabO
//
//  Created by OctosMac on 28/06/25.
//
import Foundation
import UIKit

// MARK: - SubscriptionPlans
class SubscriptionPlans {
    
    var id: String!
    var price: Double!
    var duration: Int!
    var duration_value: String!
    var role_id: String!
    var title: String!
    
    var durationTitle: String {
        return "/ \(duration!) \(duration_value.capitalized)"
    }
    
    var priceTitle: String {
        return price.currencyString
    }
    
    init(_ dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        price = dict.getDoubleValue(key: "final_price")
        duration = dict.getIntValue(key: "duration_value")
        duration_value = dict.getStringValue(key: "duration")
        role_id = dict.getStringValue(key: "role_id")
        title = dict.getStringValue(key: "title")
    }
}

//MARK: - SubscriptionCell
class SubscriptionCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var lblPlanName: UILabel!
    @IBOutlet weak var lblPlanPrice: UILabel!
    @IBOutlet weak var lblPlanDesc: UILabel!
    @IBOutlet weak var lblPlanDate: UILabel!
    @IBOutlet weak var btnSubscribe: UIButton!
    @IBOutlet weak var vwBg: UIView!
    /// Variables
    var btnSubscribeTap: (() -> ())?
    
    weak var parent: SubscriptionVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        btnSubscribe?.setViewWidth(width: (DeviceType.iPad ? 124 : 104) * _heightRatio)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func prepareUI(_ data: SubscriptionPlans) {
        lblPlanName.text = data.title
        lblPlanPrice.text = data.priceTitle
        
        
        self.layoutIfNeeded()
    }
    
    @IBAction func btnSubscribeTap(_ sender: UIButton) {
        self.btnSubscribeTap?()
    }
    
   
}
