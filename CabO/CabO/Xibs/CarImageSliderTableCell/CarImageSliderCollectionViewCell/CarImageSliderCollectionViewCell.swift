//
//  CarImageSliderCollectionViewCell.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class CarImageSliderCollectionViewCell: ConstrainedCollectionViewCell {

    static var identifier: String = "carImageSliderCollectionViewCell"
    
    /// Outlets
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

//MARK: - Register Cell
extension CarImageSliderCollectionViewCell {
    
    class func prepareToRegister(_ sender: UICollectionView) {
        sender.register(UINib(nibName: "CarImageSliderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: identifier)
    }
}
