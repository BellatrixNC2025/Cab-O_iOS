//
//  BankDetailsVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

// MARK: - BankDetailsVC
class BankDetailsVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnView: UIView!
    @IBOutlet weak var ViewButtonAdd: UIView!
    
    /// Variables
    var arrCells: [StripeDetailsCellType] = StripeDetailsCellType.allCases
    var stripeData: StripeDetails!
    var stripeUrl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewButtonAdd.isHidden = true
        
        prepareUI()
        getStripeDetails()
    }
}

// MARK: - UI Methods
extension BankDetailsVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: (8 * _heightRatio), left: 0, bottom: (24 * _heightRatio), right: 0)
        registerCells()
    }
    
    func registerCells() {
        NoDataCell.prepareToRegisterCells(tableView)
    }
}

// MARK: - Actions
extension BankDetailsVC {
    
    @IBAction func btn_add_tap(_ sender: UIButton) {
        getStripeDetails(true, isEdit: true, showCentralSpinner: false)
    }
    
    func openStripeForm() {
        let vc = CmsVC.instantiate(from: .CMS)
        vc.screenType = .stripe
        vc.stripeUrl = stripeUrl
        vc.isStripeFilled = !self.stripeData.stripeId.isEmpty
        vc.block_bankDetailSuccess = { [weak self] in
            guard let self = self else { return }
            self.getStripeDetails(false)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - TableView Methods
extension BankDetailsVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stripeData == nil ? 0 : stripeData.stripeId.isEmpty ? 1 : arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if stripeData.stripeId.isEmpty {
            return tableView.frame.height
        } else {
            let cellType = arrCells[indexPath.row]
            if cellType == .business && stripeData.business_name.isEmpty {
                return 0
            }
            var height: CGFloat = 0
            height += cellType.title.heightWithConstrainedWidth(width: _screenSize.width - (40 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio))
            height += stripeData.getValue(cellType).heightWithConstrainedWidth(width: _screenSize.width - (40 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio))

            return height + (24 * _heightRatio)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if stripeData.stripeId.isEmpty {
            return tableView.dequeueReusableCell(withIdentifier: NoDataCell.identifier, for: indexPath)
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "bankDetail", for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? NoDataCell {
            cell.prepareUI(title: "Bank details not added", subTitle: "")
        }
        else if let cell = cell as? StripeDetailCell {
            cell.title.text = cellType.title
            cell.desc.text = stripeData.getValue(cellType)
        }
    }
}

// MARK: - API Call
extension BankDetailsVC {
    
    func getStripeDetails(_ openStripeForm: Bool = true, isEdit: Bool = false, showCentralSpinner: Bool = true) {
        if showCentralSpinner {
            self.showCentralSpinner()
        }
        showSpinnerIn(container: self.btnView, control: self.btnAdd, isCenter: true)
        WebCall.call.getStripeDetails { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            self.hideSpinnerIn(container: self.btnView, control: self.btnAdd)
            
            if status == 200, let dict = json as? NSDictionary{
                if let data = dict["data"] as? NSDictionary  {
                    self.stripeUrl = data.getStringValue(key: "create_link")
                    self.stripeData = StripeDetails(data)
                    self.tableView.reloadData()
                    let cells = self.tableView.visibleCells(in: 0)
                    UIView.animate(views: cells, animations: [self.tableLoadAnimation])
                    
                    self.btnAdd.setTitle(self.stripeData.stripeId.isEmpty ? "Add bank details" : "Edit bank details", for: .normal)
                    self.ViewButtonAdd.isHidden = false
                    
                    if openStripeForm && self.stripeData.stripeId.isEmpty {
                        self.openStripeForm()
                    } else if isEdit {
                        self.openStripeForm()
                    }
                }
            }
        }
    }
}


