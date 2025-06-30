//
//  SeatSelectionCollectionCell.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import Kingfisher

class CreateRidePreferenceCollectionCell: ConstrainedCollectionViewCell {
    
    static var identifier: String = "createRidePreferenceCollectionCell"
    
    /// Outlets
    @IBOutlet weak var bgView: NRoundView!
    @IBOutlet weak var imgPref: TintImageView!
    @IBOutlet weak var labelPrefName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        imgPref?.setViewHeight(height: (DeviceType.iPad ? 20 : 14) * _widthRatio)
    }
    
    /// Prepare Cell UI
    func prepareUI(_ pref: RidePrefModel, _ isSelected: Bool = false) {
        if pref.id == 0 {
            self.imgPref.image = pref.img.withTintColor(isSelected ? AppColor.primaryTextDark : AppColor.primaryText)
        } else {
            imgPref.loadFromUrlString(pref.image, completionHandler:  { result in
                switch result {
                    case .success(let value):
                    self.imgPref.image = self.imgPref.image?.withTintColor(isSelected ? AppColor.primaryTextDark : AppColor.primaryText)
                    case .failure(let error):
                        print(error)
                    }
            })
        }
        labelPrefName.text = pref.title
        bgView.backgroundColor = isSelected ? AppColor.vwBgColor : AppColor.headerBg
        labelPrefName.textColor = isSelected ? AppColor.primaryTextDark : AppColor.primaryText
    }
}

//MARK: - Register Cell
extension CreateRidePreferenceCollectionCell {
    
    class func prepareToRegister(_ sender: UICollectionView) {
        sender.register(UINib(nibName: "CreateRidePreferenceCollectionCell", bundle: nil), forCellWithReuseIdentifier: identifier)
    }
}
