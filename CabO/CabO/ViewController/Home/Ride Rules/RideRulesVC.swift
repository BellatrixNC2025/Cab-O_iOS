//
//  RideRulesVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

fileprivate class RideRule {
    var title: String!
    var desc: String!
    var img: UIImage!
    
    init(_ titl: String, desc: String, img: UIImage) {
        self.title = titl
        self.desc = desc
        self.img = img
    }
}

// MARK: - RideRulesVC
class RideRulesVC: ParentVC {
    
    /// Variables
    var arrCells: [RideRuleCellsType] = [.title, .termsConditions, .btn]
    var screenType: RideRulesScreenType! = .crete
    fileprivate var arrRules: [RideRule]! = []
    var isTermsAccept: Bool = false
    var createData = CreateRideData()
    var bookData: RequestBookRideModel!
    
    fileprivate var fontSize: CGFloat = 12 * _fontRatio
    var createRideTerms: NSMutableAttributedString {
        let normalAttribute: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: AppColor.primaryText, NSAttributedString.Key.font: AppFont.fontWithName(.regular, size: fontSize)]
        let cancelation: [NSAttributedString.Key : Any] = [ NSAttributedString.Key.foregroundColor: UIColor.systemBlue,  NSAttributedString.Key.attachment : "driverCancel", NSAttributedString.Key.font: AppFont.fontWithName(.mediumFont, size: fontSize)]
        let termsTag: [NSAttributedString.Key : Any] = [ NSAttributedString.Key.foregroundColor: UIColor.systemBlue,  NSAttributedString.Key.attachment : "terms", NSAttributedString.Key.font: AppFont.fontWithName(.mediumFont, size: fontSize)]
        let privacyTag: [NSAttributedString.Key : Any] = [ NSAttributedString.Key.foregroundColor: UIColor.systemBlue,  NSAttributedString.Key.attachment : "privacy", NSAttributedString.Key.font: AppFont.fontWithName(.mediumFont, size: fontSize)]
        
        let para = NSMutableParagraphStyle()
        para.alignment = .left
        
        let mutableStr = NSMutableAttributedString(attributedString: NSAttributedString.attributedText(texts: ["I agree to these rules, to the ", "Driver Cancellation Policy", ", ", "Terms of Service", " and the ", "Privacy Policy,", " and I understand that my account could be suspended if I break the rules"], attributes: [normalAttribute, cancelation, normalAttribute, termsTag, normalAttribute, privacyTag, normalAttribute]))
        let range = NSMakeRange(0, mutableStr.string.count)
        mutableStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: para, range: range)
        return mutableStr
    }
    var bookRideTerms: NSMutableAttributedString {
        let normalAttribute: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: AppColor.primaryText, NSAttributedString.Key.font: AppFont.fontWithName(.regular, size: fontSize)]
        let para = NSMutableParagraphStyle()
        para.alignment = .left
        let mutableStr = NSMutableAttributedString(attributedString: NSAttributedString.attributedText(texts: ["I understand that my account could be suspended if I break these rules."], attributes: [normalAttribute]))
        let range = NSMakeRange(0, mutableStr.string.count)
        mutableStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: para, range: range)
        return mutableStr
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

// MARK: - UI Methods
extension RideRulesVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
        prepareRules()
        registerCells()
    }
    
    func prepareRules() {
        if screenType == .crete {
            arrRules.append(RideRule("Be reliable", desc: "Ensure punctuality for a smooth ride. Your passengers count on you. Thank you for being a dependable driver!", img: UIImage(named: "ic_rule_time")!))
            arrRules.append(RideRule("No cash", desc: "Do not accept any cash. Please utilize the app's payment method for security and assistance in all circumstances.", img: UIImage(named: "ic_rule_nocash")!))
            arrRules.append(RideRule("Drive safely", desc: "Prioritize safety on the road. Follow traffic rules, avoid distractions, and ensure a secure journey for everyone. Thank you for being a responsible driver!", img: UIImage(named: "ic_rule_drive")!))
        } else if screenType == .book {
            arrRules.append(RideRule("Show up on time", desc: "Respect the ride schedule. Arrive promptly at the designated pickup location. Punctuality ensures a smooth and efficient carpooling experience.", img: UIImage(named: "ic_rule_time")!))
            arrRules.append(RideRule("No cash", desc: "Do not pay cash. Please utilize the app's payment method for security and assistance in all circumstances.", img: UIImage(named: "ic_rule_nocash")!))
            arrRules.append(RideRule("Not a taxi service", desc: "Remember, this is a carpooling platform. Kindly be mindful that drivers are not professional taxi drivers. Let's foster a friendly and cooperative atmosphere.", img: UIImage(named: "ic_rule_notaxi")!))
        }
        arrRules.forEach { _ in
            arrCells.insert(.rule, at: 1)
        }
        tableView.reloadData()
    }
    
    func registerCells() {
        TitleTVC.prepareToRegisterCells(tableView)
        ButtonTableCell.prepareToRegisterCells(tableView)
    }
}

// MARK: - TableView Methods
extension RideRulesVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if cellType == .title {
            return screenType.title.heightWithConstrainedWidth(width: _screenSize.width - (40 * _widthRatio), font: AppFont.fontWithName(.mediumFont, size: 28 * _fontRatio)) + 12
        } else if cellType == .termsConditions {
            if screenType == .crete {
                return createRideTerms.heightWithConstrainedWidth(width: _screenSize.width - (92 * _widthRatio)) + (24 * _widthRatio)
            } else {
                return bookRideTerms.heightWithConstrainedWidth(width: _screenSize.width - (92 * _widthRatio)) + (24 * _widthRatio)
            }
        } else if cellType == .rule {
            var height: CGFloat = 0
            height += arrRules[indexPath.row - 1].title.heightWithConstrainedWidth(width: _screenSize.width - (164 * _widthRatio), font: AppFont.fontWithName(.mediumFont, size: 16 * _fontRatio))
            height += arrRules[indexPath.row - 1].desc.heightWithConstrainedWidth(width: _screenSize.width - (164 * _widthRatio), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio))
            height += 32 * _widthRatio
            return max(height, 108 * _widthRatio)
        }
        return cellType.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrCells[indexPath.row]
        return tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? TitleTVC {
            cell.prepareUI(screenType.title, AppFont.fontWithName(.mediumFont, size: 28 * _fontRatio), clr: AppColor.primaryText)
        }
        else if let cell = cell as? CreateRideRulesCell {
            if cellType == .termsConditions {
                cell.lblTerms?.setTagText(attriText: screenType == .crete ? createRideTerms : bookRideTerms, linebreak: .byTruncatingTail)
                cell.lblTerms?.delegate = self
            } else if cellType == .rule {
                cell.imgRule.image = arrRules[indexPath.row - 1].img
                cell.labelRuleTitle.text = arrRules[indexPath.row - 1].title
                cell.labelRuleDesc.text = arrRules[indexPath.row - 1].desc
            }
            cell.action_termsTap = { [weak self] in
                guard let self = self else { return }
                self.isTermsAccept.toggle()
            }
        }
        else if let cell = cell as? ButtonTableCell {
            cell.btn.setTitle(screenType == .crete ? "Post a ride" : "Continue", for: .normal)
            cell.btnTapAction = { [weak self] _ in
                guard let `self` = self else { return }
                if self.isTermsAccept {
                    self.continueAction()
                } else {
                    ValidationToast.showStatusMessage(message: "Please accept our terms and conditions to \(self.screenType == .crete ? "Post a ride" : "Continue booking")")
                }
            }
        }
    }
}

// MARK: - NLinkLabelDelagete
extension RideRulesVC: NLinkLabelDelagete {
    
    func tapOnTag(tagName: String, type: ActiveType, tappableLabel: NLinkLabel) {
        if tagName == "terms" {
            let vc = CmsVC.instantiate(from: .CMS)
            vc.screenType = .tnc
            self.navigationController?.pushViewController(vc, animated: true)
        } else if tagName == "privacy" {
            let vc = CmsVC.instantiate(from: .CMS)
            vc.screenType = .privacy
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = CmsVC.instantiate(from: .CMS)
            vc.screenType = .cancellationPolicy
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tapOnEmpty(index: IndexPath?) { }
}

// MARK: - API Calls
extension RideRulesVC {
    
    private func continueAction() {
        if screenType == .crete {
            self.createRide()
        } else {
            let vc = CardListVC.instantiate(from: .Profile)
            vc.screenType = .booking
            vc.bookData = self.bookData
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func createRide() {
        showCentralSpinner()
        WebCall.call.createRide(createData.createRideParam) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                if self.createData.rideId == nil {
                    self.showCreateSuccess()
                } else {
                    self.showSuccessMsg(data: json, yCord: _navigationHeight)
                    _defaultCenter.post(name: Notification.Name.rideDetailsUpdate, object: nil)
                    _defaultCenter.post(name: Notification.Name.rideListUpdate, object: nil)
                    self.navigationController?.popToViewController(ofClass: RideDetails.self, animated: true)
                }
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    fileprivate func showCreateSuccess() {
        let title: String = "Your ride has been created."
        let message: String = "Update your profile for a better ride experience."
        let animation: LottieAnimationName = .checkSuccess
        let success = SuccessPopUpView.initWithWindow(title, message, anim: animation)
        success.callBack = { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popToViewController(ofClass: NTabBarVC.self)
        }
    }
}
