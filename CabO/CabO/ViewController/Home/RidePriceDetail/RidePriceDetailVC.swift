//
//  RidePriceDetailVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class RidePriceDetailVC: ParentVC {
    
    var data: RideDetails!
    var arrStops: [StopoverDetail]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

// MARK: - UI Methods
extension RidePriceDetailVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
    }
    
    func getCellHeight(_ start: String, _ dest: String) -> CGFloat {
        var height: CGFloat = 0
        let addressMinHeight: CGFloat = 30 * _widthRatio
        
        let from = start.heightWithConstrainedWidth(width: _screenSize.width - (90 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (16 * _widthRatio)
        let to = dest.heightWithConstrainedWidth(width: _screenSize.width - (90 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (16 * _widthRatio)
        height += from > addressMinHeight ? from : addressMinHeight
        height += to > addressMinHeight ? to : addressMinHeight
        height += 58 * _widthRatio
        height += 18 * _widthRatio
        return height
    }
}


// MARK: - TableView Methods
extension RidePriceDetailVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrStops == nil ? 0 : arrStops.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let start = indexPath.row == 0 ? data.start!.name! : arrStops[indexPath.row - 1].start!.name!
        let dest = indexPath.row == 0 ? data.dest!.name! : arrStops[indexPath.row - 1].dest!.name!
        return getCellHeight(start, dest)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "priceCell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? StopOverPriceCell {
            let start = indexPath.row == 0 ? data.start!.name! : arrStops[indexPath.row - 1].start!.name!
            let dest = indexPath.row == 0 ? data.dest!.name! : (indexPath.row == arrStops.count ? data.dest!.name! : arrStops[indexPath.row].start!.name!)
            let price = indexPath.row == 0 ? data.price.stringValues : arrStops[indexPath.row - 1].price.stringValues
            cell.preparePriceDetails(start, dest, price: price)
        }
    }
}

// MARK: - API Calls
extension RidePriceDetailVC {
    
    func getStopOverList() {
        showCentralSpinner()
        WebCall.call.getRideStopovers(data.id) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            self.arrStops = []
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? [NSDictionary] {
                data.forEach { stop in
                    self.arrStops.append(StopoverDetail(stop, timeZone: self.data.start!.timeZoneId))
                }
                self.tableView.reloadData()
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
}
