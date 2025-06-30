//
//  RideDetailPrefTableCell.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class RideDetailPrefTableCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var imgView: NRoundImageView!
    @IBOutlet weak var vwImg: NRoundView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vwImg?.setViewHeight(height: (DeviceType.iPad ? 32 : 28) * _widthRatio)
    }
    
    /// Prepare Cell UI
    func prepareUI(_ pref: RidePrefModel) {
        imgView.loadFromUrlString(pref.image, completionHandler:  { result in
            switch result {
            case .success(_):
                self.imgView.image = self.imgView.image?.withTintColor(.white)
                case .failure(let error):
                    print(error)
                }
        })
        
        lblTitle.text = pref.title
    }
}

// MARK: - Register Cell
extension RideDetailPrefTableCell {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "RideDetailPrefTableCell", bundle: nil), forCellReuseIdentifier: "rideDetailPrefTableCell")
    }
}
