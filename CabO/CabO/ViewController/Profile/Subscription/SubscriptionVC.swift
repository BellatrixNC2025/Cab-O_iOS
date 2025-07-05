//
//  SubscriptionVC.swift
//  CabO
//
//  Created by OctosMac on 28/06/25.
//

import UIKit

class SubscriptionVC: ParentVC {
    var arrData: [SubscriptionPlans] = []
    var isFromSideMenu : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        prepareUI()
        addObservers()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
//MARK: - UI Methoods
extension SubscriptionVC{
    func prepareUI() {
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
        registerCells()
        getSubscriptionPlan()
    }
    
    func registerCells() {
        TitleTVC.prepareToRegisterCells(tableView)
    }
}
//MARK: - Button Actions
extension SubscriptionVC {
    func subscribePlan() {
        showConfirmationPopUpView("Confirmation!", "Are you sure you want to subscribe this plan?", btns: [.no, .yes]) { btnType in
            if btnType == .yes {
//                self.logOutUser()
            }
        }
    }
    @IBAction func button_backTap(_ sender: UIButton) {
        if !self.isFromSideMenu{
            self.showCentralSpinner()
            if _appDelegator.isUserLoggedIn() {
                _appDelegator.prepareForLogout { [weak self] (success, json) in
                    guard let `self` = self else { return }
                    self.hideCentralSpinner()
                }
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
//MARK: - TableView Methods
extension SubscriptionVC: UITableViewDelegate, UITableViewDataSource  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //isFromSideMenu ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFromSideMenu {
            return arrData.count
        }
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //        let section = arrSections[indexPath.section]
//        let cellType = arrSections[indexPath.section].arrCells[indexPath.row]
//        if cellType == .userDetails {
            return UITableView.automaticDimension
//        }
//        return 120 * _widthRatio
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
//        let cellType = arrSections[indexPath.section].arrCells[indexPath.row]
//        if indexPath.row == 0 && isFromSideMenu {
//            let cell = tableView.dequeueReusableCell(withIdentifier: TitleTVC.identifier, for: indexPath) as! TitleTVC
//            cell.prepareUI(indexPath.section == 0 ? "Current Plan" : "Other Plan", AppFont.fontWithName(.bold, size: 14 * _fontRatio), clr: AppColor.primaryTextDark)
//            cell.lblTitle.textAlignment = .left
//            applyRoundedBackground(to: cell, at: indexPath, in: tableView)
//            return cell
//        }
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionCell", for: indexPath) as! SubscriptionCell
            let plan = arrData[indexPath.row ]
            cell.prepareUI(plan)

            cell.btnSubscribeTap = {
                let vc = CardListVC.instantiate(from: .Profile)
                vc.screenType = .subscription
                vc.isFromSideMenu = self.isFromSideMenu
                vc.plan_id = plan.id
                self.navigationController?.pushViewController(vc, animated: true)
            }
            applyRoundedBackground(to: cell, at: indexPath, in: tableView)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveSubscriptionCell", for: indexPath) as! SubscriptionCell
            
            //            cell.parent = self
            //        cell.prepareUI(cellType)
            //        cell.btnLogoutTap = {
            //
            //        }
            //        cell.btnReviewTap = {
            //            let vc = ReviewsVC.instantiate(from: .Profile)
            //            vc.isFromSideMenu = true
            //            vc.userId = _user!.id.integerValue
            //            self.navigationController?.pushViewController(vc, animated: true)
            //        }
            applyRoundedBackground(to: cell, at: indexPath, in: tableView)
            return cell
        }
    }
}
//MARK: - Notification Observers
extension SubscriptionVC {
    
    func addObservers() {
        _defaultCenter.addObserver(self, selector: #selector(userProfileEdited(_:)), name: Notification.Name.userProfileUpdate, object: nil)
    }
    
    @objc func userProfileEdited(_ notification: NSNotification){
        _appDelegator.getUserProfile { [weak self] (succ, json) in
            guard let weakSelf = self else { return }
            if succ {
            }
        }
    }
    
}
// MARK: - API Calls
extension SubscriptionVC {
    
    func getSubscriptionPlan() {
        let param = ["status": DocStatus.verified.apiValue]
        if !refresh.isRefreshing {
            showCentralSpinner()
        }
        WebCall.call.getSubscriptionList { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200, let dData = json as? NSDictionary, let data = dData["data"] as? NSDictionary {
                let trial = data.getBooleanValue(key: "is_free_plan_taken")
                var arrPlans: [SubscriptionPlans] = []
                if let subPlans = data["subscription_plan"] as? [NSDictionary] {
                    subPlans.forEach { plan in
                        arrPlans.append(SubscriptionPlans(plan))
                    }
                }
                self.arrData = arrPlans
                self.tableView.reloadData()
            } else {
                self.showError(data: json)
            }
        }
    }
    
}
