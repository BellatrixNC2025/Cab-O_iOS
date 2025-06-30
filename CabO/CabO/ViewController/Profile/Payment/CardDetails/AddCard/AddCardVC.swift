//
//  AddCardVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import StripePayments

// MARK: - AddCardVC
class AddCardVC: ParentVC {
    
    /// Variables
    var arrCells: [AddCardCellType] = AddCardCellType.allCases
    var data = AddCardData()
    var isFirstCard: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        addKeyboardObserver()
    }
}

// MARK: - UI Methods
extension AddCardVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: (24 * _heightRatio), right: 0)
        
        data.isDefault = isFirstCard ? true : false
        registerCells()
        tableView.reloadData()
    }
    
    func registerCells() {
        InputCell.prepareToRegisterCells(tableView)
        DualInputCell.prepareToRegisterCells(tableView)
        ButtonTableCell.prepareToRegisterCells(tableView)
    }
}

// MARK: - Actions
extension AddCardVC {
    
    func action_buttonSubmitTap(_ sender: UIButton) {
        let valid = data.isValid()
        if valid.0 {
            self.createCardToken { [weak self] (success, token, onjCard, error) in
                guard let self = self else { return }
                if success {
                    self.addCardAPI(token!)
                } else {
                    ValidationToast.showStatusMessage(message: error?.localizedDescription ?? "Somethign went wrong", yCord: _navigationHeight)
                }
            }
        } else {
            ValidationToast.showStatusMessage(message: valid.1, yCord: _navigationHeight)
        }
    }
}

// MARK: - TableView Methods
extension AddCardVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        return cellType.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrCells[indexPath.row]
        return tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? InputCell {
            cell.tag = indexPath.row
            cell.delegate = self
        }
        else if let cell = cell as? DualInputCell {
            cell.tag = indexPath.row
            cell.delegate = self
        }
        else if let cell = cell as? AddCardCell {
            cell.btnDefault.isSelected = data.isDefault
            cell.action_default = { [weak self] in
                guard let self = self else { return }
                if isFirstCard {
                    ValidationToast.showStatusMessage(message: "You don't have any other card yet", yCord: _navigationHeight)
                } else {
                    cell.btnDefault.isSelected.toggle()
                    self.data.isDefault.toggle()
                }
            }
        }
        else if let cell = cell as? ButtonTableCell {
            cell.btn.setTitle("Submit", for: .normal)
            cell.btnTapAction = { [weak self] (sender) in
                guard let weakSelf = self else { return }
                weakSelf.action_buttonSubmitTap(sender)
            }
        }
    }
}

// MARK: - UIKeyboard Observer
extension AddCardVC {
    
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

// MARK: - API Call
extension AddCardVC {
    
    func addCardAPI(_ token: String) {
        var param: [String: Any] = [:]
        param["stripeToken"] = token
        param["is_default"] = data.isDefault ? 1 : 0
        param["card_number"] = data.cardNumber.suffix(4)
        
        showCentralSpinner()
        WebCall.call.addCardDetails(param: param) { [weak self] (json, status) in
            guard let weakSelf = self else { return }
            weakSelf.hideCentralSpinner()
            
            if status == 200 {
                weakSelf.showSuccessMsg(data: json, yCord: _navigationHeight)
                _defaultCenter.post(name: Notification.Name.cardListUpdate, object: nil)
                weakSelf.navigationController?.popViewController(animated: true)
            } else {
                weakSelf.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    func createCardToken(completionHandler: ((_ success:Bool,_ token:String?,_ onjCard : STPCard?,_ error : Error?) -> ())!) {
        let card: STPCardParams = STPCardParams()
        card.number = data.cardNumber
        card.name = data.cardHolderName
        card.expMonth = String(data.expiryDate.prefix(2)).toUInt()!
        card.expYear = String(data.expiryDate.suffix(2)).toUInt()!
        card.cvc = data.cvv
        
        showCentralSpinner()
        STPAPIClient.shared.createToken(withCard: card) { [weak self] (token, error) -> Void in
            guard let weakSelf = self else { return }
            weakSelf.hideCentralSpinner()
            if(error != nil){
                NSLog("error :- %@", (error?.localizedDescription)!)
                completionHandler(false,"",nil,error)
            }
            else{
                completionHandler(true,token?.tokenId,(token?.card)!,error)
            }
        }
    }
}
