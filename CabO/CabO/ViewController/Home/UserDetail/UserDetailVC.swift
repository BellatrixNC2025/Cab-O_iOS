//
//  UserDetailVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class UserDetailVC: ParentVC {
    
    /// Variables
    var arrCells: [UserDetailCellType]!
    var data: UserDetailModel!
    var userId: Int!
    var isDriver: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getUserDetails()
    }
}

// MARK: - UI Methods
extension UserDetailVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0 , bottom: 50, right: 0)
        
        lblTitle?.text = isDriver ? "Driver details" : "User details"
        
        if DeviceType.iPad {
            arrCells = [.info, .count, .bio, .verification, .social]
        } else {
            arrCells = [.info, .count, .count, .bio, .verification, .social]
        }
        if isDriver {
            arrCells.insert(.verification, at: 4)
        }
    }
    
    func showUserVerifyPopup() {
        let _ = SuccessPopUpView.initWithWindow("This is a verified profile", "Our team has verified the member's government-issued ID against the details they provided on \(_appName) to enhance safety within our community.", img: (data.image, _userPlaceImage), isVerifyPopUp: true)
    }
    
    func openReviews() {
        if data.totalReview > 0 {
            let vc = ReviewsVC.instantiate(from: .Profile)
            vc.userId = userId
            vc.userData = data
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func openUrl(_ tag: Int) {
        var uri = ""
        if tag == 0 {
            uri = data.fbLink
        }
        else if tag == 1 {
            uri = data.instaLink
        }
        else if tag == 2 {
            uri = data.twiterLink
        }
        if !uri.starts(with: "https://") {
            uri = "https://" + uri
        }
        
        DispatchQueue.main.async {
            if let url = URL(string: uri), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

// MARK: - TableView Methods
extension UserDetailVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data == nil ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if cellType == .bio {
            if data.bio.isEmpty {
                return 0
            } else {
                return data.bio.heightWithConstrainedWidth(width: _screenSize.width - (64 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + 48 * _heightRatio
                
            }
        } else if cellType == .social {
            if data.fbLink.isEmpty && data.twiterLink.isEmpty && data.instaLink.isEmpty {
                return 0
            } else {
                return UITableView.automaticDimension
            }
        }
        return cellType.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: arrCells[indexPath.row].cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? UserDetailCell {
            cell.tag = indexPath.row
            cell.parent = self
            
            cell.action_reviews = { [weak self] in
                guard let self = self else { return }
                self.openReviews()
            }
            
            cell.action_verify_badge = { [weak self] in
                guard let self = self else { return }
                self.showUserVerifyPopup()
            }
            
            cell.action_open_fb = { [weak self] in
                guard let self = self else { return }
                self.openUrl(0)
            }
            
            cell.action_open_insta = { [weak self] in
                guard let self = self else { return }
                self.openUrl(1)
            }
            
            cell.action_open_twiter = { [weak self] in
                guard let self = self else { return }
                self.openUrl(2)
            }
            
//            cell.action_call = { [weak self] in
//                guard let self = self else { return }
//            }
            
//            cell.action_email = { [weak self] in
//                guard let self = self else { return }
//            }
            
        }
    }
}

// MARK: - API Calls
extension UserDetailVC {
    
    func getUserDetails() {
        
        showCentralSpinner()
        WebCall.call.getUserDetails(userId) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
                self.data = UserDetailModel(data)
                self.tableView.reloadData()
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
}
