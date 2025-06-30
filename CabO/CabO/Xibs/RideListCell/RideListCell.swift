//
//  RideListCell.swift
//  CabO
//
//  Created by.
//

import UIKit

class RideListCell: ConstrainedTableViewCell {

    static let identifier: String = "rideListCell"
    
    /// Outlets
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var lblDest: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var imgDriver: UIImageView!
    @IBOutlet weak var imgDriverVerifyBadge: UIImageView!
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblDriverReviews: UILabel!
    @IBOutlet weak var lblDriverRating: UILabel!
    
    @IBOutlet weak var viewRating: UIView!
    
    @IBOutlet weak var viewAvailableSeatContainer: UIView!
    
    /// Variables
    var availableSeatView: AvailableSeatsCell?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// Prepare Cell UI
    func prepareUI(_ data: FindRideListModel) {
        
        lblDateTime.text = data.dateTimeStr
        lblStart.text = data.start?.customAddress
        lblDest.text = data.dest?.customAddress
        lblPrice.text = "₹\(data.price!)"
        
        
        lblDriverName.text = data.driver?.fullName
        if let img = data.driver?.img {
            imgDriver.loadFromUrlString(img, placeholder: _userPlaceImage)
        }
        if let driver = data.driver {
            lblDriverReviews.text = driver.reviewCount
            lblDriverRating.text = driver.averageRating.stringValues
            viewRating.isHidden = driver.totalReview == 0
        }
        
        if availableSeatView == nil {
            availableSeatView = Bundle.main.loadNibNamed("AvailableSeatsCell", owner: nil)?.first as? AvailableSeatsCell
        }
        if let availableSeatView {
            viewAvailableSeatContainer.addSubview(availableSeatView)
            availableSeatView.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
            availableSeatView.arrSeats = Array.init(repeating: 1, count: data.seatTotal)
            availableSeatView.prepareSeatLeftUI("Seat left - \(data.seatLeft!)", data.seatBooked)
        }
    }
}

//MARK: - Register Cell
extension RideListCell {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "RideListCell", bundle: nil), forCellReuseIdentifier: identifier)
    }
}
