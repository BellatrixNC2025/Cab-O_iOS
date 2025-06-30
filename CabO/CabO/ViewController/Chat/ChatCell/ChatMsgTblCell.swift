//
//  ChatSendMsgTblCell.swift

import UIKit

class ChatMsgTblCell: ConstrainedTableViewCell {

    ///Outlets
    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var tailImg: UIImageView!
    
    /// Variables
    var action_image_preview: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func btnIMageTap(_ sender: UIButton) {
        action_image_preview?()
    }
}

//MARK: - UI Related methods
extension ChatMsgTblCell {
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "ChatSendMsgTblCell", bundle: nil), forCellReuseIdentifier: "sendMsgCell")
        sender.register(UINib(nibName: "ChatReceiveMsgTblCell", bundle: nil), forCellReuseIdentifier: "receiveMsgCell")
        sender.register(UINib(nibName: "ChatSendImgTblCell", bundle: nil), forCellReuseIdentifier: "sendImgCell")
        sender.register(UINib(nibName: "ChatReceiveImgTblCell", bundle: nil), forCellReuseIdentifier: "receiveImgCell")
        sender.register(UINib(nibName: "ChatHeaderTblCell", bundle: nil), forCellReuseIdentifier: "headerChatCell")
    }
}
