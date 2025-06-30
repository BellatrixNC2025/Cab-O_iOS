import Alamofire
import Foundation
import UIKit

// Hosting mode
let _hostMode = HostMode.staging
let _socket_url = URL(string: _hostMode.basePath_Socket)!
let _aws_bucket_name: String = _appDelegator.config.aws_bucket

// MARK: - HostMode
enum HostMode {
    case dev
    case staging
    case production
    
    var isSandBoxEnable: Bool {
        return false
    }
    
    var baseUrl: String {
        switch self {
        case .dev:
            return "https://cab-o.bellatrixnc.in/"
        case .staging:
            return "https://cab-o.bellatrixnc.in/"
        case .production:
            return ""
        }
    }
    
    var basePath_Socket: String {
        switch self {
        case .dev:
            return "http://192.168.1.209:8094/"
        case .staging:
            return "https://stg83.octosglobal.info:8096/" // "http://5.183.11.61:8096/"
        case .production:
            return ""
        }
    }
}

typealias WSBlock = (_ json: Any?, _ status: Int) -> Void
typealias WSProgress = (Progress) -> ()?
typealias WSFileBlock = (_ path: String?, _ error: Error?) -> Void

// MARK: Web Operation
struct AccessTokenAdapter: RequestInterceptor {
    
    let accessToken: String
    
    init(token: String) {
        accessToken = token
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        let req = urlRequest
        //        req.headers.add(.authorization(accessToken))
        //        nprint(items: "Auth :: \(accessToken)")
        completion(.success(req))
    }
}

// MARK: - WebCall
class WebCall: NSObject {
    
    static var call: WebCall = WebCall()
    
    let manager: Session
    var networkManager = NetworkReachabilityManager.default
    var headers: HTTPHeaders {
        var head = HTTPHeaders.default
        head.add(name: "Content-Type", value: "application/json")
        if let token = token as? AccessTokenAdapter {
            head.add(name: "Authorization", value: "Bearer \(token.accessToken)")
        }
        
        return head
    }
    
    var multipartHeaders: HTTPHeaders {
        var head = HTTPHeaders.default
        head.add(name: "Content-Type", value: "multipart/form-data")
        head.add(name: "Content-Disposition", value: "form-data")  //"Content-Disposition" : "form-data"
        if let token = token as? AccessTokenAdapter {
            head.add(name: "Authorization", value: "Bearer \(token.accessToken)")
        }
        
        return head
    }
    
    var token: RequestInterceptor?
    var toast: ValidationToast!
    var noInternetView: NoInternetView!
    let timeOutInteraval: TimeInterval = 60
    var successBlock: (String, HTTPURLResponse?, AnyObject?, WSBlock) -> Void
    var errorBlock: (String, HTTPURLResponse?, NSError, WSBlock) -> Void
    
    override init() {
        manager = Alamofire.Session.default
        
        // Will be called on success of web service calls.
        successBlock = { (relativePath, res, respObj, block) -> Void in
            // Check for response it should be there as it had come in success block
            if let response = res {
                nprint(items: "Response Code: \(response.statusCode)")
                nprint(items: "Response(\(relativePath)): \(String(describing: respObj))")
                
                if response.statusCode == 200 {
                    block(respObj, response.statusCode)
                } else {
                    if response.statusCode == 401 {
                        if _user != nil {
                            _appDelegator.removeUserInfoAndNavToLogin()
                            if let msg = respObj?["error"] as? String {
                                _ = KPValidationToast.shared.showToastOnStatusBar(message: msg)
                            } else {
                                _ = KPValidationToast.shared.showToastOnStatusBar(message: "kTokenExpire".localizedString())
                            }
                        }
                        block(["_appName".localizedString(): kInternetDown] as AnyObject, response.statusCode)
                    } else {
                        block(respObj, response.statusCode)
                    }
                }
            } else {
                // There might me no case this can get execute
                block(nil, 404)
            }
        }
        
        // Will be called on Error during web service call
        errorBlock = { (relativePath, res, error, block) -> Void in
            // First check for the response if found check code and make decision
            if let response = res {
                nprint(items: "Response Code: \(response.statusCode)")
                nprint(items: "Error Code: \(error.code)")
                if let data = error.userInfo["com.alamofire.serialization.response.error.data"] as? NSData {
                    let errorDict = (try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSDictionary
                    if errorDict != nil {
                        nprint(items: "Error(\(relativePath)): \(errorDict!)")
                        block(errorDict!, response.statusCode)
                    } else {
                        let code = response.statusCode
                        block(nil, code)
                    }
                } else if response.statusCode == 401 {
                    #warning("Logout User at this point")
                    if _user != nil {
                        _appDelegator.removeUserInfoAndNavToLogin()
                    }
                    block(["_appName".localizedString(): kInternetDown] as AnyObject, response.statusCode)
                } else {
                    block(nil, response.statusCode)
                }
                // If response not found rely on error code to find the issue
            } else if error.code == -1009 {
                nprint(items: "Error(\(relativePath)): \(error)")
                block(["_appName".localizedString(): kInternetDown] as AnyObject, error.code)
                return
            } else if error.code == -1003 {
                nprint(items: "Error(\(relativePath)): \(error)")
                block(["_appName".localizedString(): "kHostDown".localizedString()] as AnyObject, error.code)
                return
            } else if error.code == -1001 {
                nprint(items: "Error(\(relativePath)): \(error)")
                block(["_appName".localizedString(): "kTimeOut".localizedString()] as AnyObject, error.code)
                return
            } else {
                nprint(items: "Error(\(relativePath)): \(error)")
                block(nil, error.code)
            }
        }
        super.init()
        addInterNetListner()
    }
    
    deinit {
        networkManager?.stopListening()
    }
}

// MARK: Other methods
extension WebCall {
    /// It will return full url vased on current host mode and relPath
    /// - Parameter relPath: end point of URL
    /// - Returns: Full URL based on current hostmode
    func getFullUrl(relPath: String) throws -> URL {
        do {
            if relPath.lowercased().contains("http") || relPath.lowercased().contains("www") {
                return try relPath.asURL()
            } else {
                return try (_hostMode.baseUrl + relPath).asURL()
            }
        } catch let err {
            throw err
        }
    }
    
    /// It will set authorosation token
    /// - Parameter token: Authorization token for current session
    func setAccesTokenToHeader(token: String) {
        self.token = AccessTokenAdapter(token: token)
    }
    
    /// It will remove authorization token
    func removeAccessTokenFromHeader() {
        self.token = nil
    }
}

// MARK: - Request, ImageUpload and Dowanload methods
extension WebCall {
    
    @discardableResult
    /// It will do api call for provided api end point with config as per parameters
    /// - Parameters:
    ///   - relPath: API endpoint
    ///   - method: HTTPMethod (i.e: get, post, put, delete)
    ///   - param: Required parameters for API
    ///   - headerParam: Set of headers for API
    ///   - encoding: encoding format for API
    ///   - block: API callback
    /// - Returns: Optional DataRequest
    func apiCall(relPath: String, method: HTTPMethod, param: [String: Any]?, headerParam: HTTPHeaders? = nil, encoding: ParameterEncoding = JSONEncoding.default, block: @escaping WSBlock) -> DataRequest? {
        do {
            nprint(items: try getFullUrl(relPath: relPath))
            var finalHeaders = headers
            if let head = headerParam {
                for value in head.sorted() {
                    finalHeaders.add(value)
                }
            }
            nprint(items: finalHeaders)
            nprint(items: param ?? "")
            
            let req = manager.request(try getFullUrl(relPath: relPath), method: method, parameters: param, encoding: encoding, headers: finalHeaders, interceptor: token)
            
            return req.responseJSON { (res) in
                switch res.result {
                case .success(_):
                    if let resData = res.data {
                        do {
                            let respon = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                            self.successBlock(relPath, res.response, respon, block)
                        } catch let errParse {
                            nprint(items: errParse)
                            self.errorBlock(relPath, res.response, errParse as NSError, block)
                        }
                    }
                    break
                case .failure(let err):
                    nprint(items: err)
                    self.errorBlock(relPath, res.response, err as NSError, block)
                    break
                }
            }
        } catch let error {
            nprint(items: error)
            errorBlock(relPath, nil, error as NSError, block)
            return nil
        }
    }
    
    @discardableResult
    /// It will do api call for provided api end point with config as per parameters
    /// - Parameters:
    ///   - relPath: API endpoint
    ///   - method: HTTPMethod (i.e: get, post, put, delete)
    ///   - param: Required parameters for API
    ///   - headerParam: Set of headers for API
    ///   - encoding: encoding format for API
    ///   - block: API callback
    /// - Returns: Optional DataRequest
    func apiCall<T: Decodable>(relPath: String, method: HTTPMethod, param: [String: Any]?, headerParam: HTTPHeaders? = nil, encoding: ParameterEncoding = JSONEncoding.default, block: @escaping (Result<T, Error>) -> Void) -> DataRequest? {
        do {
            nprint(items: try getFullUrl(relPath: relPath))
            var finalHeaders = headers
            if let head = headerParam {
                for value in head.sorted() {
                    finalHeaders.add(value)
                }
            }
            nprint(items: finalHeaders)
            nprint(items: param ?? "")
            
            let req = manager.request(try getFullUrl(relPath: relPath), method: method, parameters: param, encoding: encoding, headers: finalHeaders, interceptor: token)
            
            return req.responseDecodable(of: T.self) { (res) in
                nprint(items: res.result)
                switch res.result {
                case .success(let value):
                    block(.success(value))
                case .failure(let error):
                    block(.failure(error))
                }
            }
        } catch let error {
            nprint(items: error)
            block(.failure(error))
            return nil
        }
    }
    
    func uploadImages(relPath: String, method: HTTPMethod, param: [String: Any]?, imgKey: String, imgs: [UIImage?], headerParam: HTTPHeaders?, progress: WSProgress?, block: @escaping WSBlock) {
        
        do {
            
            nprint(items: try getFullUrl(relPath: relPath))
            var finalHeaders = headers
            if let head = headerParam {
                for value in head.sorted() {
                    finalHeaders.add(value)
                }
            }
            nprint(items: finalHeaders)
            nprint(items: param ?? "")
            
            let url = try getFullUrl(relPath: relPath)
            manager.upload(
                multipartFormData: { (formData) in
                    for (idx, img) in imgs.enumerated() {
                        if let _ = img {
                            formData.append(img!.jpegData(compressionQuality: 0.5)!, withName: imgKey, fileName: "image\(idx).png", mimeType: "image/png")
                        }
                    }
                    if let _ = param {
                        for (key, value) in param! {
                            if let str = value as? String {
                                formData.append(str.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: key)
                            } else if let strArr = value as? [String] {
                                for (_, img) in strArr.enumerated() {
                                    formData.append(img.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "\(key)[]")
                                }
                            } else if let str = value as? Int {
                                formData.append("\(str)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: key)
                            }
                        }
                    }
                    nprint(items: formData)
                }, to: url, method: method, headers: (headerParam ?? headers), interceptor: token
            ).uploadProgress { upPorgress in
                progress?(upPorgress)
            }.responseJSON { (resObj) in
                switch resObj.result {
                case .success:
                    if let resData = resObj.data {
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                            self.successBlock(relPath, resObj.response, res, block)
                        } catch let errParse {
                            nprint(items: errParse)
                            self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                        }
                    }
                    break
                case .failure(let err):
                    nprint(items: err)
                    self.errorBlock(relPath, resObj.response, err as NSError, block)
                    break
                }
            }
        } catch let err {
            self.errorBlock(relPath, nil, err as NSError, block)
        }
    }
    
    func uploadCarImages(relPath: String, param: [String: Any]?, imgKey: String, carImgs: [UIImage?], regImage: UIImage?, insImage: UIImage?, headerParam: HTTPHeaders?, progress: WSProgress?, block: @escaping WSBlock) {
        
        do {
            
            nprint(items: try getFullUrl(relPath: relPath))
            var finalHeaders = headers
            if let head = headerParam {
                for value in head.sorted() {
                    finalHeaders.add(value)
                }
            }
            nprint(items: finalHeaders)
            nprint(items: param ?? "")
            
            let url = try getFullUrl(relPath: relPath)
            manager.upload(
                multipartFormData: { (formData) in
                    for (idx, img) in carImgs.enumerated() {
                        if let _ = img {
                            formData.append(img!.pngData()!, withName: imgKey, fileName: "image\(idx).png", mimeType: "image/png")
                        }
                    }
                    if let regImage {
                        formData.append(regImage.jpegData(compressionQuality: 0.7)!, withName: "registration_image", fileName: "image.jpeg", mimeType: "image/jpeg")
                    }
                    if let insImage {
                        formData.append(insImage.jpegData(compressionQuality: 0.7)!, withName: "insurance_card", fileName: "image.jpeg", mimeType: "image/jpeg")
                    }
                    if let _ = param {
                        for (key, value) in param! {
                            if let str = value as? String {
                                formData.append(str.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: key)
                            } else if let strArr = value as? [String] {
                                for (_, str) in strArr.enumerated() {
                                    formData.append(str.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "\(key)[]")
                                }
                            } else if let str = value as? Int {
                                formData.append("\(str)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: key)
                            }
                        }
                    }
                    nprint(items: formData)
                }, to: url, method: HTTPMethod.post, headers: (headerParam ?? headers), interceptor: token
            ).uploadProgress { upPorgress in
                progress?(upPorgress)
            }.responseJSON { (resObj) in
                switch resObj.result {
                case .success:
                    if let resData = resObj.data {
                        do {
                            let res = try JSONSerialization.jsonObject(with: resData, options: []) as AnyObject
                            self.successBlock(relPath, resObj.response, res, block)
                        } catch let errParse {
                            nprint(items: errParse)
                            self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                        }
                    }
                    break
                case .failure(let err):
                    nprint(items: err)
                    self.errorBlock(relPath, resObj.response, err as NSError, block)
                    break
                }
            }
        } catch let err {
            self.errorBlock(relPath, nil, err as NSError, block)
        }
    }
    
    /// It will perform upload dara request with config as parameters
    /// - Parameters:
    ///   - relPath: API endpoint
    ///   - data: Data to upload
    ///   - block: API callback
    ///   - progressB: upload progress
    func uploadFileToUrl(relPath: String, data: Data, block: @escaping WSBlock, progressB: WSProgress?) {
        
        var request = URLRequest(url: URL(string: relPath)!, timeoutInterval: Double.infinity)
        request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let res = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    block(nil, res.statusCode)
                }
            } else {
                DispatchQueue.main.async {
                    block(nil, 100)
                }
            }
        }
        task.resume()
    }
}

// MARK: - Internet Availability
extension WebCall {
    
    /// It will add internet listner for check internet availablity.
    func addInterNetListner() {
        networkManager?.startListening(onUpdatePerforming: { [weak self] (status) in
            guard let weakSelf = self else { return }
            if case .reachable(_) = status {
                nprint(items: "Internet Avail")
                if weakSelf.noInternetView != nil {
                    weakSelf.noInternetView.animateOut {
                        weakSelf.noInternetView.removeFromSuperview()
                        weakSelf.noInternetView = nil
                    }
                }
            } else {
                nprint(items: "No InterNet")
                if weakSelf.noInternetView == nil {
                    weakSelf.noInternetView = NoInternetView.initWithWindow()
                }
            }
        })
    }
    
    /// It will check internet is rechable or not
    /// - Returns: returns bool true if internet is available else false
    func isInternetAvailable() -> Bool {
        if let man = networkManager {
            if man.isReachable {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
}

// MARK: - General
extension WebCall {
    
    func uploadImageToS3(url: String, img: UIImage, block: @escaping WSBlock) {
        nprint(items: "------------ Upload Image --------")
        uploadFileToUrl(relPath: url, data: img.jpegData(compressionQuality: 1)!, block: block, progressB: nil)
    }
    
    func getS3ImageUrl(_ file_name: String, block: @escaping WSBlock) {
        nprint(items: "------------ Upload Image --------")
        let relPath = "v1/getimageurl"
        apiCall(relPath: relPath, method: .post, param: ["image_name": file_name], headerParam: nil, block: block)
    }
    
    func getConfig(block: @escaping WSBlock) {
        nprint(items: "---------------- Get Config -----------")
        let relPath = "v1/getconfig/\(Setting.configKey.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
    
    func updatePushToken(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "------------- Update Push Token ------------")
        let relPath = "v1/adddevicetoken"
        var param = param
        param["api_version"] = "v1"
        apiCall(relPath: relPath, method: .post, param: param.merged(with: Setting.deviceInfo).merged(with: Setting.deviceAppInfo), headerParam: nil, block: block)
    }
    
    func getUserProfile(block: @escaping WSBlock) {
        nprint(items: "---------------- Get User Profile -----------")
        let relPath = "v1/userdetails"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
    
    func getLatestVersion(block: @escaping WSBlock) {
        nprint(items: "--------- Get Latest App Version ---------")
        let relPath = "v1/getappversion"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
    
    func getRideConfig(block: @escaping WSBlock) {
        nprint(items: "--------- Get Ride Configuration ---------")
        let relPath = "v1/getrideflag"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
    
    func getReasonList(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "--------- Get Reasons ---------")
        let relPath = "v1/getreasonlist"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    //Coable API Call
    func getReasonListCodable<T: Decodable>(_ param: [String: Any], block: @escaping (Result<T, Error>) -> Void) {
        nprint(items: "--------- Get Reasons ---------")
        let relPath = "v1/getreasonlist"
        apiCall(relPath: relPath, method: .post, param: param, block: block)
    }
}

// MARK: - Entry
extension WebCall {
    
    func loginUser(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Login User -----------")
        let relPath = "v1/login"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func socialSignIn(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Social Sign in User -----------")
        let relPath = "v1/sociallogin"
        var param = param
        param["api_version"] = "v1"
        apiCall(relPath: relPath, method: .post, param: param.merged(with: Setting.deviceAppInfo), headerParam: nil, block: block)
    }
    
    func signupUser(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Signup User -----------")
        let relPath = "v1/signup"
        var param = param
        param["api_version"] = "v1"
        apiCall(relPath: relPath, method: .post, param: param.merged(with: Setting.deviceAppInfo), headerParam: nil, block: block)
    }
    
    func resendOtp(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Resend OTP -----------")
        let relPath = "v1/resendotp"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func verifyOtp(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Verify OTP -----------")
        let relPath = "v1/verifyotpemailmobile"
        var param = param
        param["api_version"] = "v1"
        apiCall(relPath: relPath, method: .post, param: param.merged(with: Setting.deviceAppInfo), headerParam: nil, block: block)
    }
    
    func verifyForgotOtp(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Verify Forgot OTP -----------")
        let relPath = "v1/forgotverifyotp"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func verifyUpdateProfileOtp(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Update Profile OTP -----------")
        let relPath = "v1/verifynewotpemailmobile"
        var param = param
        param["api_version"] = "v1"
        apiCall(relPath: relPath, method: .post, param: param.merged(with: Setting.deviceAppInfo), headerParam: nil, block: block)
    }
    
    func updateEmailMobile(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Update Email Mobile -----------")
        let relPath = "v1/updateemailmobile"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func logoutUser(block: @escaping WSBlock) {
        nprint(items: "---------------- Logout User -----------")
        let relPath = "v1/logout"
        apiCall(relPath: relPath, method: .put, param: nil, headerParam: nil, block: block)
    }
    
    func deleteUser(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Delete User -----------")
        let relPath = "v1/removeuser"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
}

// MARK: - Notification
extension WebCall {
    
    func getNotificationList(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Get Notification List -----------")
        let relPath = "v1/notificationlist"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func getUnReadCount(block: @escaping WSBlock) {
        nprint(items: "---------------- Get Unread Count -----------")
        let relPath = "v1/unreadcount"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
}

// MARK: - Profile Menu
extension WebCall {
    
    func updateUserProfile(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Update User Profile -----------")
        let relPath = "v1/updateprofile"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func updateProfileImage(param: [String: Any], imgKey: String, image: UIImage, progress: @escaping WSProgress, block: @escaping WSBlock) {
        nprint(items: "---------------- Update User Profile Image -----------")
        let relPath = "v1/updateprofile"
        uploadImages(relPath: relPath, method: .post, param: param, imgKey: imgKey, imgs: [image], headerParam: nil, progress: progress, block: block)
    }
    
    func changePassword(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Change Password -----------")
        let relPath = "v1/changepassword"
        apiCall(relPath: relPath, method: .put, param: param, headerParam: nil, block: block)
    }
    
    func updateNotitificationPref(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Notification On Off -----------")
        let relPath = "v1/notificationonoff"
        apiCall(relPath: relPath, method: .put, param: param, headerParam: nil, block: block)
    }
    
    func resetPassword(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Reset Password -----------")
        let relPath = "v1/forgotresetpassword"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func getCmsDetails(_ type: CmsScreenType, block: @escaping WSBlock) {
        nprint(items: "---------------- Get CMS Details -----------")
        let relPath = "v1/getcms/\(type.endPoint)"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
    
    func getFaqDetails(block: @escaping WSBlock) {
        nprint(items: "---------------- Get CMS Details -----------")
        let relPath = "v1/getfaq"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
}

// MARK: - Support Ticket
extension WebCall {
    
    func getSupportIssueType(block: @escaping WSBlock) {
        nprint(items: "---------------- Get Support Ticker Issue Types -----------")
        let relPath = "v1/getsupportticketissue"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
    
    func createSupportTicket(_ param: [String: Any], imgKey: String, image: UIImage?, progress: WSProgress?, block: @escaping WSBlock) {
        nprint(items: "---------------- Create Support Ticket -----------")
        let relPath = "v1/addsupportticket"
        if let image {
            uploadImages(relPath: relPath, method: .post, param: param, imgKey: imgKey, imgs: [image], headerParam: nil, progress: progress, block: block)
        } else {
            apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
        }
    }
    
    func getSupportTicketList(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Get Support Ticket List -----------")
        let relPath = "v1/getsupportticketlisitng"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func getSupportTicketDetail(_ id: String, block: @escaping WSBlock) {
        nprint(items: "---------------- Get Support Ticket Detail -----------")
        let relPath = "v1/getsupportticketdetail/\(id)"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
}

// MARK: - Car
extension WebCall {
    
    func getMyCarList(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Get Car List -----------")
        let relPath = "v1/getmycarlist"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func getCarDetails(_ id: String, block: @escaping WSBlock) {
        nprint(items: "---------------- Get Car Details -----------")
        let relPath = "v1/getcardetail/\(id)"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
    
    func addUpdateCar(param: [String: Any], imgKey: String, carImages: [UIImage], regImage: UIImage?, insuranceImage: UIImage?, progress: WSProgress?, block: @escaping WSBlock) {
        nprint(items: "---------------- Add Update Car -----------")
        let relPath = "v1/addupdatecar"
        if carImages.isEmpty && regImage == nil && insuranceImage == nil {
            apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
        } else {
            uploadCarImages(relPath: relPath, param: param, imgKey: imgKey, carImgs: carImages, regImage: regImage, insImage: insuranceImage, headerParam: nil, progress: progress, block: block)
        }
    }
    
    func deleteCar(_ id: String, block: @escaping WSBlock) {
        nprint(items: "---------------- Delete Car -----------")
        let relPath = "v1/deleteusercar/\(id)"
        apiCall(relPath: relPath, method: .delete, param: nil, headerParam: nil, block: block)
    }
    
    func getCarMasterDetails(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Get Car Master Details -----------")
        let relPath = "v1/getcarmasterdetails"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func checFace(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Check Face -----------")
        let relPath = "v1/checkimagecompare"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
}

// MARK: - ID Verification
extension WebCall {
    
    func addLicenceDetails(param: [String: Any], imgKey: String, licenceImage: UIImage, progress: WSProgress?, block: @escaping WSBlock) {
        nprint(items: "---------------- Add Licence Details -----------")
        let relPath = "v1/addupdatedrivinglicense"
        uploadImages(relPath: relPath, method: .post, param: param, imgKey: imgKey, imgs: [licenceImage], headerParam: nil, progress: progress, block: block)
    }
    
    func getLicenceDetails(block: @escaping WSBlock) {
        nprint(items: "---------------- Get Licence Details -----------")
        let relPath = "v1/getlicensedetail"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
}

// MARK: - Payment Details
extension WebCall {
    
    func addCardDetails(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Add Card Details -----------")
        let relPath = "v1/addcard"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func deleteCard(_ id: String, block: @escaping WSBlock) {
        nprint(items: "---------------- Delete Card Details -----------")
        let relPath = "v1/deletecard/\(id)"
        apiCall(relPath: relPath, method: .delete, param: nil, headerParam: nil, block: block)
    }
    
    func getCardList(block: @escaping WSBlock) {
        nprint(items: "---------------- Get Card List -----------")
        let relPath = "v1/getcard"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
    
    func updateDefaultCard(_ id: String, block: @escaping WSBlock) {
        nprint(items: "---------------- Update Default Card -----------")
        let relPath = "v1/updatedefaultcard/\(id)"
        apiCall(relPath: relPath, method: .put, param: nil, headerParam: nil, block: block)
    }
    
    func addBankDetails(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Add Bank Details -----------")
        let relPath = "v1/addbusinesspaymentinfo"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func getBankDetails(block: @escaping WSBlock) {
        nprint(items: "---------------- Get Bank Details -----------")
        let relPath = "v1/getbusinesspaymentinfo"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
    
    func getStripeDetails(block: @escaping WSBlock) {
        nprint(items: "---------------- Get Stripe Details -----------")
        let relPath = "v1/getstripeaccount"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
}

// MARK: - Create Ride Flow
extension WebCall {
    
    func getRidePrefs(block: @escaping WSBlock) {
        nprint(items: "---------------- Get Ride Prefs -----------")
        let relPath = "v1/getpreferences"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
    
    func checkRidePrefs(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Check Ride Prefs -----------")
        let relPath = "v1/checkridevalidate"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func getMilesPrice(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Get Miles Price -----------")
        let relPath = "v1/getmilesprice"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func createRide(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Create Ride -----------")
        let relPath = "v1/addupdateride"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
}

// MARK: - Find Ride Flow
extension WebCall {
    
    func getFindRideList(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Get Find Ride List -----------")
        let relPath = "v1/findrides"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func bookRide(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Book Ride -----------")
        let relPath = "v1/bookride"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func postRideRequest(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Post a Request -----------")
        let relPath = "v1/addupdtepostrequestride"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func getRequestDetails(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Request Details -----------")
        let relPath = "v1/getpostridedetail"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func deleteRequest(_ id: Int, block: @escaping WSBlock) {
        nprint(items: "---------------- Delete Request -----------")
        let relPath = "v1/deletepostrequest/\(id)"
        apiCall(relPath: relPath, method: .delete, param: nil, headerParam: nil, block: block)
    }
    
    func acceptRejectBookingRequest(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Accept Reject Booking Request -----------")
        let relPath = "v1/acceptrejectride"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
}

// MARK: - Ride History
extension WebCall {
    
    func getMyRides(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Get My Rides -----------")
        let relPath = "v1/getmyrides"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func getBookedRides(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Get Booked Rides -----------")
        let relPath = "v1/getbookrides"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func getPostReqRides(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Get Post Request Rides -----------")
        let relPath = "v1/getpostrequestrides"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
}

// MARK: - Ride Details
extension WebCall {
    
    func getMyRideDetails(_ id: Int, block: @escaping WSBlock) {
        nprint(items: "---------------- Get My Ride Details -----------")
        let relPath = "v1/getmyridedetail/\(id)"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
    
    func getBookedRideDetails(_ id: Int, block: @escaping WSBlock) {
        nprint(items: "---------------- Get Booked Ride Details -----------")
        let relPath = "v1/getbookingridedetail/\(id)"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
    
    func getFindRideDetails(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Get Find Ride Details -----------")
        let relPath = "v1/findridedetail"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func updateRideStatus(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Update Ride Status -----------")
        let relPath = "v1/updateridestatus"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func getRideStopovers(_ id: Int, block: @escaping WSBlock) {
        nprint(items: "---------------- Get My Ride Stopovers -----------")
        let relPath = "v1/getridestopovers/\(id)"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
    
    func getRideSeats(_ id: Int, block: @escaping WSBlock) {
        nprint(items: "---------------- Get My Ride Seats -----------")
        let relPath = "v1/getrideseats/\(id)"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
    
    func getRequestRidePrice(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Get Request Ride Price -----------")
        let relPath = "v1/getrequestrideprice"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func applyPromoCode(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Apply Promo Code -----------")
        let relPath = "v1/applycoupon"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func getBookingList(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Get Booking List -----------")
        let relPath = "v1/getbookinglist"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func getBookingDetail(_ id: Int, block: @escaping WSBlock) {
        nprint(items: "---------------- Get Booking Detail -----------")
        let relPath = "v1/getbookingdetail/\(id)"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
    
    func getMyRideTransactionDetails(_ id: Int, block: @escaping WSBlock) {
        nprint(items: "---------------- Get Ride Transaction Detail -----------")
        let relPath = "v1/getmyridetransactions/\(id)"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
    
    func getInvitationsList(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Get Invitation List -----------")
        let relPath = "v1/getinvitationslist"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func inviteForRide(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Invite for Ride -----------")
        let relPath = "v1/inviteride"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func getInviteRiders(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Invite for Ride List -----------")
        let relPath = "v1/getinviteriders"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func payDriverTip(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Pay Driver Tip -----------")
        let relPath = "v1/paytip"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func getRideLatestLocation(_ id: Int, block: @escaping WSBlock) {
        nprint(items: "---------------- Get Ride Latest Location -----------")
        let relPath = "v1/gettrackingdetail/\(id)"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
}

// MARK: - Driver
extension WebCall {
    
    func getUserDetails(_ id: Int, block: @escaping WSBlock) {
        nprint(items: "---------------- Get User Detail -----------")
        let relPath = "v1/getdriverdetail/\(id)"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
    
    func addUpdateRating(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Add Update Rating & Review -----------")
        let relPath = "v1/addupdaterateandreview"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func getUserRating(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Get Rating & Review -----------")
        let relPath = "v1/getdriverrating"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
}

// MARK: - Chat
extension WebCall {
    
    func getChatHistory(_ param: [String: Any], block: @escaping WSBlock) -> DataRequest? {
        nprint(items: "----------------- Get Chat History  ------------")
        let relPath = "v1/getchatuser"
        return apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func readChatMsg(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "----------------- Read Chat --------------")
        let relPath = "v1/readchatmessage"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
    
    func getChat(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "----------------- Get Chat  ------------")
        let relPath = "v1/getchatmessage"
        apiCall(relPath: relPath, method: .post, param: param, block: block)
    }
    
    func blockUnblockChat(param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "----------------- Block Unblock Chat  ------------")
        let relPath = "v1/blockuser"
        apiCall(relPath: relPath, method: .post, param: param, block: block)
    }
}

// MARK: - SOS
extension WebCall {
    
    func getEmergecyTypes(block: @escaping WSBlock) {
        nprint(items: "---------------- Get Emergency Types -----------")
        let relPath = "v1/getemergencytype"
        apiCall(relPath: relPath, method: .get, param: nil, headerParam: nil, block: block)
    }
    
    func raiseSosAlert(_ param: [String: Any], block: @escaping WSBlock) {
        nprint(items: "---------------- Raise SOS Alert -----------")
        let relPath = "v1/raisealert"
        apiCall(relPath: relPath, method: .post, param: param, headerParam: nil, block: block)
    }
}
