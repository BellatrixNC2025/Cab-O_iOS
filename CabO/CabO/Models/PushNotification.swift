//
//  PushNotification.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - Push Notification Screen Rediraction
enum PushToScreenType {
    
    case chat_list
    case support_list
    case id_verification
    case car_detail
    
    case ride_create_details
    case ride_book_details
    case ride_history_list
    
    case request_carpool
    case card_list
    
    case invitation_list
    case bank_details
    
    case none
    
}

// MARK: - Push Notification Rediraction Key
enum PushType: String {
    case chat_message                           = "chat_notification"
    
    case support_create                         = "support_ticket_create"
    case support_resolve                        = "support_ticket_-_when_admin_resolve"
    case support_decline                        = "support_ticket_when_admin_declines"
    
    case payment_failed                         = "payment_failed_to_user"
    
    case id_accept                              = "verify_id_accepted"
    case id_expiring                            = "driving_license_expiring_soon"
    case id_reject                              = "verify_id_rejected"
    
    case car_reg_approved                       = "car_registration_approved"
    case car_reg_expiring                       = "car_registration_expiring_soon"
    case car_reg_rejected                       = "car_rejected_for_car_registration"
    case car_ins_approved                       = "car_insurance_card_approved"
    case car_ins_expiring                       = "car_insurance_expiring_soon"
    case car_ins_rejected                       = "car_rejected_for_insurance_card"
    
    case ride_booking_request_new               = "when_rider_sends_a_request_for_a_ride_to_driver"
    case ride_booking_request_rejected          = "when_driver_reject_the_ride_request_to_rider"
    case ride_booking_request_accepted          = "accept_ride_request_to_rider"
    case ride_booking_request_cancelled         = "when_rider_cancel_the_ride_send_notification_to_driver"
    
    case ride_created_auto_cancelled            = "ride_auto_cancelled_to_driver"
    case ride_created_end                       = "main_ride_ends_to_driver"
    case ride_booked_cancelled                  = "when_driver_cancel_the_ride_send_notification_to_driver"
    
    case ride_booked_main_start                 = "when_driver_starts_the_main_ride_to_every_rider"
    case ride_booked__start                     = "individual_ride_start_to_rider"
    case ride_booked_auto_cancelled             = "ride_auto_cancelled_to_rider"
    case ride_booked_auto_reject                = "ride_auto_rejected_to_rider"
    case ride_booked_end                        = "individual_ride_end_to_rider"
    
    case ride_created_reminder                  = "before_one_hour_reminder_trip_to_driver"
    case ride_booked_reminder                   = "before_one_hour_reminder_trip_to_rider"
    
    case ride_verification_code                 = "riders_receive_the_verification_code_to_rider"
    
    case request_carppol                        = "ride_alert_notification_(create_alert)"
    case driver_invite_for_ride                 = "when_driver_invite_to_rider"
    
    case bank_verification_reminder             = "bank_verification_reminder_notification"
    
    case none                                   = ""
    
    var screenType: PushToScreenType {
        switch self {
            
        case .chat_message:
            return .chat_list
            
        case .payment_failed:
            return .card_list
            
        case .support_resolve, .support_decline, .support_create:
            return .support_list
            
        case .id_accept, .id_expiring, .id_reject:
            return .id_verification
            
        case .car_reg_approved, .car_reg_expiring, .car_reg_rejected, .car_ins_approved, .car_ins_expiring, .car_ins_rejected:
            return .car_detail
            
        case .ride_booking_request_new, .ride_created_auto_cancelled, .ride_created_end, .ride_created_reminder, .ride_booking_request_cancelled:
            return .ride_create_details
            
        case .ride_booking_request_accepted, .ride_booked_main_start, .ride_booked__start, .ride_booked_auto_cancelled, .ride_booked_auto_reject, .ride_booked_end, .ride_booked_reminder, .ride_verification_code, .ride_booking_request_rejected, .ride_booked_cancelled:
            return .ride_book_details
            
        case .driver_invite_for_ride:
            return .invitation_list
            
        case .request_carppol:
            return .request_carpool
            
        case .bank_verification_reminder:
            return .bank_details
            
        default:
            return .none
        }
    }
    
    var isPastRideDetails: Bool {
        if EnumHelper.checkCases(self, cases: [.ride_created_auto_cancelled, .ride_created_end, .ride_booked_auto_cancelled, .ride_booked_auto_reject, .ride_booking_request_rejected, .ride_booked_end, .ride_booked_cancelled]) {
            return true
        }
        return false
    }
    
    var shouldUpdateList: Bool {
        if EnumHelper.checkCases(self, cases: [.ride_created_auto_cancelled, .ride_created_end, .ride_booking_request_accepted, .ride_booking_request_rejected, .ride_booked_main_start, .ride_booked__start, .ride_booked_auto_cancelled, .ride_booked_auto_reject, .ride_booked_end, .ride_booking_request_cancelled, .ride_booked_cancelled]) {
            return true
        }
        return false
    }
}

// MARK: - Push Notification Model
class PushNotification {
    
    let msgId: String
    let id: String
    var userId: String?
    let title: String
    var text: String
    var type: PushType
    var img: String = ""
    
    init?(dict: NSDictionary) {
        msgId = dict.getStringValue(key: "gcm.message_id")
        
        title = dict.getStringValue(key: "title")
        text = dict.getStringValue(key: "text")
        img = dict.getStringValue(key: "user_image")
        if let type = PushType(rawValue: dict.getStringValue(key: "redirect_key")) {
            self.type = type
            userId = dict.getStringValue(key: "user_id")
            id = dict.getStringValue(key: "redirection_id")
            if type == .chat_message {
                text = dict.getStringValue(key: "message")
            }
        } else {
            return nil
        }
    }
}


//MARK: PopBannerDetails Model
class AdDetails {
    
    var fileType: String = ""
    var image: String = "https://picsum.photos/200/300"
    var url: String = "https://picsum.photos/200/300"
    var seconds: Int = 3
    var position: Int = 1
    
    var imgUrl: URL { URL(string: image)! }
    
    var redirectUrl: URL { URL(string: url)! }
    
    init() {
        
    }
    
    init(dict: NSDictionary) {
        fileType = dict.getStringValue(key: "file_type")
        image = dict.getStringValue(key: "image")
        url = dict.getStringValue(key: "url")
        position = dict.getIntValue(key: "position")
        seconds = dict.getIntValue(key: "seconds")
    }
}

