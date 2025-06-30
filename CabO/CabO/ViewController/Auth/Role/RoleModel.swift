//
//  RoleModel.swift
//  CabO
//
//  Created by OctosMac on 23/06/25.
//
import Foundation
import UIKit

enum Role: CaseIterable {
    case driver, rider, subDriver
    
    init(_ ind: Int) {
        switch ind {
        case 1: self = .driver
        case 2: self = .rider
        case 3: self = .subDriver
        default: self = .rider
        }
    }
    init(_ str: String) {
        if str.lowercased() == "driver" {
            self = .driver
        } else if str.lowercased() == "rider" {
            self = .rider
        } else if str.lowercased() == "sub_driver" {
            self = .subDriver
        } else {
            self = .rider
        }
        
    }

    var intValue: Int {
        switch self {
        case .driver: return 1
        case .rider: return 2
        case .subDriver: return 3
        }
    }
    
    var Value: String {
        switch self {
        case .driver: return "driver"
        case .rider: return "rider"
        case .subDriver: return "sub_driver"
        }
    }
}
