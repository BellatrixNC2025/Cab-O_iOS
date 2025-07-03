//
//  ResetPasswordVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

// MARK: - ResetPasswordVC
class ResetPasswordVC: ParentVC {
    @IBOutlet weak var topHeaderView: UIView!
    var tableHeaderHeight:CGFloat = _screenSize.height / 3.5
    var arrCells: [ResetPassCells] = ResetPassCells.allCases
    var data = ResetPasswordData()
    var userId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareU()
        addKeyboardObserver()
    }
}

//MARK: - UI Methods
extension ResetPasswordVC {
    
    func prepareU() {
        tableView.contentInset = UIEdgeInsets(top: (_screenSize.height / 3.5), left: 0, bottom: 0, right: 0)
        
        registerCells()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let headerRect = CGRect(x: 0, y: -(self.tableHeaderHeight), width: self.tableView.bounds.width, height: (self.tableHeaderHeight ))
            self.topHeaderView!.backgroundColor = .clear
            self.topHeaderView!.frame = headerRect
        }
        prepareTblHeader()
    }
    func prepareTblHeader() {
        tableView.tableHeaderView = nil
        topHeaderView.clipsToBounds = false
        topHeaderView.layer.zPosition = -1
        tableView.addSubview(topHeaderView!)
        tableView.contentInset = UIEdgeInsets(top: (tableHeaderHeight), left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: 0)
    }
    func registerCells() {
        TitleTVC.prepareToRegisterCells(tableView)
        InputCell.prepareToRegisterCells(tableView)
        ButtonTableCell.prepareToRegisterCells(tableView)
    }
}

// MARK: - Actions
extension ResetPasswordVC {
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popToViewController(ofClass: ForgotPasswordVC.self, animated: true)
    }
    
    func buttonResetTap() {
        let valid = data.isValidResetPass()
        if valid.0 {
            resetPassword()
        } else {
            ValidationToast.showStatusMessage(message: valid.1)
        }
    }
}

//MARK: - TableView Methods
extension ResetPasswordVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if cellType == .title {
            return TitleTVC.height(for: cellType.inputTitle, width: _screenSize.width - (60 * _widthRatio), font: AppFont.fontWithName(.mediumFont, size: 16 * _fontRatio)) + 8
        }
        return arrCells[indexPath.row].cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: arrCells[indexPath.row].cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? TitleTVC {
            cell.prepareUI(cellType.inputTitle, AppFont.fontWithName(.mediumFont, size: 16 * _fontRatio), clr: AppColor.primaryTextDark)
            applyRoundedBackground(to: cell, at: indexPath, in: tableView, isTopRadius: true)
        }
        else if let cell = cell as? InputCell {
            cell.tag = indexPath.row
            cell.delegate = self
            if cellType == .pass {
                applyRoundedBackground(to: cell, at: indexPath, in: tableView)
            }else{
                applyRoundedBackground(to: cell, at: indexPath, in: tableView, isBottomRadius: true)
            }
        }
        else if let cell = cell as? ButtonTableCell {
            cell.btn.setTitle("Submit", for: .normal)
            cell.btnTapAction = { [weak self] (_) in
                guard let `self` = self else { return }
                self.buttonResetTap()
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
extension ResetPasswordVC {
    
    func addKeyboardObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
                tableView.contentInset = UIEdgeInsets(top: _screenSize.height/2, left: 0, bottom: keyboardSize.height + 10, right: 0)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification){
        guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }
}

// MARK: - API Calls
extension ResetPasswordVC {
    
    private func resetPassword() {
        
        var param: [String: Any] = [:]
        param["user_id"] = userId
        param["new_password"] = data.newPass
        
        let cell = tableViewCell(index: arrCells.firstIndex(of: .btn)!) as! ButtonTableCell
        self.showSpinnerIn(container: cell.bgView, control: cell.btn, isCenter: true)
        
        WebCall.call.resetPassword(param: param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideSpinnerIn(container: cell.bgView, control: cell.btn)
            
            if status == 200 {
                self.showSuccessMsg(data: json)
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                self.showError(data: json, yCord: _statusBarHeight)
            }
        }
    }
}
