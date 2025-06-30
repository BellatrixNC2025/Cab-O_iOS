//
//  ForgotPasswordVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

//MARK: - ForgotPasswordVC
class ForgotPasswordVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var topHeaderView: UIView!
    @IBOutlet weak var imgBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var vectorHeight: NSLayoutConstraint!
    
    /// Variables
    var tableHeaderHeight:CGFloat = _screenSize.height / 3
    var arrCells: [ForgotPassCells] = ForgotPassCells.allCases
    var data = ResetPasswordData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareU()
        addKeyboardObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

//MARK: - UI Methods
extension ForgotPasswordVC {
    
    func prepareU() {
        tableView.contentInset = UIEdgeInsets(top: _screenSize.height / 3, left: 0, bottom: 0, right: 0)
//        imgBottomConstraint.constant = (DeviceType.iPad ? 24 : 0) * _widthRatio
        vectorHeight.constant = 164 * _widthRatio
        registerCells()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let headerRect = CGRect(x: 0, y: -(self.tableHeaderHeight + (30*_widthRatio)), width: self.tableView.bounds.width, height: self.tableHeaderHeight + _statusBarHeight)
            self.topHeaderView!.frame = headerRect
        }
        prepareTblHeader()
    }
    
    func prepareTblHeader() {
        tableView.tableHeaderView = nil
        topHeaderView.clipsToBounds = false
        topHeaderView.layer.zPosition = -1
        tableView.addSubview(topHeaderView!)
//        tableView.contentInset = UIEdgeInsets(top: (tableHeaderHeight - _statusBarHeight), left: 0, bottom: 0, right: 0)
//        tableView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    func registerCells() {
        TitleTVC.prepareToRegisterCells(tableView)
        InputCell.prepareToRegisterCells(tableView)
        ButtonTableCell.prepareToRegisterCells(tableView)
    }
}

// MARK: - Actions
extension ForgotPasswordVC {
    
    func buttonSendTap() {
//        let valid = data.isValidForgotData()
//        if valid.0 {
//            sendOtp()
//        } else {
//            ValidationToast.showStatusMessage(message: valid.1)
//        }
        let vc = VerifyOtpVC.instantiate(from: .Auth)
        vc.emailMobile = "+91 94234 23457"
        vc.screenType = self.data.emailMobile.isNumber ? .forgotMobile : .forgotEmail
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - TableView Methods
extension ForgotPasswordVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if cellType == .title {
            return TitleTVC.height(for: cellType.inputTitle, width: _screenSize.width - (40 * _widthRatio), font: AppFont.fontWithName(.bold, size: 20 * _fontRatio)) + 5 * _widthRatio
        } else if cellType == .desc {
            return TitleTVC.height(for: cellType.inputTitle, width: _screenSize.width - (40 * _widthRatio), font: AppFont.fontWithName(.mediumFont, size: 14 * _fontRatio)) + 5
        }
        return arrCells[indexPath.row].cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: arrCells[indexPath.row].cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? TitleTVC {
            if cellType == .title {
                cell.prepareUI(cellType.inputTitle, AppFont.fontWithName(.bold, size: 20 * _fontRatio), clr: AppColor.primaryTextDark)
            } else {
                cell.prepareUI(cellType.inputTitle, AppFont.fontWithName(.mediumFont, size: 16 * _fontRatio), clr: AppColor.primaryTextDark)
                
            }
            applyRoundedBackground(to: cell, at: indexPath, in: self.tableView)
        }
        if let cell = cell as? InputCell {
            cell.tag = indexPath.row
            cell.delegate = self
            applyRoundedBackground(to: cell, at: indexPath, in: self.tableView, isBottomRadius: true)
        }
        else if let cell = cell as? ButtonTableCell {
            cell.btn.setTitle("Submit", for: .normal)
            cell.btnTapAction = { [weak self] (_) in
                guard let `self` = self else { return }
                self.buttonSendTap()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
//        var headerRect = CGRect(x: 0, y: -tableHeaderHeight, width: tableView.bounds.width, height: tableHeaderHeight + _statusBarHeight)
//        if tableView.contentOffset.y < -tableHeaderHeight {
//            headerRect.origin.y = tableView.contentOffset.y
//            headerRect.size.height = -tableView.contentOffset.y + _statusBarHeight
//        }
//        topHeaderView!.frame = headerRect
    }
}

// MARK: - UIKeyboard Observer
extension ForgotPasswordVC {
    
    func addKeyboardObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 10, right: 0)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification){
        guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        tableView.contentInset = UIEdgeInsets(top: _screenSize.height / 3, left: 0, bottom: 0, right: 0)
    }
}

// MARK: - API Call
extension ForgotPasswordVC {
    
    func sendOtp() {
        var param: [String: Any] = [:]
        param["source"] = data.emailMobile.isNumber ? "forgot_mobile" : "forgot_email"
        param["sourceid"] = data.emailMobile
        
        let cell = tableViewCell(index: arrCells.firstIndex(of: .signin)!) as! ButtonTableCell
        self.showSpinnerIn(container: cell.bgView, control: cell.btn, isCenter: true)
        
        WebCall.call.resendOtp(param: param) { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideSpinnerIn(container: cell.bgView, control: cell.btn)
            if status == 200 {
                let vc = VerifyOtpVC.instantiate(from: .Auth)
                vc.emailMobile = self.data.emailMobile
                vc.screenType = self.data.emailMobile.isNumber ? .forgotMobile : .forgotEmail
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.showError(data: json, yCord: _statusBarHeight)
            }
        }
    }
}
