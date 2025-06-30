//
//  RequestDetailVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class RequestDetailVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    /// Variables
    var arrCells: [RequestDetailCellType] = []
    var screenType: RequestDetailScreenType! = .carpool
    var reqId: Int!
    var data: RequestModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getRequestDetails()
    }
}

// MARK: - UI Methods
extension RequestDetailVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 12, right: 0)
        
        btnEdit.isHidden = screenType != .my
        btnDelete.isHidden = screenType != .my
        
        if screenType == .carpool {
            arrCells = [.trip, .seat, .msg, .driver]
        } else {
            arrCells = [.trip, .seat, .invitaion, .msg]
        }
        tableView.reloadData()
        addObservers()
    }
    
    private func getHeight(_ cellType: RequestDetailCellType) -> CGFloat {
        var height: CGFloat = 16 * _widthRatio
        let addressMinHeight: CGFloat = 34 * _widthRatio
        switch cellType {
        case .trip :
            return UITableView.automaticDimension
            let from = data.start!.name.heightWithConstrainedWidth(width: _screenSize.width - (100 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (8 * _widthRatio)
            let to = data.dest!.name.heightWithConstrainedWidth(width: _screenSize.width - (100 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (8 * _widthRatio)
            height += from > addressMinHeight ? from : addressMinHeight
            height += to > addressMinHeight ? to : addressMinHeight
            height += 30 * _widthRatio
            height += 16 * _widthRatio
        case .invitaion, .seat:
            height += (51 * _widthRatio)
        case .msg:
            if data.desc.isEmpty {
                height = 0
            } else {
                height += (51 * _widthRatio)
                height += data.desc.heightWithConstrainedWidth(width: _screenSize.width - (72 * _widthRatio), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio)) + (16 * _widthRatio)
            }
        case .driver: return 88 * _widthRatio
//        default:
//            height += 12
        }
        return height
    }
}

// MARK: - Actions
extension RequestDetailVC {
    
    @IBAction func btnEditTap(_ sender: UIButton) {
        let vc = PostRequestVC.instantiate(from: .Home)
        vc.data = PostRequestModel(data)
        vc.isEdit = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnDeleteTap(_ sender: UIButton) {
        showConfirmationPopUpView("Confirmation!", "are you sure you want to delete this request?", btns: [.cancel, .delete]) { btn in
            if btn == .delete {
                self.deleteRequest()
            }
        }
    }
}

// MARK: - TableView Methods
extension RequestDetailVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data == nil ? 0 : arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getHeight(arrCells[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: arrCells[indexPath.row].cellId, for: indexPath) as! RequestDetailCell
        cell.delegate = self
        cell.prepareUI(arrCells[indexPath.row])
        return cell
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if let cell = cell as? RequestDetailCell {
//            cell.delegate = self
//            cell.prepareUI(arrCells[indexPath.row])
//        }
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if cellType == .invitaion {
            let vc = BookingRequestListVC.instantiate(from: .Home)
            vc.screenType = .invitations
            vc.rideId = data.reqId
            self.navigationController?.pushViewController(vc, animated: true)
        } else if cellType == .driver {
            let vc = UserDetailVC.instantiate(from: .Home)
            vc.userId = data.userId
            vc.isDriver = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - Notification Observers
extension RequestDetailVC {
    
    func addObservers() {
        _defaultCenter.addObserver(self, selector: #selector(requestDetailsUpdated(_:)), name: Notification.Name.requestDetailsUpdate, object: nil)
    }
    
    @objc func requestDetailsUpdated(_ notification: NSNotification){
        getRequestDetails()
    }
}

// MARK: - API Calls
extension RequestDetailVC {
    
    func getRequestDetails () {
        var param: [String: Any] = [:]
        param["request_id"] = reqId
        
        showCentralSpinner()
        WebCall.call.getRequestDetails(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
                self.data = RequestModel(data)
                self.tableView.reloadData()
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    func deleteRequest() {
        showCentralSpinner()
        WebCall.call.deleteRequest(data.reqId) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.showSuccessMsg(data: json, yCord: _navigationHeight)
                _defaultCenter.post(name: Notification.Name.requestListUpdate, object: nil)
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
}
