//
//  LoginVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class NoDataCell: ConstrainedTableViewCell {
    
    static let identifier: String = "noDataCell"
    
    /// Outlets
    @IBOutlet weak var btnCreate: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    /// Variables
    var btnCreateTap: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// Prepare UI
    func prepareUI( img: UIImage = UIImage(named: "ic_no_data_found")!, title: String = "No data found", subTitle: String = "") {
        imgView.image = img
        lblTitle.text = title
        lblSubTitle.text = subTitle
    }
    
    /// Button Actions
    @IBAction func btnCreateTap(_ sender: UIButton) {
        btnCreateTap?()
    }
}

//MARK: - Register Cell
extension NoDataCell {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "NoDataCell", bundle: nil), forCellReuseIdentifier: identifier)
    }
}
