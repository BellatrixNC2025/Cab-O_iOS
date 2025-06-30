//
//  FindRideVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class FindRideVC: ParentVC {
    
    /// Variables
    var arrCells: [CreateRideCellType] = [.startDest, .date]
    var data = FindRideModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView?.reloadData()
    }
}

// MARK: - UI Methods
extension FindRideVC {
    
    func prepareUI() {
        
        tableView.contentInset = UIEdgeInsets(top: (8 * _widthRatio), left: 0, bottom: 50, right: 0)
        registerCells()
    }
    
    func registerCells() {
        StartDestPickerCell.prepareToRegisterCells(tableView)
        DatePickerCell.prepareToRegisterCells(tableView)
    }
}

// MARK: - Actions
extension FindRideVC {
    
    func openLocationPickerFor(_ tag: Int) {
        let vc = SearchVC.instantiate(from: .Home)
        vc.selectionBlock = { [weak self] (address) in
            guard let self = self else { return }
            if tag == 0 {
                if let dest = self.data.dest, dest.formatedAddress == address.formatedAddress {
                    ValidationToast.showStatusMessage(message: "Selected address is already used as destination", yCord: _navigationHeight)
                } else {
                    self.data.start = address
                }
            } else {
                if let source = self.data.start, source.formatedAddress == address.formatedAddress {
                    ValidationToast.showStatusMessage(message: "Selected address is already used as source location", yCord: _navigationHeight)
                } else {
                    self.data.dest = address
                }
            }
            self.tableView.reloadData()
        }
        self.present(vc, animated: true)
    }
    
    @IBAction func btnSearchRideTap(_ sender: UIButton) {
        let valid = data.isValidData()
        if valid.0 {
            let vc = FindRideListVC.instantiate(from: .Home)
            vc.data = self.data
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            ValidationToast.showStatusMessage(message: valid.1, yCord: _navigationHeight)
        }
    }
}

// MARK: - TableView Methods
extension FindRideVC : UITableViewDelegate, UITableViewDataSource {
    
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
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? StartDestPickerCell {
            cell.delegate = self
            cell.locationPickerTap = { [weak self] (tag) in
                guard let `self` = self else { return }
                self.openLocationPickerFor(tag)
            }
        }
        else if let cell = cell as? DatePickerCell {
            cell.lblTitle.text = cellType.title
            cell.lblTitle.font = AppFont.fontWithName(.mediumFont, size: 18 * _fontRatio)
            cell.datePicker.datePickerMode = cellType.datePickerMode
            
            cell.datePicker.minimumDate = Date()
            cell.datePicker.maximumDate = Date().adding(.day, value: _appDelegator.config.createRideMaxDays)
            
            cell.datePicker.date = data.rideDate
            cell.dateChanges = { [weak self] (date) in
                guard let self = self else { return }
                self.data.rideDate = date
            }
        }
    }
}
