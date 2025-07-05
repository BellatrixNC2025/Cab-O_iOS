//
//  AddCarCells.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - AddCarDocumentPickerCell
class AddCarDocumentPickerCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var viewUploadImage: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet var lblTitle: UILabel!
    /// Variables
    var action_btnUploadTap: ((AnyObject) -> ())?
    var action_btnDeleteTap: ((AnyObject) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareUI(_ img: UIImage?, isEditable: Bool = true,_ title:String = "") {
        if let img {
            imgView?.image = img
            imgView?.isHidden = false
            buttonDelete?.isHidden = !isEditable
            viewUploadImage?.isHidden = true
        } else {
            imgView?.isHidden = true
            buttonDelete?.isHidden = true
            viewUploadImage?.isHidden = false
            lblTitle?.text = title
        }
    }
    
    func prepareUI(_ img: String?, isEditable: Bool = true, _ title:String = "") {
        if let img {
            imgView?.loadFromUrlString(img, placeholder: _dummyPlaceImage)
            imgView?.isHidden = false
            buttonDelete?.isHidden = !isEditable
            viewUploadImage?.isHidden = true
        } else {
            imgView?.isHidden = true
            buttonDelete?.isHidden = true
            viewUploadImage?.isHidden = false
            lblTitle?.text = title
        }
    }
    
    @IBAction func btnUploadTap(_ sender: UIButton) {
        action_btnUploadTap?(sender)
    }
    
    @IBAction func btnDeleteTap(_ sender: UIButton) {
        action_btnDeleteTap?(sender)
    }
}
