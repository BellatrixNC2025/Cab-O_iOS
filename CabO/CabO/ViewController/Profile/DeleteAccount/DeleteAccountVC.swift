//
//  DeleteAccountVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class DeleteAccountVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var buttonContinue: UIButton!
    @IBOutlet var vwProgress: [UIView]!
    
    /// Variables
    var deleteStep: DeleteAccountStep! {
        didSet {
            prepareStepWiseCells()
            updateProgressView()
        }
    }
    var arrCells: [DeleteAccountCellType]!
    fileprivate var arrReasons: [DeleteNote]?
    var arrInfo1: [String] = []
    var arrInfo2: [String] = []
    var selectedReason: Int?
    var otherReason: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
//        getDeleteInfo()
        getDeleteInfoCodable()
        addKeyboardObserver()
    }

    private func getLinkString(_ str: String, key: String) -> NSAttributedString {
        let atr: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.systemBlue, NSAttributedString.Key.attachment: key, NSAttributedString.Key.font: AppFont.fontWithName(.mediumFont, size: 14 * _fontRatio), NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
        ]

        let para = NSMutableParagraphStyle()
        para.minimumLineHeight = 20
        para.maximumLineHeight = 20
        para.alignment = .left

        let mutableStr = NSMutableAttributedString(attributedString: NSAttributedString.attributedText(texts: [str], attributes: [atr]))
        let range = NSMakeRange(0, mutableStr.string.count)
        mutableStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: para, range: range)

        return mutableStr
    }
}

// MARK: - UI Methods
extension DeleteAccountVC {

    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
        deleteStep = .step1
    }

    private func prepareStepWiseCells() {
        if deleteStep == .step1 {
            arrCells = [.title, .info, .linkLabel, .otherReason]
            if let arrReasons {
                arrCells.removeAll(where: { $0 == .reasonCell })
                let resons: [DeleteAccountCellType] = Array.init(repeating: .reasonCell, count: arrReasons.count)
                arrCells.insert(contentsOf: resons, at: 3)
            }
        } else if deleteStep == .step2 {
            arrCells = [.title, .linkLabel]
            arrCells.append(contentsOf: Array.init(repeating: .description, count: arrInfo1.count))
        } else {
            arrCells = [.title]
            arrCells.append(contentsOf: Array.init(repeating: .description, count: arrInfo2.count))
            delay(0.5) {
                self.deleteAccount()
            }
        }
        tableView.reloadData()
    }

    func updateProgressView() {
        vwProgress.forEach { view in
            view.backgroundColor = view.tag < deleteStep.rawValue ? AppColor.themeGreen : AppColor.placeholderText
        }
        buttonContinue.setTitle(deleteStep == .step3 ? "Done" : "Continue", for: .normal)
    }
}

// MARK: - Actions
extension DeleteAccountVC {

    func actionChooseReason(_ index: Int) {
        if let selectedReason {
            if selectedReason != index {
                self.otherReason = ""
                self.selectedReason = index
                tableView.reloadData()
            }
        } else {
            selectedReason = index
            tableView.reloadData()
        }
    }

    @IBAction func btnBackTap(_ sender: UIButton) {
        if deleteStep == .step2 {
            deleteStep = .step1
        } else if deleteStep == .step3 {
            _appDelegator.removeUserInfoAndNavToLogin()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func btnContinueTap(_ sender: UIButton) {
        if deleteStep == .step1 {
            if selectedReason == nil {
                ValidationToast.showStatusMessage(message: "Please select to reason to continue", yCord: _navigationHeight)
            } else if arrCells[self.selectedReason!] == .otherReason && otherReason.isEmpty {
                ValidationToast.showStatusMessage(message: "Please enter your reason to continue", yCord: _navigationHeight)
            } else {
                deleteStep = .step2
            }
        } else if deleteStep == .step2 {
            deleteStep = .step3
        } else {
            _appDelegator.removeUserInfoAndNavToLogin()
        }
    }
}

// MARK: - TableView Methods
extension DeleteAccountVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrReasons == nil ? 0 : arrCells.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if cellType == .linkLabel {
            let str = getLinkString(deleteStep == .step1 ? "Learn more about account deletion requests" : _user!.emailAddress, key: deleteStep == .step1 ? "learnMode" : "mail")
            return str.heightWithConstrainedWidth(width: _screenSize.width - (40 * _widthRatio)) + (28 * _heightRatio)
        } else if cellType == .info {
            let info = "This will permanently delete your account and your data, in accordance with applicable law."
            return info.heightWithConstrainedWidth(width: _screenSize.width - (70 * _widthRatio), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio)) + (16 * _widthRatio)
        } else if cellType == .reasonCell {
            return arrReasons![indexPath.row - 3].name.heightWithConstrainedWidth(width: _screenSize.width - (110 * _widthRatio), font: AppFont.fontWithName(.regular, size: 15 * _fontRatio)) + (34 * _widthRatio)
        } else if cellType == .otherReason {
            if selectedReason != nil && indexPath.row == selectedReason! {
                return 210 * _widthRatio
            } else {
                return 70 * _widthRatio
            }
        } else if cellType == .description {
            var str: String = ""
            if deleteStep == .step2 {
                str = arrInfo1[indexPath.row - 2]
            } else if deleteStep == .step3 {
                str = arrInfo2[indexPath.row - 1]
            }
            return str.heightWithConstrainedWidth(width: _screenSize.width - (80 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (16 * _heightRatio)
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrCells[indexPath.row]
        return tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? DeleteAccountCell {
            cell.tag = indexPath.row
            cell.parent = self
            cell.prepareU()
            if cellType == .title {
                cell.labelTitle.text = deleteStep.title
                cell.imgRightTitle?.isHidden = deleteStep.hideRightImage
            } else if cellType == .linkLabel {
                cell.labelLink?.setTagText(attriText: getLinkString(deleteStep == .step1 ? "Learn more about account deletion requests" : _user!.emailAddress, key: deleteStep == .step1 ? "learnMore" : "mail"), linebreak: .byTruncatingTail)
                cell.labelLink?.delegate = self
            } else if cellType == .reasonCell {
                cell.labelTitle?.text = arrReasons![indexPath.row - 3].name
                cell.buttonReasonRadio?.isSelected = (selectedReason != nil && indexPath.row == selectedReason!)
            } else if cellType == .otherReason {
                cell.buttonReasonRadio?.isSelected = (selectedReason != nil && indexPath.row == selectedReason!)
                cell.textContainer.isHidden = !cell.buttonReasonRadio.isSelected
                cell.lblReasonTitle.isHidden = !cell.buttonReasonRadio.isSelected
                cell.labelTextCount.isHidden = !cell.buttonReasonRadio.isSelected
            } else if cellType == .description {
                var str: String = ""
                if deleteStep == .step2 {
                    str = arrInfo1[indexPath.row - 2]
                } else if deleteStep == .step3 {
                    str = arrInfo2[indexPath.row - 1]
                }
                cell.labelTitle.text = str
            }

        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if cellType == .reasonCell || cellType == .otherReason {
            self.actionChooseReason(indexPath.row)
        }
    }
}

// MARK: - NLinkLabelDelagete
extension DeleteAccountVC: NLinkLabelDelagete {

    func tapOnEmpty(index: IndexPath?) {}

    func tapOnTag(tagName: String, type: ActiveType, tappableLabel: NLinkLabel) {
        nprint(items: tagName)
        if tagName == "learnMore" {
            let vc = DeleteAccountInfoVC.instantiate(from: .Profile)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - UIKeyboard Observer
extension DeleteAccountVC {

    func addKeyboardObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification: NSNotification) {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: _screenSize.height / 2, right: 0)
        if let fIndex = arrCells.firstIndex(of: .otherReason) {
            scrollToIndex(index: fIndex, animate: true, .top)
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
    }
}

// MARK: - API Call
extension DeleteAccountVC {

//    func getDeleteInfo() {
//        showCentralSpinner()
//        WebCall.call.getReasonList(["type": "delete_account"]) { [weak self] (json, status) in
//            guard let self = self else { return }
//            self.hideCentralSpinner()
//            self.arrCells.removeAll(where: { $0 == .reasonCell })
//            self.arrReasons = []
//            self.arrInfo1 = []
//            self.arrInfo2 = []
//            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
//                if let reasons = data["delete_reason"] as? [NSDictionary] {
//                    reasons.forEach { reason in
//                        self.arrReasons!.append(DeleteReason(reason))
//                        self.arrCells.insert(.reasonCell, at: 3)
//                    }
//                    self.arrReasons!.removeAll(where: { $0.title.lowercased() == "other" })
//                }
//                if let info1 = data["delete_account_note"] as? [NSDictionary] {
//                    info1.forEach { info in
//                        self.arrInfo1.append(info.getStringValue(key: "name"))
//                    }
//                }
//                if let info2 = data["deleted_account_note"] as? [NSDictionary] {
//                    info2.forEach { info in
//                        self.arrInfo2.append(info.getStringValue(key: "name"))
//                    }
//                }
//                self.tableView.reloadData()
//            } else {
//                self.showError(data: json, yCord: _navigationHeight)
//            }
//        }
//    }

    func deleteAccount() {
        var param: [String: Any] = [:]
        param["user_id"] = _user!.id
        if arrReasons!.count == selectedReason! - 3 {
            param["is_other"] = "1"
            param["other_reason"] = otherReason
        } else {
            param["reason_id"] = arrReasons![selectedReason! - 3].id
            param["is_other"] = "0"
        }

        self.showCentralSpinner()
        WebCall.call.deleteUser(param) { [weak self] (json, status) in
            guard let weakSelf = self else { return }
            weakSelf.hideCentralSpinner()
            if status == 200 {
                nprint(items: "User deleted")
            } else {
                weakSelf.showError(data: json)
            }
        }
    }
    
    func getDeleteInfoCodable() {
        showCentralSpinner()
        WebCall.call.getReasonListCodable(["type": "delete_account"]) { [weak self] (result: Result<ApiResponse<DeleteData>, Error>) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            self.arrCells.removeAll(where: { $0 == .reasonCell })
            self.arrReasons = []
            self.arrInfo1 = []
            self.arrInfo2 = []
            switch result {
            case .success(let response):
                guard let data = response.data else { return }
                
                self.arrReasons = data.deleteReason
                self.arrCells.insert(contentsOf: Array.init(repeating: .reasonCell, count: self.arrReasons!.count), at: 3)
                self.arrReasons!.removeAll(where: { $0.name.lowercased() == "other" })
                
                self.arrInfo1 = data.deleteAccountNote.map { $0.name }
                self.arrInfo2 = data.deletedAccountNote.map { $0.name }
                self.tableView.reloadData()
            case .failure(let error):
                self.showError(data: error, yCord: _navigationHeight)
                print("Error occured while fetching the data")
            }
        }
    }
}

///JSON Model
class DeleteReason {

    var id: Int!
    var name: String!

    init(_ dict: NSDictionary) {
        id = dict.getIntValue(key: "id")
        name = dict.getStringValue(key: "name")
    }
}

// Generic response model
struct ApiResponse<T: Codable>: Codable {
    let data: T?
    let message: String?
}

//Codabe Model
struct DeleteData: Codable {
    let deleteAccountNote: [DeleteNote]
    let deleteReason: [DeleteNote]
    let deletedAccountNote: [DeleteNote]

    enum CodingKeys: String, CodingKey {
        case deleteAccountNote = "delete_account_note"
        case deleteReason = "delete_reason"
        case deletedAccountNote = "deleted_account_note"
    }
}

struct DeleteNote: Codable {
    let createdAt: String
    let deletedAt: String?
    let id: Int
    let name: String
//    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case deletedAt = "deleted_at"
        case id
        case name
//        case updatedAt = "updated_at"
    }
}
