//
//  StartDestPickerCell.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class StartDestPickerCell: ConstrainedTableViewCell {
    
    static let identifier: String = "StartDestPickerCell"
    static let height: CGFloat = 164 * _widthRatio
    
    /// Outlets
    @IBOutlet weak var btnStartLoc: UIButton!
    @IBOutlet weak var btnDestLoc: UIButton!
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var lblDest: UILabel!
    @IBOutlet weak var lblStartLocation: UILabel!
    @IBOutlet weak var lblDestLocation: UILabel!
    @IBOutlet weak var btnSwap: UIButton!
    
    /// Variables
    var locationPickerTap:((Int) -> ())?
    weak var delegate: ParentVC! {
        didSet {
            prepareUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblStartLocation.isHidden = true
        lblDestLocation.isHidden = true
    }
}

// MARK: - UI Methods
extension StartDestPickerCell {
    
    func prepareUI() {
        lblStart.text = "Source"
        lblDest.text = "Destination"
        if let parent = delegate as? CreateRideVC {
            prepareCreateRideUI(parent.data)
        }
        else if let parent = delegate as? FindRideVC {
            prepareFindRideUI(parent.data)
        }
        else if let parent = delegate as? PostRequestVC {
            preparePostRequestUI(parent.data)
        }
    }
    
    func prepareCreateRideUI(_ data: CreateRideData) {
        lblStartLocation.isHidden = data.start == nil
        lblDestLocation.isHidden = data.dest == nil
        if let source = data.start {
            lblStartLocation.text = source.customAddress
        }
        if let dest = data.dest {
            lblDestLocation.text = dest.customAddress
        }
    }
    
    func prepareFindRideUI(_ data: FindRideModel) {
        lblStart.text = "From"
        lblDest.text = "To"
        
        lblStartLocation.isHidden = data.start == nil
        lblDestLocation.isHidden = data.dest == nil
        if let start = data.start {
            lblStartLocation.text = start.customAddress
        }
        if let dest = data.dest {
            lblDestLocation.text = dest.customAddress
        }
    }
    
    func preparePostRequestUI(_ data: PostRequestModel) {
        lblStartLocation.isHidden = data.start == nil
        lblDestLocation.isHidden = data.dest == nil
        if let start = data.start {
            lblStartLocation.text = start.customAddress
        }
        if let dest = data.dest {
            lblDestLocation.text = dest.customAddress
        }
    }
}

// MARK: - Button Actions
extension StartDestPickerCell {
    
    @IBAction func action_btnStartLocTap(_ sender: UIButton) {
        locationPickerTap?(sender.tag)
    }
    
    @IBAction func action_btnDestLocTap(_ sender: UIButton) {
        locationPickerTap?(sender.tag)
    }
    
    @IBAction func actiion_btnSwapTap(_ sender: UIButton) {
        self.btnSwap.transform = CGAffineTransform.identity
        if let parent = delegate as? CreateRideVC {
            parent.data.swapStartDest()
        } else if let parent = delegate as? FindRideVC {
            parent.data.swapStartDest()
        } else if let parent = delegate as? PostRequestVC {
            parent.data.swapStartDest()
        }
        
        prepareUI()
        UIView.animate(withDuration: 0.25) {
            self.btnSwap.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
    }
}

//MARK: - Register Cell
extension StartDestPickerCell {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "StartDestPickerCell", bundle: nil), forCellReuseIdentifier: identifier)
    }
}
