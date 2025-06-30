//
//  RateAndReviewVC.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

class RateAndReviewVC: ParentVC {
    
    /// Variables
    var arrCells: [RateAndReviewCellType] = RateAndReviewCellType.allCases
    var data = RatingModel()
    var isForDriver: Bool = false
    var ratingId: Int?
    var rideId: Int!
    
    var review_given_success:(() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

// MARK: - UI Methods
extension RateAndReviewVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
        addKeyboardObserver()
        registerCells()
    }
    
    func registerCells() {
        InputCell.prepareToRegisterCells(tableView)
        ButtonTableCell.prepareToRegisterCells(tableView)
    }
}

// MARK: - Actions
extension RateAndReviewVC {
    
    func btnSubmitTap() {
        if data.rating == nil {
            ValidationToast.showStatusMessage(message: "Please select the rating first",yCord: _navigationHeight)
        } else {
            addUpdateRating()
        }
    }
}

// MARK: - TableView Methods
extension RateAndReviewVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        return cellType.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrCells[indexPath.row]
        if cellType == .user || cellType == .rating {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath) as! GiveRatingCell
            if cellType == .user {
                cell.imgView.loadFromUrlString(data.toUserImage ?? "", placeholder: _userPlaceImage)
                cell.lblTitle.text = data.toUserName
            }
            else if cellType == .rating {
                cell.prepareRatingUI(data.rating)
            }
            cell.action_rating = { [weak self] (rating) in
                guard let self = self else { return }
                self.data.rating = rating
            }
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? InputCell {
            cell.tag = indexPath.row
            cell.delegate = self
        }
        else if let cell = cell as? ButtonTableCell {
            cell.btn.setTitle("Submit", for: .normal)
            cell.btnTapAction = { [weak self] (_) in
                guard let self = self else { return }
                self.btnSubmitTap()
            }
        }
    }
}

// MARK: - UIKeyboard Observer
extension RateAndReviewVC {
    
    func addKeyboardObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        if let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height + (12 * _widthRatio), right: 0)
        }
        if let fIndex = arrCells.firstIndex(of: .comment), let cell = tableViewCell(index: fIndex) as? InputCell, cell.txtView.isFirstResponder {
            scrollToIndex(index: fIndex, animate: true, .top)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification){
        guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
    }
}

// MARK: - API Calls
extension RateAndReviewVC {
    
    func addUpdateRating() {
        var param: [String: Any] = [:]
        if let ratingId {
            param["rating_id"] = ratingId
        }
        if let bookId = data.toBookingId {
            param["book_ride_id"] = bookId
        }
        param["ride_id"] = rideId
        param["from_user_id"] = _user?.id
        param["to_user_id"] = data.toUserId
        param["from_type"] = isForDriver ? "rider" : "driver"
        param["rating"] = data.rating
        param["review"] = data.msg

        showCentralSpinner()
        WebCall.call.addUpdateRating(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.showSuccessMsg(data: json, yCord: _navigationHeight)
                if self.isForDriver {
                    _defaultCenter.post(name: Notification.Name.rideDetailsUpdate, object: nil)
                }
                self.review_given_success?()
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
}
