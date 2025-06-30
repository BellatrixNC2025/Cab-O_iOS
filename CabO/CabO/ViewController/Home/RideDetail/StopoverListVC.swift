//
//  StopoverListVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class StopoverListVC: ParentVC {
    
    /// Variables
    var arrStops: [StopoverDetail] = []
    var fromTimeZoneId: String!
    var fromTimeZoneName: String!
    var rideId: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getStopOverList()
    }
}

// MARK: - UI Methods
extension StopoverListVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
        registerCells()
    }
    
    func registerCells() {
        
    }
    
    func getCellHeight(_ data: StopoverDetail, isFirst: Bool = false, isLast: Bool = false) -> CGFloat{
        var height: CGFloat = 0
        let padding = 70 * _widthRatio
        let timseZoneStr: String = fromTimeZoneName.shortName()
        if isFirst {
            let date = data.dateTimeStr + timseZoneStr
            height += date.heightWithConstrainedWidth(width: _screenSize.width - (padding), font: AppFont.fontWithName(.mediumFont, size: 14 * _fontRatio))
            height += data.fromLocation.heightWithConstrainedWidth(width: _screenSize.width - (padding), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio))
        } else if isLast {
            let date = data.toDateTimeStr + timseZoneStr
            height += date.heightWithConstrainedWidth(width: _screenSize.width - (padding), font: AppFont.fontWithName(.mediumFont, size: 14 * _fontRatio))
            height += data.toLocation.heightWithConstrainedWidth(width: _screenSize.width - (padding), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio))
        } else {
            let date = data.dateTimeStr + timseZoneStr
            height += date.heightWithConstrainedWidth(width: _screenSize.width - (padding), font: AppFont.fontWithName(.mediumFont, size: 14 * _fontRatio))
            height += data.fromLocation.heightWithConstrainedWidth(width: _screenSize.width - (padding), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio))
        }
        height += 52 * (DeviceType.iPhone ? _widthRatio : _heightRatio)
//        height += 40 * _heightRatio
        return height
    }
}

// MARK: - TableView Methods
extension StopoverListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrStops.isEmpty ? 0 : arrStops.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = indexPath.row == (arrStops.count) ? arrStops.last! : arrStops[indexPath.row]
        return getCellHeight(data, isFirst: indexPath.row == 0, isLast: indexPath.row == (arrStops.count))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "stopCell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? StopOverListCell {
            cell.parent = self
            let data = indexPath.row == (arrStops.count) ? arrStops.last! : arrStops[indexPath.row]
            cell.prepareUI(data, isFirst: indexPath.row == 0, isLast: indexPath.row == (arrStops.count))
        }
    }
}

// MARK: - API Call
extension StopoverListVC {
    
    func getStopOverList() {
        showCentralSpinner()
        WebCall.call.getRideStopovers(rideId) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            self.arrStops = []
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? [NSDictionary] {
                data.forEach { stop in
                    self.arrStops.append(StopoverDetail(stop, timeZone: self.fromTimeZoneId))
                }
                self.tableView.reloadData()
                let cells = self.tableView.visibleCells(in: 0)
                UIView.animate(views: cells, animations: [self.tableLoadAnimation])
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
}

// MARK: - StopOverListCell
class StopOverListCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    /// Variables
    weak var parent: StopoverListVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareUI(_ data: StopoverDetail, isFirst: Bool = false, isLast: Bool = false) {
        if isFirst {
            lblTitle.text = "Source"
            lblTitle.textColor = AppColor.themeGreen
            lblDate.text = data.dateTimeStr + " (\(parent.fromTimeZoneName.shortName()))"
            lblLocation.text = data.fromLocation
            imgView.image = UIImage(named: "ic_ride_start")
        } else if isLast {
            lblTitle.text = "Destination"
            lblTitle.textColor = UIColor.hexStringToUIColor(hexStr: "#257EF9")
            lblDate.text = data.toDateTimeStr + " (\(parent.fromTimeZoneName.shortName()))"
            lblLocation.text = data.toLocation
            imgView.image = UIImage(named: "ic_ride_dest")
        } else {
            lblTitle.text = "Stopover \(data.stopOverNumber! - 1)"
            lblTitle.textColor = UIColor.hexStringToUIColor(hexStr: "#00D3F2")
            lblDate.text = data.dateTimeStr + " (\(parent.fromTimeZoneName.shortName()))"
            lblLocation.text = data.fromLocation
            imgView.image = UIImage(named: "ic_ride_stop")?.withTintColor(UIColor.hexStringToUIColor(hexStr: "#00D3F2"))
        }
    }
}
