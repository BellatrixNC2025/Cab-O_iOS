
import Foundation
import CoreData

// MARK: - Core Data User
class User: NSManagedObject, ParentManagedObject {
    
    @NSManaged var id: String
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var profilePic: String
    @NSManaged var mobileNumber: String
    @NSManaged var emailAddress: String
    @NSManaged var joinDate: Date
    @NSManaged var userVerify: Bool
    @NSManaged var allowDelete: Bool
    @NSManaged var isSocialUser: Bool
    @NSManaged var pushNotify: Bool
    @NSManaged var textNotify: Bool
    @NSManaged var roleValue: String
    @NSManaged var emailVerify: Bool
    @NSManaged var mobileVerify: Bool
    
//    var isSubscribed: Bool = false
    
    var fullName: String {
        return firstName + " " + lastName
    }
    var role: Role {
        return Role(roleValue)
    }
    func initWith(_ dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        firstName = dict.getStringValue(key: "first_name")
        lastName = dict.getStringValue(key: "last_name")
        mobileNumber = dict.getStringValue(key: "mobile")
        emailAddress = dict.getStringValue(key: "email")
        profilePic = dict.getStringValue(key: "image")
        joinDate = Date.dateFromServerFormat(from: dict.getStringValue(key: "created_at")) ?? Date()
        userVerify = dict.getBooleanValue(key: "is_verified")
        allowDelete = dict.getBooleanValue(key: "is_allow_delete_account")
        isSocialUser = dict.getBooleanValue(key: "is_social_user")
        roleValue = dict.getStringValue(key: "role")
        emailVerify = dict.getBooleanValue(key: "email_verify")
        mobileVerify = dict.getBooleanValue(key: "mobile_verify")
//        isSubscribed = dict.getBooleanValue(key: "isSubscription")
//        pushNotify = true
//        textNotify = true
    }
}
