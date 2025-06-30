//
//  InfoPopoverVC.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - InfoPopoverVC
class InfoPopoverVC: ParentVC {
    
    /// Variables
    var message: String!
    
    /// View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle?.text = message
    }
}
