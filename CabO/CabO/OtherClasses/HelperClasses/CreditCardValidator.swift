//
//  CreditCardValidator.swift
//
//  Created by Vitaliy Kuzmenko on 02/06/15.
//  Copyright (c) 2015. All rights reserved.
//

import Foundation
import UIKit

public func ==(lhs: CreditCardValidationType, rhs: CreditCardValidationType) -> Bool {
    return lhs.name == rhs.name
}

public struct CreditCardValidationType: Equatable {
    
    public var name: String
    
    public var regex: String

    public init(dict: [String: AnyObject]) {
        if let name = dict["name"] as? String {
            self.name = name
        } else {
            self.name = ""
        }
        
        if let regex = dict["regex"] as? String {
            self.regex = regex
        } else {
            self.regex = ""
        }
    }
    
}

public class CreditCardValidator {
    
    static let shared = CreditCardValidator()
    
    public lazy var types: [CreditCardValidationType] = {
        var types = [CreditCardValidationType]()
        for object in CreditCardValidator.types {
            types.append(CreditCardValidationType(dict: object as [String : AnyObject]))
        }
        return types
    }()
    
    public init() { }
    
    /**
     Get card type from string
     
     - parameter string: card number string
     
     - returns: CreditCardValidationType structure
     */
    // card validation
    public func typeFromString(string: String) -> CreditCardValidationType? {
        for type in types {
            let predicate = NSPredicate(format: "SELF MATCHES %@", type.regex)
            let _ = self.onlyNumbersFromString(string: string)
            if predicate.evaluate(with: string) {
                return type
            }
        }
        return nil
    }
    
    /**
     Validate card number
     
     - parameter string: card number string
     
     - returns: true or false
     */
        public func validateString(string: String) -> Bool {
        let numbers = self.onlyNumbersFromString(string: string)
        if numbers.count < 9 {
            return false
        }
        
        var reversedString = ""
        let range = Range(uncheckedBounds: (numbers.startIndex,numbers.endIndex))
        numbers.enumerateSubstrings(in: range, options: [NSString.EnumerationOptions.reverse, NSString.EnumerationOptions.byComposedCharacterSequences]){(substring, substringRange, enclosingRange, stop) -> () in
            reversedString += substring!
        }
        
        var oddSum = 0, evenSum = 0
        let reversedArray = reversedString
        let i = 0
        
        for s in reversedArray {
            
            let digit = Int(String(s))!
            
            if (i+1) % 2 == 0 {
                evenSum += digit
            } else {
                oddSum += digit / 5 + (2 * digit) % 10
            }
        }
        return (oddSum + evenSum) % 10 == 0
    }
    
    /**
     Validate card number string for type
     
     - parameter string: card number string
     - parameter type:   CreditCardValidationType structure
     
     - returns: true or false
     */
    public func validateString(string: String, forType type: CreditCardValidationType) -> Bool {
        return typeFromString(string: string) == type
    }
    
    public func onlyNumbersFromString(string: String) -> String {
        let set = CharacterSet.decimalDigits.inverted
        let numbers = string.components(separatedBy: set)
        return numbers.joined(separator: "")
    }
    
    // MARK: - Loading data
    
    private static let types = [
        [
            "name": "American Express",
            "regex": "^3[47][0-9]{5,}$"
        ], [
            "name": "Visa",
            "regex": "^4[0-9]{6,}$"
        ], [
            "name": "MasterCard",
            "regex": "^5[1-5][0-9]{5,}$"
        ], [
            "name": "Maestro",
            "regex": "^(?:5[0678]\\d\\d|6304|6390|67\\d\\d)\\d{8,15}$"
        ], [
            "name": "Diners Club",
            "regex": "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
        ], [
            "name": "JCB",
            "regex": "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"
        ], [
            "name": "Discover",
            "regex": "^6(?:011|5[0-9]{2})[0-9]{3,}$"
        ], [
            "name": "UnionPay",
            "regex": "^62[0-5]\\d{13,16}$"
        ]
    ]
    
}

enum CardType {
    case americanExpress, visa, mastercard, maestro, dinersClub, jcb, discover, unionPay, none
    
    init(_ str: String) {
        switch str.lowercased() {
        case "americanexpress": self = .americanExpress
        case "visa": self = .visa
        case "mastercard": self = .mastercard
        case "maestro": self = .maestro
        case "dinersclub": self = .dinersClub
        case "jcb": self = .jcb
        case "discover": self = .discover
        case "unionpay": self = .unionPay
        default: self = .none
        }
    }
    
    var image: UIImage? {
        switch self {
        case .americanExpress: return UIImage(named: "card_amex")
        case .discover: return UIImage(named: "card_discover")
        case .jcb: return UIImage(named: "card_jcb")
        case .unionPay: return UIImage(named: "card_unionpay_en")
        case .visa: return UIImage(named: "card_visa")
        case .mastercard: return UIImage(named: "mastercard")
        default: return nil
        }
    }
}
