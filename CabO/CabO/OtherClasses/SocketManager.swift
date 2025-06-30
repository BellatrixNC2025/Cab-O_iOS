//
//  SocketManager.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import SocketIO
import CoreLocation

// Observers
extension Notification.Name {
    //Status Change
    static let observerSocketConnectionStateChange
        = NSNotification.Name("KSocketconnectionStateChange")
    //Join Chat
    static let observerSocketJoinChat
        = NSNotification.Name("observerSocketJoinChat")
    //Leave Chat
    static let observerSocketLeaveChat
        = NSNotification.Name("observerSocketLeaveChat")
    //Send Messages
    static let observerSocketSendMessage
        = NSNotification.Name("observerSocketSendMessage")
    //Somthing Went Wrong
    static let observerSocketWentWrong
        = NSNotification.Name("observerSocketWentWrong")
    //Join Ride Tracking
    static let observerSocketJoinRideTracking
        = NSNotification.Name("observerSocketJoinRideTracking")
    //Leave Ride Tracking
    static let observerSocketLeaveRideTracking
        = NSNotification.Name("observerSocketJoinRideTracking")
    //Send Messages
    static let observerSocketSendRideLocation
        = NSNotification.Name("observerSocketSendRideLocation")
}

//Channel String
enum KSocketChannel: String {
    case join_chat = "join_room"
    case leave_chat = "leave_room"
    case message = "chat_message"
    case went_wrong = "went-wrong"
    case join_tracking = "join_track_room"
    case leave_tracking = "disconnect_tracking"
    case ride_tracking = "ride_track"
}

//Blocks
typealias KSocketEmitBlock = (_ json: Any?) -> ()
typealias KSocketBlock = (_ json: Any?, _ channel: KSocketChannel) -> ()

//MARK: - KSocketManager
class KSocketManager: NSObject {
    
    //Share Instance
    static var shared: KSocketManager = KSocketManager()
    
    //Socket Manager
    lazy var manager: SocketManager = {
        return SocketManager(socketURL: _socket_url , config: [.log(true), .compress, .version(.two)])
    }()
    
    //Socket Clinet Obj
    lazy var socket: SocketIOClient = {
        return manager.defaultSocket
    }()
    
    //Connection Status
    var connectionStatus: SocketIOStatus { return socket.status }

    override init() {
        super.init()
        socket.connect()
        self.addConnectionListner()
    }

    deinit {
        _defaultCenter.removeObserver(self)
        debugPrint("Deallocated: \(self.classForCoder)")
    }
}
// MARK: - Class Methods
extension KSocketManager {
    
    //Reset the Socket Manager
    class func resetup() {
        KSocketManager.shared = KSocketManager()
    }
    
    //Connect Socket
    class func connect() {
        KSocketManager.shared.socket.connect()
    }
    
    //Disconnect Socket
    class func disconnect() {
        KSocketManager.shared.socket.disconnect()
    }
}

// MARK: - Listner Methods
extension KSocketManager {
    
    //Add Connection Listner
    func addConnectionListner() {
        statusListner()
        dataListner()
    }
    
    //Status Change Listners
    func statusListner() {
        socket.on(clientEvent: SocketClientEvent.connect) { [weak self] (obj, ack) in
            guard let weakSelf = self else { return }
            debugPrint("Socket Connected")
            weakSelf.dataListner()
        }
        
        socket.on(clientEvent: SocketClientEvent.error) { [weak self] (obj, ack) in
            guard let _ = self else { return }
            debugPrint("Error : \(obj.debugDescription)")
        }
        
        socket.on(clientEvent: SocketClientEvent.disconnect) { [weak self] (obj, ack) in
            guard let _ = self else { return }
            debugPrint("Socket Disconnected")
        }
        
        socket.on(clientEvent: SocketClientEvent.statusChange) { [weak self] (obj, ack) in
            guard let weakSelf = self else { return }
            debugPrint("Status : \(weakSelf.socket.status.description)")
            _defaultCenter.post(name: .observerSocketConnectionStateChange, object: obj)
        }
    }
    
    //Data Listners
    func dataListner() {
        //Any Type of socket on methods
        socket.onAny { (anyEvent) in
//            debugPrint("@AnyEvent.event: \(anyEvent.event)")
//            debugPrint("@AnyEvent.items: \(String(describing: anyEvent.items))")
            if  let event = KSocketChannel(rawValue: anyEvent.event){
                switch event {
                case .join_chat:
                    _defaultCenter.post(name: .observerSocketJoinChat, object: anyEvent.items)
                    break
                case .leave_chat:
                    _defaultCenter.post(name: .observerSocketLeaveChat, object: anyEvent.items)
                    break
                case .message:
                    _defaultCenter.post(name: .observerSocketSendMessage, object: anyEvent.items)
                    break
                case .went_wrong:
                    _defaultCenter.post(name: .observerSocketWentWrong, object: anyEvent.items)
                    break
                case .join_tracking:
                    _defaultCenter.post(name: .observerSocketJoinRideTracking, object: anyEvent.items)
                    break
                case .leave_tracking:
                    _defaultCenter.post(name: .observerSocketLeaveRideTracking, object: anyEvent.items)
                    break
                case .ride_tracking:
                    _defaultCenter.post(name: .observerSocketSendRideLocation, object: anyEvent.items)
                    break
                }
            }
        }
    }
}

// MARK: - Emit Methods
extension KSocketManager {
    
    //Emit With ACK
     func emitWitAck(channel: String, param: [String: Any], block: @escaping KSocketEmitBlock) {
        if socket.status == .connected {
            socket.emitWithAck(channel, with: [param]).timingOut(after: 0, callback: { (data) in
                debugPrint("obj: \(data)")
                block(data)
            })
        } else {
            KSocketManager.connect()
            block(nil)
        }
    }

    //Emit Without ACK
    fileprivate func emit(channel: String, param: [String: Any]) {
        if socket.status == .connected {
            debugPrint("EMIT Connect: \(param)")
            socket.emit(channel, with: [param], completion: nil)
        } else {
            debugPrint("EMIT Disconnect: \(param)")
            KSocketManager.connect()
        }
    }
}

//MARK: - Other Methods
extension KSocketManager{

    //Join the chat room
    func joinChat(id: String) {
        debugPrint("----------- JOIN CHAT -------------")
        var param: [String: Any] = [:]
        param["from_id"] = _user!.id
        param["to_id"] = id
        self.emit(channel: KSocketChannel.join_chat.rawValue, param: param)
    }
    
    //Leave the chat room
    func leaveChat(id: String) {
        debugPrint("----------- LEAVE CHAT -------------")
        var param: [String: Any] = [:]
        param["chat_room"] = id
        self.emit(channel: KSocketChannel.leave_chat.rawValue, param: param)
    }
    
    //Send the Msg
    func requestSendMessage(_ to: String, message: String, media_name: String? = nil, messageType type: ChatMsgType, roomID: String) {
        debugPrint("----------- REQUEST SEND MESSGAE -------------")
        var param: [String: Any] = [
            "from_id": _user!.id,
            "to_id": to,
            "content": message,
            "chat_room": roomID,
            "message_type": type.rawValue
        ]
        if let media_name {
            param["media_name"] = media_name
        }
        self.emit(channel: KSocketChannel.message.rawValue , param: param)
    }
    
    //Join the ride tracking
    func joinTracking(id: Int) {
        debugPrint("----------- JOIN RIDE TRACKING -------------")
        var param: [String: Any] = [:]
        param["ride_id"] = id
        self.emit(channel: KSocketChannel.join_tracking.rawValue, param: param)
    }
    
    //Leave the ride tracking
    func leaveTracking(id: Int) {
        debugPrint("----------- LEAVE RIDE TRACKING -------------")
        var param: [String: Any] = [:]
        param["ride_id"] = id
        self.emit(channel: KSocketChannel.leave_tracking.rawValue, param: param)
    }
    
    //Send the ride location
    func requestSendRideLocation(rideId: Int, location: CLLocation, roomID: String) {
        debugPrint("----------- REQUEST SEND RIDE LOCATION -------------")
        let param: [String: Any] = [
            "ride_id": rideId,
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "heading": location.course,
            "track_room_id": roomID
        ]
        self.emit(channel: KSocketChannel.ride_tracking.rawValue , param: param)
    }
}
