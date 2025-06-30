//
//  RateAndReviewModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - RateAndReview CellType
enum RateAndReviewCellType: CaseIterable {
    case user, rating, comment, btn
    
    var cellId: String {
        switch self {
        case .user: return "userCell"
        case .rating: return "ratingCell"
        case .comment: return InputCell.textViewIdentifier
        case .btn: return ButtonTableCell.identifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .comment: return InputCell.textViewHeight
        case .btn: return ButtonTableCell.cellHeight
        default: return UITableView.automaticDimension
        }
    }
}

// MARK: - Rating Model
class RatingModel {
    
    var toUserId: Int!
    var toBookingId: Int?
    var toUserImage: String?
    var toUserName: String?
    var rating: Int?
    var msg: String = ""
    
}

// MARK: - GiveRating Cell
class GiveRatingCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet var imgStars: [UIImageView]!
    @IBOutlet var btnStars: [UIButton]!
    
    /// Variables
    var action_rating: ((Int) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareRatingUI(_ rating: Int?) {
        if let rating {
            imgStars.forEach { img in
                img.tintColor = img.tag <= rating ? UIColor.systemYellow : AppColor.headerBg
            }
        } else {
            imgStars.forEach { star in
                star.tintColor = AppColor.headerBg
            }
        }
    }
    
    @IBAction func btn_star_tap(_ sender: UIButton) {
        self.prepareRatingUI(sender.tag)
        action_rating?(sender.tag)
    }
}
