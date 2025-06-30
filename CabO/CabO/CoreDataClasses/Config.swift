//
//  Config.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
var AppVersion : String {
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
        return version
    } else {
        return ""
    }
}
// MARK: - Config
class Config {
    
    var admin_email: String!
    private var isEmailOnOff: String!
    private var facebookOnOff: String!
    private var googleOnOff: String!
    private var appleOnOff: String!
    var aws_key: String!
    var aws_secret: String!
    var aws_bucket: String!
    var aws_region: String!
    var stripe_key: String!
    var stripe_secret: String!
    var createRideMinTime: Int!
    var createRideMaxDays: Int!
    var createRideSeatLimit: Int!
    var addCarMaxSeat: Int!
    var addCarMaxImage: Int!
    var currencySign:String! = ""
    var range_min: Int!
    var range_max: Int!
    var subscription_hide: String!
    var ios_latest_version: String!
    var isEmailOn: Bool {
        return true // isEmailOnOff.getBooleanValue()
    }
    
    var isFacebookOn: Bool {
        return facebookOnOff.getBooleanValue()
    }
    var isGoogleOn: Bool {
        return googleOnOff.getBooleanValue()
    }
    var isAppleOn: Bool {
        return appleOnOff.getBooleanValue()
    }
    
    var isSocialLogInOn: Bool {
        return isFacebookOn || isGoogleOn || isAppleOn
    }
    
    var isSubscriptionHide: Bool {
        get{
            if ios_latest_version == AppVersion {
                if subscription_hide.getBooleanValue() {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }
    }
    
    init() {
        if let dict = _userDefault.value(forKey: _CabOConfig) as? NSDictionary {
            admin_email = dict.getStringValue(key: "admin-email").base64Decoded()
            isEmailOnOff = dict.getStringValue(key: "EMAIL_ON_OFF").base64Decoded()
            facebookOnOff = dict.getStringValue(key: "FACEBOOK_ENABLE").base64Decoded()
            googleOnOff = dict.getStringValue(key: "GOOGLE_ENABLE").base64Decoded()
            appleOnOff = dict.getStringValue(key: "APPLE_ENABLE").base64Decoded()
            aws_key = dict.getStringValue(key: "AWS_KEY").base64Decoded()
            aws_secret = dict.getStringValue(key: "AWS_SECRET").base64Decoded()
            aws_bucket = dict.getStringValue(key: "AWS_BUCKET").base64Decoded()
            aws_region = dict.getStringValue(key: "AWS_REGION").base64Decoded()
            stripe_key = dict.getStringValue(key: "STRIPE_KEY").base64Decoded()
            stripe_secret = dict.getStringValue(key: "STRIPE_SECRET").base64Decoded()
            createRideMinTime = dict.getStringValue(key: "CREATE_RIDE_MIN_TIME").base64Decoded()!.integerValue
            createRideMaxDays = dict.getStringValue(key: "CREATE_RIDE_MAX_DAYS").base64Decoded()!.integerValue
            createRideSeatLimit = dict.getStringValue(key: "CREATE_RIDE_SEAT_LIMIT").base64Decoded()!.integerValue
            addCarMaxSeat = dict.getStringValue(key: "ADD_CAR_MAX_SEAT").base64Decoded()!.integerValue
            addCarMaxImage = dict.getStringValue(key: "CAR_MAX_IMG_UPLOAD").base64Decoded()!.integerValue
            range_min = dict.getStringValue(key: "MIN_RIDE_RANGE").base64Decoded()!.integerValue
            range_max = dict.getStringValue(key: "MAX_RIDE_RANGE").base64Decoded()!.integerValue
            currencySign = dict.getStringValue(key: "CURRENCY_SIGN").base64Decoded()
            subscription_hide = dict.getStringValue(key: "SUBSCRIPTION_HIDE").base64Decoded()
            ios_latest_version = dict.getStringValue(key: "IOS_LATEST_VERSION").base64Decoded()
        } else {
            admin_email = ""
            isEmailOnOff = ""
            facebookOnOff = ""
            googleOnOff = ""
            appleOnOff = ""
            aws_key = ""
            aws_secret = ""
            aws_bucket = ""
            aws_region = ""
            stripe_key = ""
            stripe_secret = ""
            createRideMinTime = 5
            createRideMaxDays = 45
            createRideSeatLimit = 3
            addCarMaxSeat = 7
            addCarMaxImage = 8
            range_min = 0
            range_max = 0
            currencySign = ""
            subscription_hide = "no"
            ios_latest_version = ""
        }
    }
    
    init(_ dict: NSDictionary) {
        admin_email = dict.getStringValue(key: "admin-email").base64Decoded()
        isEmailOnOff = dict.getStringValue(key: "EMAIL_ON_OFF").base64Decoded()
        facebookOnOff = dict.getStringValue(key: "FACEBOOK_ENABLE").base64Decoded()
        googleOnOff = dict.getStringValue(key: "GOOGLE_ENABLE").base64Decoded()
        appleOnOff = dict.getStringValue(key: "APPLE_ENABLE").base64Decoded()
        aws_key = dict.getStringValue(key: "AWS_KEY").base64Decoded()
        aws_secret = dict.getStringValue(key: "AWS_SECRET").base64Decoded()
        aws_bucket = dict.getStringValue(key: "AWS_BUCKET").base64Decoded()
        aws_region = dict.getStringValue(key: "AWS_REGION").base64Decoded()
        stripe_key = dict.getStringValue(key: "STRIPE_KEY").base64Decoded()
        stripe_secret = dict.getStringValue(key: "STRIPE_SECRET").base64Decoded()
        ios_latest_version = dict.getStringValue(key: "IOS_LATEST_VERSION").base64Decoded()
        createRideMinTime = dict.getStringValue(key: "CREATE_RIDE_MIN_TIME").base64Decoded()!.integerValue
        createRideMaxDays = dict.getStringValue(key: "CREATE_RIDE_MAX_DAYS").base64Decoded()!.integerValue
        createRideSeatLimit = dict.getStringValue(key: "CREATE_RIDE_SEAT_LIMIT").base64Decoded()!.integerValue
        addCarMaxSeat = dict.getStringValue(key: "ADD_CAR_MAX_SEAT").base64Decoded()!.integerValue
        addCarMaxImage = dict.getStringValue(key: "CAR_MAX_IMG_UPLOAD").base64Decoded()!.integerValue
        range_min = dict.getStringValue(key: "MIN_RIDE_RANGE").base64Decoded()!.integerValue
        range_max = dict.getStringValue(key: "MAX_RIDE_RANGE").base64Decoded()!.integerValue
        currencySign = dict.getStringValue(key: "CURRENCY_SIGN").base64Decoded()
        subscription_hide = dict.getStringValue(key: "SUBSCRIPTION_HIDE").base64Decoded()
        _userDefault.set(self.jsonParam(), forKey: _CabOConfig)
    }
    
    func jsonParam() -> NSDictionary {
        var param: [String: Any] = [:]
        param["admin-email"] = admin_email.base64Encoded()
        param["EMAIL_ON_OFF"] = isEmailOnOff.base64Encoded()
        param["FACEBOOK_ENABLE"] = facebookOnOff.base64Encoded()
        param["GOOGLE_ENABLE"] = googleOnOff.base64Encoded()
        param["APPLE_ENABLE"] = appleOnOff.base64Encoded()
        param["AWS_KEY"] = aws_key.base64Encoded()
        param["AWS_SECRET"] = aws_secret.base64Encoded()
        param["AWS_BUCKET"] = aws_bucket.base64Encoded()
        param["AWS_REGION"] = aws_region.base64Encoded()
        param["STRIPE_KEY"] = stripe_key.base64Encoded()
        param["STRIPE_SECRET"] = stripe_secret.base64Encoded()
        param["CREATE_RIDE_MIN_TIME"] = "\(createRideMinTime!)".base64Encoded()
        param["CREATE_RIDE_MAX_DAYS"] = "\(createRideMaxDays!)".base64Encoded()
        param["CREATE_RIDE_SEAT_LIMIT"] = "\(createRideSeatLimit!)".base64Encoded()
        param["ADD_CAR_MAX_SEAT"] = "\(addCarMaxSeat!)".base64Encoded()
        param["CAR_MAX_IMG_UPLOAD"] = "\(addCarMaxImage!)".base64Encoded()
        param["MIN_RIDE_RANGE"] = "\(range_min!)".base64Encoded()
        param["MAX_RIDE_RANGE"] = "\(range_max!)".base64Encoded()
        param["CURRENCY_SIGN"] = currencySign.base64Encoded()
        param["SUBSCRIPTION_HIDE"] = subscription_hide.base64Encoded()
        param["IOS_LATEST_VERSION"] = ios_latest_version.base64Encoded()
        return param as NSDictionary
    }
}

// MARK: - UpdateModel

enum UpdateType: String {
    case optional = "0", force = "1"
}

class UpdateModel {
    let maxVersion: String
    let minVersion: String
    let updateType: UpdateType
    let message: String
    
    init(dict: NSDictionary, message: String = "It looks like you are using an older version of the app. Please update to get latest features and best experience.") {
        maxVersion = dict.getStringValue(key: "ios_max_version")
        minVersion = dict.getStringValue(key: "ios_min_version")
        self.message = message
        updateType = UpdateType(rawValue: dict.getStringValue(key: "ios_force_update"))!
    }
}
