//
//  RideDetailBookingListTVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

// MARK: - RideDetailBookingListTVC
class RideDetailBookingListTVC: ConstrainedTableViewCell {
    
    static let identifier: String = "RideDetailBookingListTVC"
    
    /// Outlets
    @IBOutlet weak var vwBookingList: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var vwViewMore: UIView!
    
    @IBOutlet weak var vwStatus: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var vwCode: UIView!
    @IBOutlet weak var lblVerificationCode: UILabel!
    
    @IBOutlet weak var vwRejected: UIView!
    @IBOutlet weak var vwRejectMsg: UIStackView!
    @IBOutlet weak var lblRejectReason: UILabel!
    @IBOutlet weak var lblRejectDesc: UILabel!
    
    /// Variables
    weak var delegate: ParentVC!{
        didSet {
            prepareUI()
        }
    }
    var arrData: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    var isSeatLeft: Bool = false
    var seatBookedCount: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView?.setViewHeight(height: (DeviceType.iPad ? 44 : 36) * _widthRatio)
        vwRejected.isHidden = true
        RideDetailBookingListCVC.prepareToRegister(collectionView)
    }
}

// MARK: - UI & Actions
extension RideDetailBookingListTVC {
    
    func prepareUI() {
        if let parent = delegate as? RideDetailVC {
            prepareRideDetail(parent)
        }
    }
    
    private func prepareRideDetail(_ parent: RideDetailVC) {
        vwCode.isHidden = true
        
        let data = parent.data!
        let status = data.status
        if ((status == .pending || status == .cancelled || status == .autoCancelled) && parent.screenType == .book) || status == .rejected {
            vwBookingList.isHidden = true
        } else {
            vwBookingList.isHidden = data.bookingList.isEmpty
        }
        vwRejected.isHidden = !(status == .rejected || status == .cancelled)
        if (status == .cancelled && parent.screenType == .created) {
            vwRejectMsg.isHidden = data.cancelRideMessage.isEmpty
            lblRejectReason.text = data.canceRideReason.capitalized
            lblRejectDesc.text = data.cancelRideMessage
        } else if parent.screenType == .book && status == .ontheway {
            let code = parent.data.verificationCode!
            vwCode.isHidden = code.isEmpty
            lblVerificationCode.addCharactersSpacing(spacing: (4 * _widthRatio), text: code)
        }
        else{
            vwCode.isHidden = true
            vwRejected.isHidden = data.cancelReasonDesc.isEmpty && data.cancelReason.isEmpty
            vwRejectMsg.isHidden = data.cancelReasonDesc.isEmpty
            lblRejectReason.text = data.cancelReason.capitalized
            lblRejectDesc.text = data.cancelReasonDesc
        }
        
        lblTitle.text = parent.screenType == .book ? "Co-riders" : "Booked"
       
        self.isSeatLeft = parent.screenType == .find
        if !isSeatLeft {
            arrData = data.bookingList.compactMap({$0.image})
        } else {
            vwBookingList.isHidden = false
            vwViewMore.isHidden = true
            vwStatus.isHidden = true
            arrData = Array.init(repeating: "", count: data.seatTotal)
            seatBookedCount = data.seatBooked
        }
        
        lblStatus.text = data.status.title
        lblStatus.textColor = data.status.color
    }
    
    @IBAction func btn_viewMore_tap(_ sender: UIButton) {
        if let parent = delegate as? RideDetailVC {
            parent.openRiderList(.booked)
        }
    }
}

// MARK: - CollectionView Methods
extension RideDetailBookingListTVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (DeviceType.iPad ? 44 : 36) * _widthRatio
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8 * _widthRatio
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8 * _widthRatio
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: RideDetailBookingListCVC.identifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? RideDetailBookingListCVC {
            if isSeatLeft {
                cell.bgView.isHidden = false
                cell.imgView.isHidden = true
                if indexPath.row < seatBookedCount! {
                    cell.imgSeat.tintColor = .white
                    cell.gradientView.isHidden = false
                } else {
                    cell.imgSeat.tintColor = AppColor.primaryText
                    cell.gradientView.isHidden = true
                }
            } else {
                cell.bgView.isHidden = true
                cell.imgView.isHidden = false
                cell.imgView.loadFromUrlString(arrData[indexPath.row], placeholder: _userPlaceImage)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isSeatLeft {
            if let parent = delegate as? RideDetailVC {
                parent.openRiderBookingDetail(indexPath.row)
            }
        }
    }
}

// MARK: - Register Cell
extension RideDetailBookingListTVC {
    
    class func prepareToRegister(_ sender: UITableView) {
        sender.register(UINib(nibName: "RideDetailBookingListTVC", bundle: nil), forCellReuseIdentifier: identifier)
    }
}

// MARK: - RideDetailBookingListCVC
class RideDetailBookingListCVC: ConstrainedCollectionViewCell {
    
    static let identifier: String = "RideDetailBookingListCVC"
    
    /// Outlets
    @IBOutlet weak var bgView: NRoundView!
    @IBOutlet weak var imgSeat: UIImageView!
    @IBOutlet weak var gradientView: RoundGradientView!
    
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView?.setViewHeight(height: (DeviceType.iPad ? 44 : 36) * _widthRatio)
        imgView?.setViewHeight(height: (DeviceType.iPad ? 44 : 36) * _widthRatio)
        imgSeat?.setViewHeight(height: (DeviceType.iPad ? 28 : 20) * _widthRatio)
    }
    
    /// Register Cell
    class func prepareToRegister(_ sender: UICollectionView) {
        sender.register(UINib(nibName: "RideDetailBookingListCVC", bundle: nil), forCellWithReuseIdentifier: identifier)
    }
}
