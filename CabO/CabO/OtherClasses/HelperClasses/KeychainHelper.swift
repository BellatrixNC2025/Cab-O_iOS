//
//  KeychainHelper.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit
import Security

class KeyChain {

    class func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data ] as [String : Any]

        SecItemDelete(query as CFDictionary)

        return SecItemAdd(query as CFDictionary, nil)
    }

    class func load(key: String) -> Data? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]

        var dataTypeRef: AnyObject? = nil

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }

    class func createUniqueID() -> String {
        let uuid: CFUUID = CFUUIDCreate(nil)
        let cfStr: CFString = CFUUIDCreateString(nil, uuid)

        let swiftString: String = cfStr as String
        return swiftString
    }
    
    public class func logout()  {
        let secItemClasses =  [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity,
        ]
        for itemClass in secItemClasses {
            let spec: NSDictionary = [kSecClass: itemClass]
            SecItemDelete(spec)
        }
    }
}


//func convertIntoData(obj : String) -> Data {
//    let data = Data(obj.utf8) //Data(from: obj)
//    return data
//}

extension Data {

    var decodeData:String{
        return String(decoding: self, as: UTF8.self)
    }
    
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }

    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.load(as: T.self) }
    }
}
