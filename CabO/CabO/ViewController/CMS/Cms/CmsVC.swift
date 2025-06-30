//
//  CmsVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import WebKit

// MARK: - CmsScreenType
enum CmsScreenType {
    
    case tnc, privacy, cancellationPolicy, aboutUS, shareRide, stripe
    
    init?(_ screen: ProfileSettingsCells) {
        switch screen {
        case .tnc: self = .tnc
        case .privacyPolicy: self = .privacy
        case .cancellationPolicy: self = .cancellationPolicy
        case .aboutUS: self = .aboutUS
        default: self = .tnc
        }
    }
    
    var endPoint: String {
        switch self {
        case .tnc: return "terms_and_condition"
        case .privacy: return "privacy_policy"
        case .cancellationPolicy: return "cancellation_policy"
        case .shareRide: return "share_ride"
        case .aboutUS: return "about_us"
        case .stripe: return ""
        }
    }
    
    var title: String {
        switch self {
        case .tnc: return "Terms conditions"
        case .privacy: return "Privacy policy"
        case .cancellationPolicy: return "Cancellation policy"
        case .aboutUS: return "About Us"
        default: return ""
        }
    }
}

// MARK: - CmsVC
class CmsVC: ParentVC {

    @IBOutlet weak var bottomButtonView: UIView!
    @IBOutlet weak var topInfoView: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var webView: WKWebView!
    
    var screenType: CmsScreenType! = .tnc
    var isFromSignUp: Bool = false
    var dataStr: String = ""
    var stripeUrl: String!
    var isStripeFilled: Bool = false
    var block_bankDetailSuccess: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle?.text = screenType.title
        navView.backgroundColor = isFromSignUp ? AppColor.headerBg : AppColor.appBg
        
        setUpWebView()
        
        bottomButtonView.isHidden = !isFromSignUp
        topInfoView.isHidden = !isFromSignUp
        
        if screenType == .stripe {
            lblTitle?.text = isStripeFilled ? "Edit bank details" : "Add bank details"
            self.webView.load(URLRequest(url: URL(string: stripeUrl)!))
        } else {
            getCmsDetails()
        }
    }
    
    func setUpWebView() {
        self.webView.navigationDelegate = self
        self.webView.backgroundColor = AppColor.appBg
        self.webView.scrollView.backgroundColor = AppColor.appBg
        self.webView.scrollView.showsVerticalScrollIndicator = false
    }
    
    func loadHtmlString() {
        let apiHTMLString = "<html><body style='color: {text}'>\(self.dataStr)</body></html>"
        var customTextColor: String = ""
        if _appTheme == .system {
            customTextColor = UITraitCollection.current.userInterfaceStyle == .light ? "#000000" : "#FFFFFF"
        } else {
            customTextColor = _appTheme == .light ? "#000000" : "#FFFFFF"
        }
        
        let htmlString = apiHTMLString
            .replacingOccurrences(of: "{text}", with: customTextColor)
        self.webView.loadHTMLString(htmlString, baseURL: URL(string: _hostMode.baseUrl))
    }
    
    @IBAction func action_acceptTap(_ sender: UIButton) {
        _appDelegator.navigateUserToHome()
    }
    
    @IBAction func btn_back_tap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Theme change observer
extension CmsVC {

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if _appTheme == .system {
            if screenType != .stripe {
                loadHtmlString()
            }
        }
    }
}

// MARK: - WebView Delegate
extension CmsVC : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if screenType != .stripe {
            if navigationAction.navigationType == .linkActivated  {
                if let url = navigationAction.request.url,
                   let host = url.host, !host.hasPrefix("www.google.com"),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                    print(url)
                    print("Redirected to browser. No need to open it locally")
                    decisionHandler(.cancel)
                    return
                } else {
                    decisionHandler(.cancel)
                    return
                }
            } else {
                print("not a user click")
                decisionHandler(.allow)
                return
            }
        } else {
            decisionHandler(.allow)
            return
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Start navigation to Url String: \(webView.url?.absoluteString ?? "")")
        if screenType == .stripe {
            if let toUrl = webView.url?.absoluteString, toUrl == "\(_hostMode.baseUrl)success" || toUrl == "\(_hostMode.baseUrl)error" {
                block_bankDetailSuccess?()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

// MARK: - Tableview Method
extension CmsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let strHeight = dataStr.removeHTMLTag()?.heightWithConstrainedWidth(width: _screenSize.width - (40 * _widthRatio))
        return strHeight! + (50 * _widthRatio)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cmsCell", for: indexPath) as! CmsCell
        cell.lblTitle.attributedText = dataStr.removeHTMLTag()
        cell.lblTitle.textColor = AppColor.primaryText
        return cell
    }
}

// MARK: - API Calls
extension CmsVC {
    
    private func getCmsDetails() {
        self.showCentralSpinner()
        WebCall.call.getCmsDetails(screenType) { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
                self.lblTitle?.text = data.getStringValue(key: "title")
                self.dataStr = data.getStringValue(key: "content")
                self.loadHtmlString()
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
}

// MARK: - CmsCell
class CmsCell: ConstrainedTableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
