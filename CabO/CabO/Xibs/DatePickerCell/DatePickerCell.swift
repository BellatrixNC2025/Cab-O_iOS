//
//  DatePickerCell.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class DatePickerCell: ConstrainedTableViewCell {

    static let identifier: String = "datePickerCell"
    static let height: CGFloat = 44 * _widthRatio
    
    /// Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    /// Variables
    var dateChanges: ((Date) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.tintColor = .systemBlue
        lblTitle?.font = AppFont.fontWithName(.regular, size: 14 * _fontRatio)
    }
    
    /// Date Change action
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        dateChanges?(sender.date)
    }
}

//MARK: - Register Cell
extension DatePickerCell {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: identifier)
    }
}
