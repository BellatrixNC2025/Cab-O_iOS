//
//  CreateRidePreferenceCell.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class CreateRideLuggageCell: ConstrainedTableViewCell {

    static var identifier: String = "createRideLuggageCell"
    static var addHeight: CGFloat = (68 + 44) * _widthRatio
    
    /// Outlets
    @IBOutlet weak var tableV: UITableView!
    
    /// Variables
    var arrLuggage: [RidePrefModel]! = [] {
        didSet {
            tableV.reloadData()
        }
    }
    var selectedPref: [RidePrefModel] = []
    var selectionCallBack: ((RidePrefModel) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CreateRideLuggageTableCell.prepareToRegisterCells(tableV)
    }
}

// MARK: - TableView Methods
extension CreateRideLuggageCell : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrLuggage.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CreateRideLuggageTableCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: CreateRideLuggageTableCell.identifier, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? CreateRideLuggageTableCell {
            let lugg = arrLuggage[indexPath.row]
            cell.prepareUI(lugg, selected: lugg.count > 0)
            
            cell.selectionCallBack = { [weak self] in
                guard let self = self else { return }
                self.selectionCallBack?(lugg)
                if self.selectedPref.contains(lugg) {
                    lugg.count = 0
                    self.selectedPref.remove(lugg)
                } else {
                    lugg.count += 1
                    self.selectedPref.append(lugg)
                }
                self.tableV.reloadRows(at: [indexPath], with: .none)
            }
            
            cell.plusMinusCallBack = { [weak self] (tag) in
                guard let self = self else { return }
                if tag == 0 {
                    if lugg.count != 0 {
                        lugg.count -= 1
                    }
                    if lugg.count == 0 && self.selectedPref.contains(lugg) {
                        self.selectionCallBack?(lugg)
                        self.selectedPref.remove(lugg)
                    }
                } else {
                    if lugg.count == 0 {
                        self.selectionCallBack?(lugg)
                        self.selectedPref.append(lugg)
                    }
                    lugg.count += 1
                }
                self.tableV.reloadRows(at: [indexPath], with: .none)
                cell.lblCount.text = "\(lugg.count)"
            }
        }
    }
}


//MARK: - Register Cell
extension CreateRideLuggageCell {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "CreateRideLuggageCell", bundle: nil), forCellReuseIdentifier: identifier)
    }
}
