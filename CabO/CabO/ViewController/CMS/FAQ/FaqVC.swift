//
//  FaqVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

// MARK: - FaqModel
struct FaqModel {
    
    var title: String = ""
    var description: String = ""
    
    init() { }
    
    init(_ dict: NSDictionary) {
        title = dict.getStringValue(key: "question")
        description = dict.getStringValue(key: "answer")
    }
}

// MARK: - FaqCell
class FaqCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var imgRight: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: - FaqVC
class FaqVC: ParentVC {
    
    /// Variables
    var selectedIndex: Int?
    var arrFaq: [FaqModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: (12 * _widthRatio), left: 0, bottom: 50, right: 0)
        getFaqList()
    }
}

// MARK: - TableView Methods
extension FaqVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFaq != nil ? arrFaq.count : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
//        let faq = arrFaq[indexPath.row]
//        var height = faq.title.heightWithConstrainedWidth(width: _screenSize.width - (74 * _widthRatio), font: AppFont.fontWithName(.mediumFont, size: 16 * _fontRatio))
//        if let selectedIndex, selectedIndex == indexPath.row {
//            height += faq.description.heightWithConstrainedWidth(width: _screenSize.width - (40 * _widthRatio), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio)) + (24 * _heightRatio)
//        }
//        return height + (24 * _heightRatio)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "faqCell", for: indexPath) as! FaqCell
        let faq = arrFaq[indexPath.row]
        
        cell.labelTitle.text = faq.title
        cell.labelDescription.text = faq.description
//        cell.labelDescription.attributedText = faq.description.removeHTMLTag()
        
        cell.labelDescription.isHidden = selectedIndex != nil ? selectedIndex! != indexPath.row : true
        cell.imgRight.image = cell.labelDescription.isHidden ? UIImage(systemName: "plus")?.withTintColor(AppColor.primaryText) : UIImage(systemName: "minus")?.withTintColor(AppColor.primaryText)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndex != indexPath.row {
            selectedIndex = indexPath.row
        } else {
           selectedIndex = nil
        }
        tableView.reloadData()
    }
}

// MARK: - API Calls
extension FaqVC {
    
    func getFaqList() {
        showCentralSpinner()
        WebCall.call.getFaqDetails() { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            self.arrFaq = []
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? [NSDictionary]  {
                for fq in data {
                    self.arrFaq.append(FaqModel(fq))
                }
                self.tableView.reloadData()
                
                let cells = self.tableView.visibleCells(in: 0)
                UIView.animate(views: cells, animations: [self.tableLoadAnimation])
            } else {
                showError(data: json)
            }
        }
    }
}
