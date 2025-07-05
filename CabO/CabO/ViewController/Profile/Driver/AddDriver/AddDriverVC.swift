//
//  AddDriverVC.swift
//  CabO
//
//  Created by OctosMac on 03/07/25.
//

import UIKit

class AddDriverVC: ParentVC {
    /// Outlets
    @IBOutlet var heightConstTable: NSLayoutConstraint!
    
    /// Variables
    var arrCells: [AddDriverCellType] = [.title,.fname, .lname,.email,.mobile,.driveType, .btn]
    var arrDriveTYpe : [driveType] = [.car,.auto,.both]
    var data: AddDriverData = AddDriverData()
    var isEdit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        prepareUI()
    }
}
// MARK: - UI Methods
extension AddDriverVC {
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = AppColor.vwBgColor
        tableView.layer.cornerRadius = 19.0
        
        lblTitle?.text = isEdit ? "Edit" : "Add New Driver"
        
        registerCells()
        addKeyboardObserver()
        self.tableView.reloadData()

        delay(1.0) {

            DispatchQueue.main.async {
                let updatedContentHeight = self.tableView.contentSize.height
                print("Updated Table View Content Height after reload: \(updatedContentHeight)")
                self.heightConstTable.constant = updatedContentHeight + 10
            }
        }
    }
    func registerCells() {
        InputCell.prepareToRegisterCells(tableView)
        ButtonTableCell.prepareToRegisterCells(tableView)
    }
}
// MARK: - Actions
extension AddDriverVC {
    @IBAction func btnSubmitTap(_ sender: UIButton) {
        showSucessMsg()
        return
        let valid = isEdit ? data.isValidData() : data.isValidData()
        if valid.0 {
            
            addUpdateDriver()
        } else {
            ValidationToast.showStatusMessage(message: valid.1, yCord: _navigationHeight)
        }
    }
    @IBAction func btnCloseTap(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    func openIssueTypePicker(_ sender: AnyObject) {
        let reason = arrDriveTYpe
            let alert = UIAlertController.init(title: "Select Drive Type", message: nil, preferredStyle: .actionSheet)
            
            reason.forEach { type in
                let action = UIAlertAction(title: type.rawValue, style: .default) { [weak self] (action) in
                    guard let `self` = self else { return }
                    self.data.driveType  = type.rawValue
                    self.tableView.reloadData()
                }
                alert.addAction(action)
            }
            let cancel = UIAlertAction(title: "Close", style: .cancel, handler: nil)
            alert.addAction(cancel)
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = sender as? UIView
                popoverController.sourceRect = (sender as? UIView)!.bounds
            }
            //            if _appTheme != .system {
            //                alert.overrideUserInterfaceStyle = appTheme
            //            }
            self.present(alert, animated: true, completion: nil)
    }
}
extension AddDriverVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if cellType == .title {
            return UITableView.automaticDimension
        }
        return cellType.cellHeight
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrCells[indexPath.row]
        if cellType == .title || cellType == .btn {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType.identifier, for: indexPath) as! AddDriverCell
            cell.parent = self
            if cellType == .title {
                cell.labelTitle.text = isEdit ? "Edit" : "Add New Driver"
            }else{
                cell.btnSubmit.setTitle(isEdit ? "Update" : "Submit", for: .normal)
            }
            return cell
        }else{
            return tableView.dequeueReusableCell(withIdentifier: cellType.identifier, for: indexPath)
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? InputCell {
            cell.tag = indexPath.row
            cell.delegate = self
        }
//        else if let cell = cell as? ButtonTableCell {
//            cell.btn.setTitle(isEdit ? "Update" : "Submit", for: .normal)
//            cell.btnTapAction = { [ weak self] (_) in
//                guard let `self` = self else { return }
//                self.buttonSubmitTap()
//            }
//        }
    }
}
// MARK: - UIKeyboard Observer/
extension AddDriverVC {
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
        tableView.contentInset = UIEdgeInsets.zero
    }
}
// MARK: - API Calls
extension AddDriverVC {
    func addUpdateDriver() {
        showCentralSpinner()
        WebCall.call.addUpdateDrvier(param: data.addDeriverParam) { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            if status == 200{
                self.showSuccessMsg(data: json)
                self.showSucessMsg()
//                self.navigationController?.popViewController(animated: true)
            } else {
                self.showError(data: json)
            }
        }
    }
    private func showSucessMsg() {
        let title: String = "You have successfully done!"
        let message: String = "Once your driver login to the app we will sent notification."
        let success = SuccessPopUpView.initWithWindow(title, message,img: ("ic_success", nil), showSuccess: true)
        success.callBack = { [weak self] in
            guard let `self` = self else { return }
            self.dismiss(animated: true)
        }
    }
}
