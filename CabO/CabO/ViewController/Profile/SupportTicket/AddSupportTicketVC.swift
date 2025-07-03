//
//  AddSupportTicketVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import Photos

// MARK: - AddSupportTicketCell
class AddSupportTicketCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var buttonDelete: UIButton!
    
    /// Variables
    var actionButtonPickImage: ((AnyObject) -> ())?
    var actionButtonDeleteImage: ((AnyObject) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgView?.setViewHeight(height: (DeviceType.iPad ? 224 : 154) * _widthRatio)
    }
    
    @IBAction func btnPickImage(_ sender: UIButton) {
        actionButtonPickImage?(sender)
    }
    
    @IBAction func btnDeleteImage(_ sender: UIButton) {
        actionButtonDeleteImage?(sender)
    }
}

// MARK: - AddSupportTicketVC
class AddSupportTicketVC: ParentVC {
    
    /// Variables
    var arrCells: [AddSupportTicketCellType] = [.issueType, .message, .addImage]
    var arrIssueTypes: [SupportTicketIssueType] = []
    var data = SupportTicketModel()
    var isFromRideDetail: Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getSuportTicketList()
        getUserLocation()
    }
}

// MARK: - UI Methods
extension AddSupportTicketVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
        if isFromRideDetail {
            arrCells.insert(.rideInfo, at: 0)
        }
        registerCells()
        updateImageCell()
        addKeyboardObserver()
    }
    
    func registerCells() {
        InputCell.prepareToRegisterCells(tableView)
    }
    
    func updateImageCell() {
        if self.data.image != nil, let indx = arrCells.firstIndex(of: .addImage) {
            arrCells.remove(at: indx)
            arrCells.insert(.image, at: indx)
            tableView.reloadRows(at: [IndexPath(row: indx, section: 0)], with: .automatic)
        } else {
            if let indx = arrCells.firstIndex(of: .image) {
                arrCells.remove(at: indx)
                arrCells.insert(.addImage, at: indx)
                tableView.reloadRows(at: [IndexPath(row: indx, section: 0)], with: .automatic)
            }
        }
    }
    
    func getUserLocation() {
        weak var controller: UIViewController! = self
        UserLocation.sharedInstance.fetchUserLocationForOnce(controller: controller) { (location, error) in
            if let _ = location{
                if isGooleKeyFound{
                    KPAPICalls.shared.getAddressFromLatLong(lat: "\(location!.coordinate.latitude)", long: "\(location!.coordinate.longitude)", block: { (addres) in
                        if let addres{
                            self.data.location = addres.name!
                            self.data.lat = addres.lat
                            self.data.long = addres.long
                        }
                    })
                } else {
                    KPAPICalls.shared.addressFromlocation(location: location!, block: { (addres) in
                        if let addres{
                            self.data.location = addres.name!
                            self.data.lat = addres.lat
                            self.data.long = addres.long
                        }
                    })
                }
            }
        }
    }
    
    func getTripInfoCellHeight() -> CGFloat {
        if let data = data.rideDetails {
            var height: CGFloat = 0
            let addressMinHeight: CGFloat = 30 * _widthRatio
            height += data.dateTimeStr.heightWithConstrainedWidth(width: _screenSize.width - (100 * _widthRatio), font: AppFont.fontWithName(.mediumFont, size: 14 * _fontRatio)) + (24 * _widthRatio)
            let from = data.start!.name!.heightWithConstrainedWidth(width: _screenSize.width - (100 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (12 * _widthRatio)
            let to = data.dest!.name!.heightWithConstrainedWidth(width: _screenSize.width - (100 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (12 * _widthRatio)
            height += from > addressMinHeight ? from : addressMinHeight
            height += to > addressMinHeight ? to : addressMinHeight
            return height + 24 * _widthRatio
        } else {
            return 0
        }
    }
}

// MARK: - Actions
extension AddSupportTicketVC {
    
    func openIssueTypePicker(_ sender: AnyObject) {
        let alert = UIAlertController.init(title: "Select issue type", message: nil, preferredStyle: .actionSheet)
        
        arrIssueTypes.forEach { type in
            let action = UIAlertAction(title: type.name, style: .default) { [weak self] (action) in
                guard let `self` = self else { return }
                self.data.issueIType = type
                if type.name.lowercased() == "other" && !self.arrCells.contains(.other) {
                    self.arrCells.removeItem(.other)
                    if self.isFromRideDetail {
                        self.arrCells.insert(.other, at: 2)
                    } else {
                        self.arrCells.insert(.other, at: 1)
                    }
                } else if self.arrCells.contains(.other){
                    self.arrCells.removeItem(.other)
                    self.data.otherTitle = ""
                }
                self.tableView.reloadData()
            }
            alert.addAction(action)
        }
        let cancel = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        alert.addAction(cancel)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = (sender as? UIView)!.bounds
        }
        if _appTheme != .system {
            alert.overrideUserInterfaceStyle = appTheme
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func buttonSubmitTap(_ sender: UIButton) {
        let valid = data.isValid()
        if valid.0 {
            createSupportTicket()
        } else {
            ValidationToast.showStatusMessage(message: valid.1, yCord: _navigationHeight)
        }
    }
}

// MARK: - TableView Methods
extension AddSupportTicketVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if cellType == .rideInfo {
            return getTripInfoCellHeight()
        } else {
            return cellType.cellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrCells[indexPath.row]
        return tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? SupportTicketDetailsCell {
            if let rideDetail = data.rideDetails {
                cell.lblTripCode?.text = rideDetail.tripCode
                if data.type == 1 {
                    cell.lblDate?.text = data.bookDetails?.dateTimeStr
                    cell.lblStartLoc?.text = data.bookDetails?.fromLoc
                    cell.lblDestLoc?.text = data.bookDetails?.toLoc
                } else {
                    cell.lblDate?.text = rideDetail.dateTimeStr
                    cell.lblStartLoc?.text = rideDetail.start?.customAddress
                    cell.lblDestLoc?.text = rideDetail.dest?.customAddress
                }
            }
        }
        else if let cell = cell as? InputCell {
            cell.tag = indexPath.row
            cell.delegate = self
        }
        else if let cell = cell as? AddSupportTicketCell {
            cell.imgView?.image = self.data.image
            cell.actionButtonPickImage = { [weak self] (sender) in
                guard let weakSelf = self else { return }
                PhotoLibraryManager.shared.setup(.images, in: weakSelf, source: sender)
            }
            cell.actionButtonDeleteImage = { [weak self] (_) in
                guard let `self` = self else { return }
                self.data.image = nil
                self.updateImageCell()
            }
        }
        applyRoundedBackground(to: cell, at: indexPath, in: tableView)
    }
}

//MARK: - PhotoLibraryDelegate
extension AddSupportTicketVC: PhotoLibraryDelegate {
    
    func cameraMedia(_ image: UIImage) {
        if image.fileSizeMB > 4 {
            ValidationToast.showStatusMessage(message: kImageSizeValidation)
        } else {
            self.data.image = image
        }
        self.updateImageCell()
    }
    
    func photoLibrary(didFinishedPicking media: [PHAsset]) {
        if let imageAsset = media.first {
            let image = PhotoLibraryManager.shared.getImage(from: imageAsset)
            if image.fileSizeMB > 4 {
                ValidationToast.showStatusMessage(message: kImageSizeValidation)
            } else {
                self.data.image = image
            }
            self.updateImageCell()
        }
    }
    
    func didCancelPicking() {
        nprint(items: "Media pick canceled")
    }
}

// MARK: - UIKeyboard Observer
extension AddSupportTicketVC {
    
    func addKeyboardObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 10, right: 0)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification){
        guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
    }
}

// MARK: - API Calls
extension AddSupportTicketVC {
    
    func getSuportTicketList() {
        showCentralSpinner()
        WebCall.call.getSupportIssueType { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.arrIssueTypes = []
            self.hideCentralSpinner()
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? [NSDictionary] {
                data.forEach { type in
                    self.arrIssueTypes.append(SupportTicketIssueType(type))
                }
                if self.data.type == 0 {
                    self.arrIssueTypes.removeAll(where: {$0.alias == "the_rider_did_not_show_up"})
                    self.arrIssueTypes.removeAll(where: {$0.alias == "the_driver_did_not_show_up"})
                } else {
                    if self.data.type == 1 {
                        self.arrIssueTypes.removeAll(where: {$0.alias == "the_driver_did_not_show_up"})
                    } else {
                        self.arrIssueTypes.removeAll(where: {$0.alias == "the_rider_did_not_show_up"})
                    }
                }
            } else {
                showError(data: json)
            }
        }
    }
    
    func createSupportTicket() {
        
        showCentralSpinner()
        WebCall.call.createSupportTicket(data.param, imgKey: "image", image: data.image, progress: nil) { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.showSuccessMsg(data: json)
                _defaultCenter.post(name: Notification.Name.supportTicketListUpdate, object: nil)
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
}
