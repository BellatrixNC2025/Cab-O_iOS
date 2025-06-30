//
//  AddProfilePicModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - AddProfilePicCells
enum AddProfilePicCells: CaseIterable {
    case title, desc1, desc2, desc3, img, btn, confirm
    
    var cellId: String {
        switch self {
        case .title, .desc1, .desc2, .desc3: return TitleTVC.identifier
        case .img: return "profileImageCell"
        case .btn: return ButtonTableCell.identifier
        case .confirm: return "confirmButton"
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
//        case .confirm: return ButtonTableCell.cellHeight + 48 * _heightRatio
        case .img: return 200 * _widthRatio
        default: return ButtonTableCell.cellHeight + 48 * _heightRatio
        }
    }
    
    var title: String {
        switch self {
        case .title: return "Add your profile picture for safer pickups"
        case .desc1: return "Enhance the security of your carpooling experience by uploading your profile picture. It helps drivers identify you easily during pickups, ensuring a smooth and efficient process."
        case .desc2: return "Your profile picture also fosters a sense of trust and community among fellow riders. Let's create a safer and more connected carpooling environment together."
        case .desc3: return "Please review your picture and make sure that it is clear."
        default: return ""
        }
    }
}

// MARK: - AddProfilePicImageCell
class AddProfilePicImageCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var imgView: UIImageView!
    
    /// Variables
    var btnChooseOtherTap:((AnyObject) -> ())?
    var btnSubmitTap:(() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// Actions
    @IBAction func btnChooseOtherTap(_ sender: UIButton) {
        btnChooseOtherTap?(sender)
    }
    
    @IBAction func btnSubmitTap(_ sender: UIButton) {
        btnSubmitTap?()
    }
}
