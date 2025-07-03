//
//  ChangePasswordVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

// MARK: - ChangePasswordVC
class ChangePasswordVC: ParentVC {

    let arrCells: [ChangePassCells] = ChangePassCells.allCases    
    var data = ResetPasswordData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareU()
        addKeyboardObserver()
    }
}

//MARK: - UI Methods
extension ChangePasswordVC {
    
    func prepareU() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        registerCells()
        //Set UItable header
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as? UITableViewCell else {
            fatalError("Could not dequeue MyTableHeaderCell")
        }
        tableView.tableHeaderView = headerCell.contentView
        // Set the frame, only the height matters for tableHeaderView
        headerCell.contentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 118 * _widthRatio)
        
        // Very important: Tell the header view to lay out its subviews
        headerCell.contentView.layoutIfNeeded()
    }
    
    func registerCells() {
        InputCell.prepareToRegisterCells(tableView)
        ButtonTableCell.prepareToRegisterCells(tableView)
    }
}

// MARK: - Actions
extension ChangePasswordVC {
    
    func actionChangePassTap() {
        let valid = data.isValidChangePass()
        if valid.0 {
            changePassword()
        } else {
            ValidationToast.showStatusMessage(message: valid.1 ,yCord: _navigationHeight)
        }
    }
}

//MARK: - TableView Methods
extension ChangePasswordVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        return cellType.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: arrCells[indexPath.row].cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? InputCell {
            cell.tag = indexPath.row
            cell.delegate = self
            applyRoundedBackground(to: cell, at: indexPath, in: self.tableView , isBottomRadius: cellType == .conPass ? true : false)
        }
        else if let cell = cell as? ButtonTableCell {
            cell.btn.setTitle("Update", for: .normal)
            cell.btnTapAction = { [weak self] (_) in
                guard let `self` = self else { return }
                self.actionChangePassTap()
            }
        }
    }
}

// MARK: - UIKeyboard Observer
extension ChangePasswordVC {
    
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
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }
}

// MARK: - API Calls
extension ChangePasswordVC {
    
    private func changePassword() {
//        nprint(items: data.param)
        
        self.showCentralSpinner()
        WebCall.call.changePassword(param: data.changeParam) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.showSuccessMsg(data: json, yCord: _statusBarHeight)
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showError(data: json, yCord: _statusBarHeight)
            }
        }
    }
}
