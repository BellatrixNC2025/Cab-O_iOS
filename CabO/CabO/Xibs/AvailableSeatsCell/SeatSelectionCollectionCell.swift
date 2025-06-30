//
//  SeatSelectionCollectionCell.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class SeatSelectionCollectionCell: ConstrainedCollectionViewCell {
    
    static var identifier: String = "seatSelectionCollectionCell"
    static var cellSize: CGSize = CGSize(width: (((_screenSize.width - (40 * _widthRatio)) / 7) - 4), height: (((_screenSize.width - (40 * _widthRatio)) / 7) - 4))
    
    /// Outlets
    @IBOutlet weak var bgView: NRoundView!
    @IBOutlet weak var imgSeat: UIImageView!
    @IBOutlet weak var gradientView: RoundGradientView!
    @IBOutlet weak var labelSeat: UILabel!
    @IBOutlet weak var heightConstant: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = (((_screenSize.width - (40 * _widthRatio)) / 7) - 4) / 2
    }
}

//MARK: - Register Cell
extension SeatSelectionCollectionCell {
    
    class func prepareToRegister(_ sender: UICollectionView) {
        sender.register(UINib(nibName: "SeatSelectionCollectionCell", bundle: nil), forCellWithReuseIdentifier: identifier)
    }
}
