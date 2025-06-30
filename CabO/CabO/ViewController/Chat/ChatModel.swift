//
//  ChatModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - ChatMsgType
enum ChatMsgType: String {
    case text = "text", media = "media"
}

// MARK: - ChatHistory
class ChatHistory {
    
    let id: String
    var roomId: String?
    let userName: String
    var messageType: ChatMsgType
    var message: String
    var date: Date
    let userImage: String
    var unReadCount: Int
    
    var profileImage: URL? {
        return URL(string: userImage)
    }
    
    var timeStr: String {
        if date.isToday {
            return Date.localDateString(from: date, format: "hh:mm aa").uppercased()
        }
        return date.getChatSectionHeader()
    }
    
    var chatCount: String {
        return unReadCount > 99 ? "99+" : unReadCount.stringValue
    }
    
    init(_ driver: DriverModel) {
        id = driver.id.stringValue
        userName = driver.fullName
        userImage = driver.img
        messageType = .text
        message = ""
        date = Date()
        unReadCount = 0
    }
    
    init(_ push: PushNotification) {
        id = push.id
        userName = push.title
        userImage = push.img
        messageType = .text
        message = push.text
        date = Date()
        unReadCount = 0
    }
    
    init(_ driver: BookingRequestDetailModel) {
        id = driver.userId.stringValue
        userName = driver.fullName
        userImage = driver.image
        messageType = .text
        message = ""
        date = Date()
        unReadCount = 0
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "user_id")
        userImage = dict.getStringValue(key: "image")
        userName = dict.getStringValue(key: "user_name")
        message = dict.getStringValue(key: "content")
        messageType = ChatMsgType.init(rawValue: dict.getStringValue(key: "message_type")) ?? .text
        
        let dDate = Date.dateFromServerFormat(from: dict.getStringValue(key: "created_at"), format: DateFormat.serverDateTimeFormat)!
        date = dDate.getUtcDate()!.getTimeZoneDate()!
        
        unReadCount = dict.getIntValue(key: "unreadcount")
    }
}

// MARK: - ChatMessage
class ChatMessage: NSObject {
    let id: String
    let senderID: String
    let receiverID: String
    let msgType: ChatMsgType
    let message: String
    let date: Date
    var tempImage: UIImage?
    
    var isSentByMe: Bool {
        return senderID == _user!.id
    }
    
    var image: URL? {
        return URL(string: message)
    }
    
    var timeStr: String {
        return Date.localDateString(from: date, format: "hh:mm aa").uppercased()
    }
    
    init(dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        senderID = dict.getStringValue(key: "from_id")
        receiverID = dict.getStringValue(key: "to_id")
        message = dict.getStringValue(key: "content")
        msgType = ChatMsgType(rawValue: dict.getStringValue(key: "message_type")) ?? .text
        let dat = dict.getStringValue(key: "created_at")
        if !dat.isEmpty {
            let dDate = Date.dateFromServerFormat(from: dat, format: DateFormat.serverDateTimeFormat)!
            date = dDate.getUtcDate()!.getTimeZoneDate()!
        } else {
            date = Date()
        }
    }
    
    init(receiverId: String, msgType: ChatMsgType, message: String) {
        self.id = "0"
        self.senderID = _user!.id
        self.receiverID = receiverId
        self.msgType = msgType
        self.message = message
        self.date = Date()
    }
    
    init(_ push: PushNotification) {
        self.id = "0"
        self.senderID = push.id
        self.receiverID = _user!.id
        self.msgType = .text
        self.message = push.text
        self.date = Date()
    }
    
    init(localDict: NSDictionary, image: UIImage?, autoID: Int?) {
        id = ""
        senderID = _user!.id
        receiverID = localDict.getStringValue(key: "to_id")
        message = localDict.getStringValue(key: "content")
        msgType = ChatMsgType(rawValue: localDict.getStringValue(key: "message_type")) ?? .text
        date = Date()
        tempImage = image
//        time = Date.dateFromLocalFormat(from: dict.getStringValue(key: "time"), format: "HH:mm:ss")!
    }
    
    init(msg: NSDictionary) {
        id = msg.getStringValue(key: "id")
        senderID = msg.getStringValue(key: "from_id")
        receiverID = msg.getStringValue(key: "to_id")
        message = msg.getStringValue(key: "content")
        msgType = ChatMsgType(rawValue: msg.getStringValue(key: "message_type")) ?? .text
        let dat = msg.getStringValue(key: "created_at")
        if !dat.isEmpty {
            let dDate = Date.dateFromServerFormat(from: dat, format: DateFormat.serverDateTimeFormat)!
            date = dDate.getUtcDate()!.getTimeZoneDate()!
        } else {
            date = Date()
        }
    }

    override func isEqual(_ object: Any?) -> Bool {
        let obj = object as! ChatMessage
        return obj.id == self.id
    }
}

// MARK: - ChatMsgSection
class ChatMsgSection {
    let date: Date
    let messages: [ChatMessage]
    
    init(date: Date, arr: [ChatMessage]) {
        self.date = date
        self.messages = arr.sorted(by: { (msg1, msg2) -> Bool in
            return msg1.date < msg2.date
        })
    }
}

