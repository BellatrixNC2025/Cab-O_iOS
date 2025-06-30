//
//  DeleteAccountInfoVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

// MARK: - DeleteAccountInfoVC
class DeleteAccountInfoVC: ParentVC {
    
    /// Variables
    var arrInfo: [String] = ["Once your request is processed, your personal data will be deleted permanently (except for certain information that we are legally required or permitted to retain, as outlined in our Privacy Policy)", "If you want to use Eco Carpool in the future, you'll need to set up a new account.", "If you have future reservations as a Host or guest, you'll need to cancel them before submitting your deletion request."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - TableView Methods
extension DeleteAccountInfoVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrInfo.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return "About account deletion requests".heightWithConstrainedWidth(width: _screenSize.width - (80 * _widthRatio), font: AppFont.fontWithName(.mediumFont, size: 24 * _fontRatio)) + (24 * _heightRatio)
        } else {
            let str = arrInfo[indexPath.row - 1]
            let height: CGFloat = str.heightWithConstrainedWidth(width: _screenSize.width - (84 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (16 * _heightRatio)
            return max(height, 50 * _heightRatio)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
        }
        return tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? DeleteAccountCell {
            if indexPath.row == 0 {
                cell.labelTitle.text = "About account deletion requests"
            } else {
                cell.labelTitle.text = arrInfo[indexPath.row - 1]
            }
        }
    }
}
