//
//  AvailableSeatsCell.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class AvailableSeatsCell: ConstrainedTableViewCell {
    
    static var identifier: String = "availableSeatsCell"
    static var cellHeight: CGFloat = 144 * _widthRatio
    static var titleCellHeight: CGFloat = 90 * _widthRatio
    
    /// Outlets
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var lblRideFull: UILabel!
    @IBOutlet weak var labelSubTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    /// Variables
    var arrSeats: [Int] = [1,2,3,4,5,6,7]
    var selectedSeat: Int?
    var seatLeft: Int?
    var maxAllow: Int?
    var minAllow: Int?
    var seatSelectionCallBack: ((Int) -> ())?
    var isFromRideDetails : Bool = false
    weak var delegate:ParentVC!
    let maxLimit = _appDelegator.config.createRideSeatLimit!
    
    var isSeatLeftUI: Bool! = false {
        didSet {
            leadingConstraint.constant = isSeatLeftUI ? (isFromRideDetails ? 20 : 12) : 20
            trailingConstraint.constant = isSeatLeftUI ? (isFromRideDetails ? 20 : 12) : 20
            self.layoutIfNeeded()
            collectionView.isUserInteractionEnabled = !isSeatLeftUI
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        SeatSelectionCollectionCell.prepareToRegister(collectionView)
    }
}

// MARK: - UI Methods
extension AvailableSeatsCell {
    
    func prepareUI(_ title: String = "Available seats", _ subTitle: String = "Add seats available count, without considering a driver seat.", hideSubTitle: Bool = false, _ selectedSeat: Int?,  _ maxAllow: Int? = nil) {
        labelTitle.text = title
        labelSubTitle.text = subTitle
        labelSubTitle.isHidden = hideSubTitle
        if hideSubTitle {
            labelTitle.font = labelTitle.font.withSize(18 * _fontRatio)
        }
        self.selectedSeat = selectedSeat
        self.maxAllow = maxAllow
        self.collectionView.reloadData()
        lblRideFull.isHidden = true
    }
    
    func prepareSeatLeftUI(_ title: String = "Seats Left - ", _ seatsLeft: Int = 0, isfromDetails : Bool = false) {
        labelTitle.text = title
        labelSubTitle.isHidden = true
        labelTitle.font = AppFont.fontWithName(.mediumFont, size: 14 * _fontRatio)
        self.seatLeft = seatsLeft
        lblRideFull.isHidden = seatsLeft != arrSeats.count
        self.isFromRideDetails = isfromDetails
        isSeatLeftUI = true
    }
}

// MARK: - CollectionView Methods
extension AvailableSeatsCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrSeats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if DeviceType.iPad {
            return CGSize(width: 48 * _widthRatio, height: 48 * _widthRatio)
        } else if isSeatLeftUI {
            return CGSize(width: (((_screenSize.width - (64 * _widthRatio)) / 7) - 4 * _widthRatio), height: (((_screenSize.width - (64 * _widthRatio)) / 7) - 4 * _widthRatio))
        } else {
            return CGSize(width: (((_screenSize.width - (40 * _widthRatio)) / 7) - 4 * _widthRatio), height: (((_screenSize.width - (40 * _widthRatio)) / 7) - 4 * _widthRatio))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1 * _widthRatio
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: SeatSelectionCollectionCell.identifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? SeatSelectionCollectionCell {
            let seatNo = indexPath.row + 1
            let _ = arrSeats[indexPath.row]
            if isSeatLeftUI {
                cell.labelSeat.isHidden = true
                cell.imgSeat.isHidden = false
                if indexPath.row < seatLeft! {
                    cell.imgSeat.tintColor = .white
                    cell.gradientView.isHidden = false
                } else {
                    cell.imgSeat.tintColor = AppColor.primaryText
                    cell.gradientView.isHidden = true
                }
            } else {
                cell.labelSeat.isHidden = false
                cell.imgSeat.isHidden = true
                
                cell.labelSeat.text = "\(seatNo)"
                cell.labelSeat.textColor = (selectedSeat != nil && seatNo == selectedSeat!) ? .white : AppColor.primaryText
                cell.gradientView.isHidden = !(selectedSeat != nil && seatNo == selectedSeat!)
                
                if let maxAllow, indexPath.row >= min(maxLimit, maxAllow){
                    cell.contentView.alpha = 0.5
                } else {
                    cell.contentView.alpha = 1
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let minAllow, (indexPath.row + 1) < minAllow {
            ValidationToast.showStatusMessage(message: "\(minAllow) seat is already booked", yCord: _navigationHeight)
        }
        else if let maxAllow{ //, indexPath.row >= maxAllow
            if let _ = delegate as? PostRequestVC {
                if indexPath.row >= maxAllow {
                    ValidationToast.showStatusMessage(message: "Maximum seats you can request ride for is \(maxAllow)", yCord: _navigationHeight)
                } else {
                    self.selectedSeat = indexPath.row + 1
                    seatSelectionCallBack?(selectedSeat!)
                    collectionView.reloadData()
                }
            } else {
                if indexPath.row >= maxLimit {
                    ValidationToast.showStatusMessage(message: "You can create ride for max \(maxLimit) seats", yCord: _navigationHeight)
                } else if indexPath.row >= maxAllow {
                    ValidationToast.showStatusMessage(message: "Maximum seats available in the selected car is \(maxAllow)", yCord: _navigationHeight)
                } else {
                    self.selectedSeat = indexPath.row + 1
                    seatSelectionCallBack?(selectedSeat!)
                    collectionView.reloadData()
                }
            }
        } else {
            self.selectedSeat = indexPath.row + 1
            seatSelectionCallBack?(selectedSeat!)
            collectionView.reloadData()
        }
    }
}

//MARK: - Register Cell
extension AvailableSeatsCell {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "AvailableSeatsCell", bundle: nil), forCellReuseIdentifier: identifier)
    }
}
