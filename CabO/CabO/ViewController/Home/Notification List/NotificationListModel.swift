//
//  NotificationListModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

class NotificationListModel {

    var display_flag: Int!
    var display_type: String!
    var title: String!
    var desc: String!
    var date: Date!
    var image: String!
    var redirect_key: String!
    var user_name: String!

    init(_ dict: NSDictionary) {
        display_flag = dict.getIntValue(key: "display_flag")
        display_type = dict.getStringValue(key: "display_type")
        title = dict.getStringValue(key: "")
        desc = dict.getStringValue(key: "message")
        image = dict.getStringValue(key: "image")
        redirect_key = dict.getStringValue(key: "redirect_key")
        date = Date.dateFromServerFormat(from: dict.getStringValue(key: "notification_date"), format: DateFormat.serverDateTimeFormat)
        user_name = dict.getStringValue(key: "user_name")
    }
}

// MARK: - NotificationListCell
class NotificationListCell: UITableViewCell {
    
    /// Outlets
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var txtDesc: UITextView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblDate: UILabel!

    override func awakeFromNib() {
        txtDesc?.isEditable = false
        txtDesc?.isScrollEnabled = false
        txtDesc?.font = AppFont.fontWithName(.regular, size: 12 * _fontRatio)
        let textContainer = txtDesc?.textContainer
        if let textContainer {
            textContainer.exclusionPaths = [UIBezierPath(rect: CGRect(x: 0, y: 0, width: (42 * _widthRatio), height: (40 * _widthRatio)))]
        }
    }
}
