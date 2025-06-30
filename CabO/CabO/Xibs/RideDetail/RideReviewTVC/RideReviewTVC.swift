//
//  RideReviewTVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class RideReviewTVC: ConstrainedTableViewCell {
    
    static let identifier: String = "RideReviewTVC"
    
    /// Outlets
    @IBOutlet weak var vwRating: UIView!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblReview: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func prepareToRegister(_ sender: UITableView) {
        sender.register(UINib(nibName: "RideReviewTVC", bundle: nil), forCellReuseIdentifier: identifier)
    }
    
    func prepareUI(_ review: ReviewModel) {
        lblReview.isHidden = review.review.isEmpty
        lblReview.text = review.review
        lblRating.text = review.rating.stringValues
    }
}
