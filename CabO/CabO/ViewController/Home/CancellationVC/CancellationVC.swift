//
//  CancellationVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class CancellationVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var vwSubmitBtn: UIView!
    
    /// Variables
    var arrCells: [CancellationCellType] = [.title, .issueType]
    var screenType: CancelScreenType!
    var arrIssueTypes: [SupportTicketIssueType] = []
    var data = CancellationModel()
    var rideId: Int!
    var bookingId: Int?
    
    fileprivate var fontSize: CGFloat = 12 * _fontRatio
    
    var cancelPolicy: NSMutableAttributedString {
        let normalAttribute: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: AppColor.primaryText, NSAttributedString.Key.font: AppFont.fontWithName(.regular, size: fontSize)]
        let cancelation: [NSAttributedString.Key : Any] = [ NSAttributedString.Key.foregroundColor: UIColor.systemBlue,  NSAttributedString.Key.attachment : "cancel", NSAttributedString.Key.font: AppFont.fontWithName(.mediumFont, size: fontSize)]
        
        let para = NSMutableParagraphStyle()
        para.alignment = .left
        
        let mutableStr = NSMutableAttributedString(attributedString: NSAttributedString.attributedText(texts: ["Before canceling this ride, please review our ", "Cancellation Policy."], attributes: [normalAttribute, cancelation]))
        let range = NSMakeRange(0, mutableStr.string.count)
        mutableStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: para, range: range)
        return mutableStr
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        addKeyboardObserver()
        getCancellationReasons()
    }
}

// MARK: - UI Methods
extension CancellationVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
        lblTitle?.text = screenType.screenTitle
        
        if screenType != .rejectRequest {
            self.arrCells.insert(.info, at: 1)
        }
        
        TitleTVC.prepareToRegisterCells(tableView)
        InputCell.prepareToRegisterCells(tableView)
    }
}

// MARK: - Actions
extension CancellationVC {
    
    func openIssueTypePicker(_ sender: AnyObject) {
        let alert = UIAlertController.init(title: "Select reason", message: nil, preferredStyle: .actionSheet)
        
        arrIssueTypes.forEach { type in
            let action = UIAlertAction(title: type.name, style: .default) { [weak self] (action) in
                guard let self = self else { return }
                self.data.issueType = type
                if type.name.lowercased() == "other" && !self.arrCells.contains(.other) {
                    self.arrCells.removeItem(.message)
                    self.arrCells.append(.message)
                } else if self.arrCells.contains(.message){
                    self.arrCells.removeItem(.message)
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
            cancelAPI()
        } else {
            ValidationToast.showStatusMessage(message: valid.1, yCord: _navigationHeight)
        }
    }
}

// MARK: - TableView Methods
extension CancellationVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if cellType == .title {
            return screenType.screenInfo.heightWithConstrainedWidth(width: _screenSize.width - (40 * _widthRatio), font: AppFont.fontWithName(.mediumFont, size: 22 * _fontRatio)) + (20 * _widthRatio)
        }
        else if cellType == .info {
            return cancelPolicy.heightWithConstrainedWidth(width: _screenSize.width - (72 * _widthRatio)) + (24 * _widthRatio)
        }
        else {
            return cellType.cellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: arrCells[indexPath.row].cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? TitleTVC {
            cell.prepareUI(screenType.screenInfo, AppFont.fontWithName(.mediumFont, size: 22 * _fontRatio), clr: AppColor.primaryText)
        }
        else if let cell = cell as? CreateRideRulesCell {
            cell.lblTerms?.setTagText(attriText: cancelPolicy, linebreak: .byTruncatingTail)
            cell.lblTerms?.delegate = self
        }
        else if let cell = cell as? InputCell {
            cell.tag = indexPath.row
            cell.delegate = self
        }
    }
}

// MARK: - NLinkLabelDelagete
extension CancellationVC: NLinkLabelDelagete {
    
    func tapOnTag(tagName: String, type: ActiveType, tappableLabel: NLinkLabel) {
        nprint(items: tagName)
        if tagName == "cancel" {
            let vc = CmsVC.instantiate(from: .CMS)
            vc.screenType = .cancellationPolicy
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tapOnEmpty(index: IndexPath?) { }
}

// MARK: - UIKeyboard Observer
extension CancellationVC {
    
    func addKeyboardObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        if let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height + (12 * _widthRatio), right: 0)
        }
        if let fIndex = arrCells.firstIndex(of: .message), let cell = tableViewCell(index: fIndex) as? InputCell, cell.txtView.isFirstResponder {
            scrollToIndex(index: fIndex, animate: true, .top)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification){
        guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        tableView.contentInset = UIEdgeInsets(top: (8 * _widthRatio), left: 0, bottom: 50, right: 0)
    }
}

// MARK: - API Calls
extension CancellationVC {
    
    func getCancellationReasons() {
        
        showCentralSpinner()
        WebCall.call.getReasonList(["type" : screenType.apiEnd]) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? [NSDictionary] {
                data.forEach { type in
                    self.arrIssueTypes.append(SupportTicketIssueType(reason: type))
                }
                
                if !self.arrIssueTypes.contains(where: {$0.name.lowercased() == "other"}) {
                    self.arrIssueTypes.append(SupportTicketIssueType(reason: ["id": 0, "name":"Other"]))
                }
            } else {
                showError(data: json)
            }
        }
    }
    
    func cancelAPI() {
        var param: [String: Any] = data.param
        param["ride_id"] = rideId
        if let bookingId , bookingId != 0 {
            param["book_ride_id"] = bookingId
        }
        param["ride_status"] = screenType.updateStatus
        
        showCentralSpinner()
        WebCall.call.updateRideStatus(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.showSuccessMsg(data: json, yCord: _navigationHeight)
                if self.screenType == .rejectRequest {
                    _defaultCenter.post(name: Notification.Name.requestListUpdate, object: nil)
                    self.navigationController?.popToViewController(ofClass: BookingRequestListVC.self, animated: true)
                } else {
                    _defaultCenter.post(name: Notification.Name.rideListUpdate, object: nil)
                    self.navigationController?.popToViewController(ofClass: RideHistoryVC.self, animated: true)
                }
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
}
