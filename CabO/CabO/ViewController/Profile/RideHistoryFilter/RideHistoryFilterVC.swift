//
//  RideHistoryFilter.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class RideHistoryFilterVC: ParentVC {
    
    /// Variables
    var arrStatus: [RideStatus] = []
    var arrCells: [RideHistoryFilterCellType] = [.start, .dest, .date]
    var data = RideHistoryFilterModel()
    var isRequestFilter: Bool = false
    var isPast: Bool = false
    var screenType: RideHistoryScreenType!
    
    var filterCallBack: ((RideHistoryFilterModel) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

// MARK: - UI Methods
extension RideHistoryFilterVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 24, right: 0)
        if isRequestFilter {
            arrCells.remove(.status)
            tableView.reloadData()
        }
        if screenType != .requests {
            arrCells.append(.status)
        }
        tableView.reloadData()
        prepareStatusFilter()
        registerCells()
    }
    
    func prepareStatusFilter() {
        if screenType == .created {
            if isPast {
                arrStatus = [.cancelled, .autoCancelled, .completed]
            } else {
                arrStatus = [.pending, .started]
            }
        } else if screenType == .booked {
            if isPast {
                arrStatus = [.cancelled, .rejected, .completed]
            } else {
                arrStatus = [.pending, .accepted, .ontheway, .started]
            }
        }
        tableView.reloadData()
    }
    
    func registerCells() {
        RideFilterStatusCell.prepareToRegisterCells(tableView)
        InputCell.prepareToRegisterCells(tableView)
    }
}

// MARK: - Actions
extension RideHistoryFilterVC {
    
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
    
    @IBAction func btn_back_tap(_ sender: UIButton) {
        data.reset()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_reset_tap(_ sender: UIButton) {
        data.reset()
        filterCallBack?(data)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_apply(_ sender: UIButton) {
        filterCallBack?(data)
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - TableView Methods
extension RideHistoryFilterVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if cellType == .status {
            let data = arrStatus
            let columns: CGFloat = DeviceType.iPad ? 3 : 2
            
            if data.isEmpty {
                return 0
            }
            else {
                let rows = Int(ceil(Double(data.count) / columns))
                let height = data.isEmpty ? 0 : (RideFilterStatusCell.prefHeight * CGFloat(rows)) + CGFloat(4 * rows)
                return height + cellType.cellHeight
            }
        }
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
        } else if let cell = cell as? RideFilterStatusCell {
            cell.arrStatus = arrStatus
            cell.prepareUI("Status", isMultiSelect: false, selectedStatus: self.data.status, arrSelectedStatus: [])
            cell.selectionCallBack = { [weak self] (stats) in
                guard let self = self else { return }
                self.data.status = stats
            }
        }
    }
}
