//
//  NotificationPermissionVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class NotificationPermissionVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var swtchPush: UISwitch!
    @IBOutlet weak var swtchText: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swtchPush?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        swtchText?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
}

// MARK: - Button Actions
extension NotificationPermissionVC {
    
    @IBAction func btnSkipTap(_ sender: UIButton) {
        _appDelegator.navigateUserToHome()
    }
    
    @IBAction func btnNextTap(_ sender: UIButton) {
        _appDelegator.navigateUserToHome()
    }
}
