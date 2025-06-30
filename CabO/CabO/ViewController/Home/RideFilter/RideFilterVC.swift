//
//  RideFilterVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class RideFilterVC: ParentVC {
    
    /// Variables
    let arrCells: [RideFilterCellType] = [.datePicker, .rangeMeter, .seatRequired, .ridePrefs, .tripFilter]
    var data: FindRideModel = FindRideModel()
    var prefs: [RidePrefModel] = []

    var filterCallBack: ((FindRideModel) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

// MARK: - UI Methods
extension RideFilterVC {
    
    func prepareUI() {
        
        prefs = _arrPrefs.compactMap({$0.copy()})
        let lug = RidePrefModel(0, "Luggage", "", 0)
        lug.img = UIImage(named: "ic_luggage_pref")!
        prefs.append(lug)
        
        
        tableView.contentInset = UIEdgeInsets(top: (12 * _widthRatio), left: 0, bottom: 24, right: 0)
        registerCells()
        tableView.reloadData()
    }
    
    func registerCells() {
        TitleTVC.prepareToRegisterCells(tableView)
        DualInputCell.prepareToRegisterCells(tableView)
        DatePickerCell.prepareToRegisterCells(tableView)
        AvailableSeatsCell.prepareToRegisterCells(tableView)
        CreateRidePreferenceCell.prepareToRegisterCells(tableView)
    }
}

// MARK: - Actions
extension RideFilterVC {
    
    @IBAction func btnResetTap(_ sender: UIButton) {
        data.seatReq = nil
        data.arrPrefs.removeAll()
        data.isNonStopRide = nil
        data.range = nil
        filterCallBack?(data)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnApplyFilterTap(_ sender: UIButton) {
        filterCallBack?(data)
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - TableView Methods
extension RideFilterVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if cellType == .ridePrefs {
            let data = prefs
            let columns: CGFloat = DeviceType.iPad ? 3 : 2
            
            if data.isEmpty {
               return 0
            }
            else {
                let rows = Int(ceil(Double(data.count) / columns))
                let height = data.isEmpty ? 0 : (CreateRidePreferenceCell.prefHeight * CGFloat(rows)) + CGFloat((4 * _widthRatio) * CGFloat(rows))
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
        if let cell = cell as? DatePickerCell {
            cell.lblTitle.text = "Date"
            cell.lblTitle.font = AppFont.fontWithName(.mediumFont, size: 18 * _fontRatio)
            cell.datePicker.date = data.rideDate
            cell.datePicker.datePickerMode = .date
            cell.datePicker.minimumDate = Date()
            cell.datePicker.maximumDate = Date().adding(.day, value: _appDelegator.config.createRideMaxDays)
            
            cell.dateChanges = { [weak self] (date) in
                guard let self = self else { return }
                self.data.rideDate = date
            }
        }
        else if let cell = cell as? AvailableSeatsCell {
            cell.arrSeats = Array.init(repeating: 1, count: _appDelegator.config.createRideSeatLimit)
            cell.prepareUI("Seats required", hideSubTitle: true, data.seatReq)
            cell.seatSelectionCallBack = { [weak self] (seat) in
                guard let self = self else { return }
                self.data.seatReq = seat
            }
        }
        else if let cell = cell as? CreateRidePreferenceCell {
            cell.arrPrefs = prefs
            cell.prepareUI("Preferences", hideSubTitle: true, selectedPref: data.arrPrefs.compactMap({$0.id}))
            cell.selectionCallBack = { [weak self] (pref) in
                guard let self = self else { return }
                if self.data.arrPrefs.contains(pref) {
                    self.data.arrPrefs.remove(pref)
                } else {
                    self.data.arrPrefs.append(pref)
                }
            }
        }
        else if let cell = cell as? RangeMeterCell {
            if let range = data.range {
                cell.setValue(range)
            } else {
                cell.setValue(Float(_appDelegator.config.range_min!))
            }
            cell.action_slider_changes = { [weak self] (range) in
                guard let self = self else { return }
                self.data.range = range
            }
            cell.action_info = { [weak self] (btn) in
                guard let self = self else { return }
                self.openPopOver(view: btn, msg: "Use this range meter to discover rides available within your selected distance.")
            }
        }
        else if let cell = cell as? RideFilterCell {
            cell.prepareUI(data.isNonStopRide)
            cell.action_stopover_selection = { [weak self] (selection) in
                guard let self = self else { return }
                self.data.isNonStopRide = selection
            }
        }
    }
}
