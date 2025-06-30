//
//  ImageCollectionViewCell.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class ImageCollectionViewCell: ConstrainedCollectionViewCell {

    static var identifier: String = "imageCollectionViewCell"
    
    /// Outlets
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var deleteBtnHeight: NSLayoutConstraint!
    
    /// Variables
    var action_deleteImage:(() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        deleteBtnHeight.constant = (DeviceType.iPad ? 28 : 22) * _widthRatio
    }

    /// Delete button actions
    @IBAction func btnDeleteTap(_ sender: UIButton) {
        action_deleteImage?()
    }
}

//MARK: - Register Cell
extension ImageCollectionViewCell {
    
    class func prepareToRegister(_ sender: UICollectionView) {
        sender.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: identifier)
    }
}
