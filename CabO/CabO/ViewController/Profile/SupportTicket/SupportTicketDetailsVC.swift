//
//  SupportTicketDetailsVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

// MARK: - SupportTicketDetailsCell
class SupportTicketDetailsCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var labelCreatedAt: UILabel!
    @IBOutlet weak var labelTicketNo: UILabel!
    @IBOutlet weak var labelTicketStatus: UILabel!
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDesc: UILabel!
    
    @IBOutlet weak var labelTitleOne: UILabel!
    @IBOutlet weak var labelDescOne: UILabel!
    @IBOutlet weak var labelTitleTwo: UILabel!
    @IBOutlet weak var labelDescTwo: UILabel!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTripCode: UILabel!
    @IBOutlet weak var lblStartLoc: UILabel!
    @IBOutlet weak var lblDestLoc: UILabel!
    
    @IBOutlet weak var imgView: NRoundImageView!
    
    @IBOutlet weak var imgRideStart: UIImageView!
    @IBOutlet weak var imgRideEnd: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgRideStart?.setViewHeight(height: (DeviceType.iPad ? 22 : 18) * _widthRatio)
        imgRideEnd?.setViewHeight(height: (DeviceType.iPad ? 22 : 18) * _widthRatio)
    }
}

// MARK: - SupportTicketDetailsVC
class SupportTicketDetailsVC: ParentVC {
    
    /// Variables
    var arrCells: [SupportTicketDetailCellType] = [.ticket, .issueType, .other, .message, .image]
    var ticketId: String!
    var data: SupportTicketData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getTicketDetail()
    }
}

// MARK: - UI Methods
extension SupportTicketDetailsVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
        addRefresh()
    }
    
    func addRefresh() {
        refresh.addTarget(self, action: #selector(self.refreshing(_:)), for: .valueChanged)
        self.tableView.refreshControl = refresh
    }
    
    @objc private func refreshing(_ sender: UIRefreshControl) {
        self.getTicketDetail()
    }
    
    func getTripInfoCellHeight() -> CGFloat {
        if !data.rideId.isEmpty {
            var height: CGFloat = 0
            let addressMinHeight: CGFloat = 30 * _widthRatio
            let from = data.startLoc.heightWithConstrainedWidth(width: _screenSize.width - (100 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (12 * _widthRatio)
            let to = data.destLoc.heightWithConstrainedWidth(width: _screenSize.width - (100 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (12 * _widthRatio)
            height += from > addressMinHeight ? from : addressMinHeight
            height += to > addressMinHeight ? to : addressMinHeight
            height += 18 * _widthRatio
            return height + 24 * _widthRatio
        } else {
            return 0
        }
    }
}

// MARK: - TableView Methods
extension SupportTicketDetailsVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data == nil ? 0 : arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if cellType == .tripInfo {
            return data.rideId.isEmpty ? 0 : getTripInfoCellHeight()
        } else if cellType == .image {
            return data.image.isEmpty ? 0 : UITableView.automaticDimension
        } else  if cellType == .ticket {
            return UITableView.automaticDimension
        } else {
            let value = data.getValue(cellType)
            return value.isEmpty ? 0 : value.heightWithConstrainedWidth(width: _screenSize.width - (40 * _widthRatio), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio)) + (44 * _widthRatio)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrCells[indexPath.row]
        return tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? SupportTicketDetailsCell {
            
            cell.labelCreatedAt?.text = Date.localDateString(from: data.createdAt, format: "MMM dd, yyyy hh:mm a")
            cell.labelTicketNo?.text = data.ticketNo
            cell.labelTicketStatus?.text = data.status.title
            cell.labelTicketStatus?.textColor = data.status.color
            
            cell.lblTripCode?.text = data.tripCode
            cell.lblStartLoc?.text = data.startLoc
            cell.lblDestLoc?.text = data.destLoc
            
            if cellType == .driver {
                cell.labelTitle?.text = data.userType
            } else {
                cell.labelTitle?.text = cellType.detailTitle
            }
            cell.labelDesc?.text = data.getValue(cellType)
            
            if !data.image.isEmpty {
                cell.imgView?.loadFromUrlString(data.image, placeholder: _dummyPlaceImage)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if cellType == .image {
            openMsgImagePreview(data.image)
        }
    }
    
    func openMsgImagePreview(_ img: String) {
        let vc = KPImagePreview(objs: [img], sourceRace: nil, selectedIndex: nil, type: .preview)
        vc.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(vc, animated: true)
        }
    }
}

// MARK: - WebCall
extension SupportTicketDetailsVC {
    
    func getTicketDetail() {
        if !refresh.isRefreshing {
            showCentralSpinner()
        }
        
        WebCall.call.getSupportTicketDetail(ticketId) { [weak self] (json, status) in
            guard let weakSelf = self else { return }
            weakSelf.hideCentralSpinner()
            weakSelf.refresh.endRefreshing()
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
                let ticket = SupportTicketData(data)
                weakSelf.data = ticket
                if !ticket.rideId.isEmpty {
                    if !weakSelf.arrCells.contains(.tripInfo){
                        weakSelf.arrCells.insert(.tripInfo, at: 1)
                    }
                }
                
                if !weakSelf.arrCells.contains(.driver) && !ticket.dFullname.removeSpace().isEmpty {
                    weakSelf.arrCells.insert(.driver, at: 2)
                }
                
                if ticket.status == .rejected && !ticket.reason.isEmpty {
                    if let index = weakSelf.arrCells.firstIndex(of: .message) {
                        if !weakSelf.arrCells.contains(.rejectReason) {
                            weakSelf.arrCells.insert(.rejectReason, at: index + 1)
                        }
                    }
                }
                weakSelf.tableView.reloadData()
            } else {
                weakSelf.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
}
