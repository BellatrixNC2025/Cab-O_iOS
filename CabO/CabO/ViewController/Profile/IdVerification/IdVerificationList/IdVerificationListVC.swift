//
//  IdVerificationListVC.swift
//  CabO
//
//  Created by OctosMac on 03/07/25.
//

import UIKit

class IdVerificationListVC: ParentVC {
    /// Variables
    var arrCells : [VerificaionListModel] = VerificaionListModel.allCases
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        prepareUI()
        addObservers()
    }
 

}
//MARK: - UI Methoods
extension IdVerificationListVC {

    
    func prepareUI() {
        
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        registerCells()
    }
    
    func registerCells() {
//        TitleTVC.prepareToRegisterCells(tableView)
    }
}
//MARK: - Button Actions
extension IdVerificationListVC {
    @IBAction func btnAddTap(_ sender: UIButton) {
        let vc = IdVerificationVC.instantiate(from: .Profile)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnViewTap(_ sender: UIButton) {
        let vc = IdVerificationVC.instantiate(from: .Profile)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - TableView Methods
extension IdVerificationListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15 * _widthRatio
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let uw = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 15*_widthRatio))
        uw.backgroundColor = UIColor.clear
        return uw
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrCells[indexPath.row]
       
        let cell = tableView.dequeueReusableCell(withIdentifier: cellType.celld, for: indexPath) as! VerificaionListCell
        cell.parent = self
        cell.prepareUI(cellType)
        return cell
    }
}
//MARK: - Notification Observers
extension IdVerificationListVC {
    
    func addObservers() {
//        _defaultCenter.addObserver(self, selector: #selector(userProfileEdited(_:)), name: Notification.Name.userProfileUpdate, object: nil)
    }
    
    @objc func userProfileEdited(_ notification: NSNotification){
//        _appDelegator.getUserProfile { [weak self] (succ, json) in
//            guard let weakSelf = self else { return }
//            if succ {
//                weakSelf.labelUserName?.text = _user?.fullName
//                weakSelf.imgVerifyBadgeRight.isHidden = !(_user?.userVerify ?? false)
//                if let profileImg = _user?.profilePic, !profileImg.isEmpty {
//                    weakSelf.imgUserProfile.loadFromUrlString(profileImg, placeholder: _userPlaceImage)
//                } else {
//                    weakSelf.imgUserProfile.image = _userPlaceImage
//                }
//            }
//        }
    }
    
}

// MARK: - API Calls
extension IdVerificationListVC {
    
    func logOutUser() {
        self.showCentralSpinner()
        _appDelegator.prepareForLogout { [weak self] (success, json) in
            guard let weakSelf = self else { return }
            weakSelf.hideCentralSpinner()
        }
    }
}
