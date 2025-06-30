//
//  RoleVC.swift
//  CabO
//
//  Created by OctosMac on 23/06/25.
//

import UIKit

class RoleVC: ParentVC {
    /// Outlets
    @IBOutlet weak var btnDriver: UIButton!
    @IBOutlet weak var btnRider: UIButton!
    /// Variables
    var data = SignUpData()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /// Actions
    @IBAction func btnTapAction(sender: UIButton) {
        if sender == self.btnRider {
            self.data.role = .rider
        }else{
            self.data.role = .driver
        }
        let vc = SignUpVC.instantiate(from: .Auth)
        vc.data = self.data
        vc.screenType = .profile
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
