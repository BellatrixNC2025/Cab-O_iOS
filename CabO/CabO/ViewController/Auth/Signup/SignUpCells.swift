//
//  Untitled.swift
//  CabO
//
//  Created by OctosMac on 20/06/25.
//
import UIKit

// MARK: - SignUpCell
class SignUpCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: NLinkLabel!
    @IBOutlet weak var btnCheck: UIButton!{
        didSet{
            btnCheck.setImage(UIImage(systemName: "square")!.withTintColor(AppColor.appBg), for: .normal)
            btnCheck.setImage(UIImage(systemName: "checkmark.square.fill")!.withTintColor(AppColor.appBg), for: .selected)
        }
    }
 
    var action_check: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func btnCheckTap(_ sender: UIButton) {
        self.action_check!()
    }
}
// MARK: - SignUpCell
class SignUpSelectionCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnS1: NRoundButton!
    @IBOutlet weak var btnS2: NRoundButton!
    
    var action_selection: ((Int) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    func prepareUI(  type: SignUpCells) {
        lblTitle.text = type.inputTitle
        if type == .role {
            self.btnS1.setBackgroundImage(UIImage.createImageWithColor(color: AppColor.textfieldBgDark, size: self.btnS1.frame.size), for: .normal)
            self.btnS2.setBackgroundImage(UIImage.createImageWithColor(color: AppColor.textfieldBgDark, size: self.btnS2.frame.size), for: .normal)
            self.btnS1.setBackgroundImage(UIImage.createImageWithColor(color: AppColor.roleBgGreen, size: self.btnS1.frame.size), for: .selected)
            self.btnS2.setBackgroundImage(UIImage.createImageWithColor(color: AppColor.roleBgGreen, size: self.btnS2.frame.size), for: .selected)
        }else{
            self.btnCheckTap(btnS1)
        }
        
    }
    @IBAction func btnCheckTap(_ sender: UIButton) {
        if sender == btnS1 {
            btnS1.borderColor = AppColor.themeGreen
            btnS2.borderColor = AppColor.primaryTextDark
            btnS1.isSelected = true
            btnS2.isSelected = false
        }else{
            btnS2.borderColor = AppColor.themeGreen
            btnS1.borderColor = AppColor.primaryTextDark
            btnS1.isSelected = false
            btnS2.isSelected = true
        }
        
        self.action_selection?(sender.tag)
    }
}
