//
//  SideMenuVC.swift
//  CabO
//
//  Created by OctosMac on 25/06/25.
//

import UIKit

class SideMenuVC: ParentVC {
    /// Variables
    var arrSections: [SideMenuSections] = SideMenuSections.allCases
    weak var navigaton_controller : UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        prepareUI()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateBadge()
    }


}
//MARK: - UI Methoods
extension SideMenuVC {
    
    func updateBadge() {
//        _appDelegator.getUserProfile(updateToken: false) { [weak self] (succes, json) in
//            guard let self = self else { return }
//            self.imgVerifyBadgeRight.isHidden = !(_user?.userVerify ?? false)
//        }
    }
    
    func prepareUI() {
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        registerCells()
    }
    
    func registerCells() {
        TitleTVC.prepareToRegisterCells(tableView)
    }
}
//MARK: - Button Actions
extension SideMenuVC {
    @IBAction func buttonMenuTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnCheckCompleteProfile(_ sender: UIButton) {
        let vc = AddProfilePicVC.instantiate(from: .Profile)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func confirmLogout() {
        showConfirmationPopUpView("Confirmation!", "Are you sure you want to logout?", btns: [.no, .yes]) { btnType in
            if btnType == .yes {
                self.logOutUser()
            }
        }
    }
    
}
//MARK: - TableView Methods
extension SideMenuVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSections[section].arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let section = arrSections[indexPath.section]
        let cellType = arrSections[indexPath.section].arrCells[indexPath.row]
        if cellType == .userDetails {
            return UITableView.automaticDimension
        }
        return 50 * _widthRatio
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15 * _widthRatio
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let uw = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 15*_widthRatio))
        uw.backgroundColor = UIColor.clear
        return uw
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrSections[indexPath.section].arrCells[indexPath.row]
        
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType.celld, for: indexPath) as! SideMenuCell
//            cell.parent = self
            cell.prepareUI(cellType)
            cell.btnLogoutTap = {
               
            }
        cell.btnReviewTap = {
            let vc = ReviewsVC.instantiate(from: .Profile)
            vc.isFromSideMenu = true
            vc.userId = _user!.id.integerValue
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if cellType != .version {
            applyRoundedBackground(to: cell, at: indexPath, in: tableView)

        }
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType = arrSections[indexPath.section].arrCells[indexPath.row]
        if cellType == .logout {
            self.confirmLogout()
        }else{
//            self.dismiss(animated: false)
        }
        switch cellType {
           

        case .accSetting :
            let vc = ProfileVC.instantiate(from: .Profile)
//            vc.editType = EditProfileScreenType(cellType)!
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .wallet:
            let vc = ChangePasswordVC.instantiate(from: .Profile)
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .myRides:
            let vc = RideHistoryVC.instantiate(from: .Profile)
            vc.scrennType = .created //RideHistoryScreenType(rawValue: tag)!
            self.navigationController?.pushViewController(vc, animated: true)
        case .rideHistory:
            let vc = RideHistoryVC.instantiate(from: .Profile)
            vc.scrennType = .history //RideHistoryScreenType(rawValue: tag)!
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .subscription:
            let vc = SubscriptionVC.instantiate(from: .Profile)
            vc.isFromSideMenu = true
            self.navigationController?.pushViewController(vc, animated: true)
        case .document:
            let vc = IdVerificationListVC.instantiate(from: .Profile)
            self.navigationController?.pushViewController(vc, animated: true)
        case .carDetails:
            let vc = CarListVC.instantiate(from: .Profile)
            self.navigationController?.pushViewController(vc, animated: true)
        case .autoDetails:
            let vc = CarListVC.instantiate(from: .Profile)
            self.navigationController?.pushViewController(vc, animated: true)
        case .driverDetails:
            let vc = DriverListVC.instantiate(from: .Profile)
            self.navigationController?.pushViewController(vc, animated: true)
       
        case .insurance:
            let vc = CardListVC.instantiate(from: .Profile)
            vc.screenType = .list
            self.navigationController?.pushViewController(vc, animated: true)
        case .paymentMethods:
            let vc = CardListVC.instantiate(from: .Profile)
            vc.screenType = .list
            self.navigationController?.pushViewController(vc, animated: true)
            
//        case .bankDetails:
//            let vc = BankDetailsVC.instantiate(from: .Profile)
//            self.navigationController?.pushViewController(vc, animated: true)
            
        case .supportCenter:
            let vc = SupportTicketListVC.instantiate(from: .Profile)
            self.navigationController?.pushViewController(vc, animated: true)
//        case .logout:
            
            
        default:
            break
        }
    }
}

//MARK: - Notification Observers
extension SideMenuVC {
    
    func addObservers() {
        _defaultCenter.addObserver(self, selector: #selector(userProfileEdited(_:)), name: Notification.Name.userProfileUpdate, object: nil)
    }
    
    @objc func userProfileEdited(_ notification: NSNotification){
        _appDelegator.getUserProfile { [weak self] (succ, json) in
            guard let weakSelf = self else { return }
            if succ {
                weakSelf.tableView.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .none)
//                weakSelf.labelUserName?.text = _user?.fullName
//                weakSelf.imgVerifyBadgeRight.isHidden = !(_user?.userVerify ?? false)
//                if let profileImg = _user?.profilePic, !profileImg.isEmpty {
//                    weakSelf.imgUserProfile.loadFromUrlString(profileImg, placeholder: _userPlaceImage)
//                } else {
//                    weakSelf.imgUserProfile.image = _userPlaceImage
//                }
            }
        }
    }
    
}

// MARK: - API Calls
extension SideMenuVC {
    
    func logOutUser() {
        self.showCentralSpinner()
        _appDelegator.prepareForLogout { [weak self] (success, json) in
            guard let weakSelf = self else { return }
//            weakSelf.dismiss(animated: false)
            weakSelf.hideCentralSpinner()
        }
    }
    
}
