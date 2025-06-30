//
//  ReviewsVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

// MARK: - ReviewModel
class ReviewModel {
    
    var fName: String!
    var lName: String!
    var image: String!
    var rating: Double!
    var review: String!
    
    var fullName: String {
        return fName + " " + lName
    }
    
    init(_ dict: NSDictionary) {
        fName = dict.getStringValue(key: "first_name")
        lName = dict.getStringValue(key: "last_name")
        image = dict.getStringValue(key: "image")
        rating = dict.getDoubleValue(key: "rating")
        review = dict.getStringValue(key: "review")
    }
}

// MARK: - ReviewCell
class ReviewCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var viewComment: UIView!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareUI(_ review: ReviewModel) {
        lblUserName.text = review.fullName
        imgUser.loadFromUrlString(review.image, placeholder: _userPlaceImage)
        lblRating.text = review.rating.stringValues
        viewComment.isHidden = review.review.isEmpty
        lblComment.text = review.review
    }
}

// MARK: - ReviewsVC
class ReviewsVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var vwUserDetails: UIView!
    @IBOutlet weak var vwTadContainer: UIView!
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblReviewCount: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblJoinDate: UILabel!
    @IBOutlet weak var btnVerified: UIButton!
    
    @IBOutlet weak var vwTabBg: UIView!
    
    @IBOutlet weak var vwReceive: UIView!
    @IBOutlet weak var lblReceived: UILabel!
    @IBOutlet weak var lblRecCount: UILabel!
    
    @IBOutlet weak var vwGiven: UIView!
    @IBOutlet weak var lblGiven: UILabel!
    @IBOutlet weak var lblGivCount: UILabel!
    
    @IBOutlet weak var tabLeading: NSLayoutConstraint!
    
    /// Variables
    var selectedTab: Int!
    var userId: Int!
    var userData: UserDetailModel!
    var isFromSideMenu: Bool = false
    var arrData: [ReviewModel]!
    var loadMore = LoadMore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedTab = 0
        
        prepareUI()
        getReviews()
    }
}

// MARK: - UI Methods
extension ReviewsVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
        vwGiven.isHidden = !isFromSideMenu
        
        lblRecCount.isHidden = true
        lblGivCount.isHidden = true
        
        if isFromSideMenu {
            vwUserDetails.isHidden = true
        } else {
            vwTadContainer.isHidden = true
            if let userData {
                lblUserName.text = userData.fullName
                lblReviewCount.text = userData.reviewCountStr
                lblRating.text = userData.rating.stringValues
                lblJoinDate.text = "Joined \(userData.joinDate.getChatSectionHeader())"
                imgUser.loadFromUrlString(userData.image, placeholder: _userPlaceImage)
            }
        }
        
        registerCells()
        addRefresh()
        prepareTabSelectionUI()
    }
    
    func registerCells() {
        NoDataCell.prepareToRegisterCells(tableView)
    }
    
    func addRefresh() {
        refresh.addTarget(self, action: #selector(self.refreshing(_:)), for: .valueChanged)
        self.tableView.refreshControl = refresh
    }
    
    @objc private func refreshing(_ sender: UIRefreshControl) {
        loadMore = LoadMore()
        getReviews()
    }
    
    func prepareTabSelectionUI() {
        let finalWidth = self.vwReceive.bounds.width
        let leadingConstraintConstant = CGFloat(self.selectedTab) * finalWidth
        
        UIView.animate(withDuration: 0.25) {
            self.tabLeading.constant = leadingConstraintConstant
            self.view.layoutIfNeeded()
        }
        
        vwReceive.backgroundColor = .clear
        vwGiven.backgroundColor = .clear
        lblReceived.textColor = selectedTab == 0 ? UIColor.white : AppColor.primaryText
        lblGiven.textColor = selectedTab == 1 ? UIColor.white : AppColor.primaryText
    }
}

// MARK: - Actions
extension ReviewsVC {
    
    @IBAction func btnTabTap(_ sender: UIButton) {
        if selectedTab != sender.tag {
            selectedTab = sender.tag
            self.arrData = nil
            
            self.tableView.reloadData()
            prepareTabSelectionUI()
            loadMore = LoadMore()
            getReviews()
        } else {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
          
    }
}

// MARK: - TableView Methods
extension ReviewsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrData == nil ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.isEmpty ? 1 : arrData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arrData.isEmpty {
            return tableView.frame.height
        } else {
            let data = arrData[indexPath.row]
            if data.review.isEmpty {
                return (60 + 16) * _widthRatio
            } else {
                let height = data.review.heightWithConstrainedWidth(width: _screenSize.width - (70 * _widthRatio), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio)) + 12 * _widthRatio
                return height + (60 + 16 + 26) * _widthRatio
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == arrData.count - 1 && !loadMore.isLoading && !loadMore.isAllLoaded {
            getReviews()
            return showLoadMoreCell()
        }
        if arrData.isEmpty {
            return tableView.dequeueReusableCell(withIdentifier: NoDataCell.identifier, for: indexPath)
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? NoDataCell {
            cell.prepareUI(img: UIImage(named: "ic_no_reviews")!, title: "No review found")
        } else if let cell = cell as? ReviewCell {
            cell.prepareUI(arrData[indexPath.row])
        }
    }
}

// MARK: - API Calls
extension ReviewsVC {
    
    func getReviews() {
        var param: [String: Any] = [:]
        param["user_id"] = userId
        param["type"] = selectedTab == 1 ? "given" : "received"
        param["offset"] = loadMore.offset
        param["limit"] = loadMore.limit
        
        if !refresh.isRefreshing && loadMore.index == 0 {
            showCentralSpinner()
        }
        
        WebCall.call.getUserRating(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            self.refresh.endRefreshing()
            
            if status == 200, let data = json as? NSDictionary {
                let received = data.getIntValue(key: "received_review")
                let given = data.getIntValue(key: "given_review")
                
                if self.lblRecCount.isHidden {
                    self.lblRecCount.isHidden = false
                }
                if self.lblGivCount.isHidden {
                    self.lblGivCount.isHidden = false
                }
                
                self.lblRecCount.text = received.stringValue
                self.lblGivCount.text = given.stringValue
                
                if let dict = data["data"] as? [NSDictionary] {
                    if self.loadMore.index == 0 {
                        self.arrData = []
                    }
                    for data in dict {
                        self.arrData.append(ReviewModel(data))
                    }
                    if dict.isEmpty  || (selectedTab == 1 ? given : received) == self.arrData.count {
                        self.loadMore.isAllLoaded = true
                    } else {
                        self.loadMore.index += 1
                    }
                    self.tableView.reloadData()
                    if self.loadMore.index < 2 {
                        let cells = self.tableView.visibleCells(in: 0)
                        UIView.animate(views: cells, animations: [self.tableLoadAnimation])
                    }
                }
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
}
