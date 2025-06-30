//
//  CardListVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

// MARK: - CardListVC
class CardListVC: ParentVC {
    
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnAddNewCard: UIButton!
    
    var arrCards: [CardListModel]!
    var screenType: CardListScreenType = .list
    var bookData: RequestBookRideModel!
    var bookRideId: Int!
    var tipAmount: String!
    var selectedCard: CardListModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getCardList()
    }
}

// MARK: - UI Methods
extension CardListVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        btnContinue.setTitle(screenType.buttonTitle, for: .normal)
        btnAddNewCard.isHidden = screenType == .list
        registerCells()
        addRefresh()
        addObservers()
    }
    
    func addRefresh() {
        refresh.addTarget(self, action: #selector(self.refreshing(_:)), for: .valueChanged)
        self.tableView.refreshControl = refresh
    }
    
    @objc private func refreshing(_ sender: UIRefreshControl) {
        self.getCardList()
    }
    
    func registerCells() {
        NoDataCell.prepareToRegisterCells(tableView)
    }
}

// MARK: - Actions
extension CardListVC {
    
    @IBAction func btnAddCardTap(_ sender: UIButton) {
        let vc = AddCardVC.instantiate(from: .Profile)
        vc.isFirstCard = arrCards.isEmpty
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnContinueTap(_ sender: UIButton) {
        if screenType == .list {
            let vc = AddCardVC.instantiate(from: .Profile)
            vc.isFirstCard = arrCards.isEmpty
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            if arrCards.isEmpty {
                ValidationToast.showStatusMessage(message: "Please add a card to continue", yCord: _navigationHeight)
            }
            else if selectedCard == nil {
                ValidationToast.showStatusMessage(message: "Please select a card to continue", yCord: _navigationHeight)
            } 
            else if selectedCard!.isCardExpired {
                ValidationToast.showStatusMessage(message: "Selected card is expired", yCord: _navigationHeight)
            }
            else {
                if screenType == .tip {
                    self.payTip()
                } else {
                    self.bookRide()
                }
            }
        }
    }
    
    @IBAction func btnBackTap(_ sender: UIButton) {
        if screenType == .booking {
            self.navigationController?.popToViewController(ofClass: RequestBookRideVC.self, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func updateDefaultCard(_ indx: Int) {
        showConfirmationPopUpView("Confirmation!", "Are you sure you want to update your default card?", btns: [.cancel, .yes]) { btn in
            if btn == .yes {
                self.setDefaultCardAPI(indx)
            }
        }
    }
    
    func deleteCard(_ indx: Int) {
//        if arrCards.count == 1 {
//            ValidationToast.showStatusMessage(message: "There should be atleast one card", yCord: _navigationHeight)
//        }
//        else if arrCards[indx].isDefault {
//            ValidationToast.showStatusMessage(message: "You can not delete your default card", yCord: _navigationHeight)
//        }
//        else {
            showConfirmationPopUpView("Confirmation!", "Are you sure you want to delete this card?", btns: [.cancel, .yes]) { btn in
                if btn == .yes {
                    self.deleteCardAPI(indx)
                }
            }
//        }
    }
}

// MARK: - TableView Methods
extension CardListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCards != nil ? arrCards!.isEmpty ? 1 : arrCards.count : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arrCards.isEmpty {
            return _isLandScape ? tableView.frame.width : tableView.frame.height
        } else {
            return 180 * _widthRatio
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if arrCards.isEmpty {
            return tableView.dequeueReusableCell(withIdentifier: NoDataCell.identifier, for: indexPath)
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? NoDataCell {
            cell.prepareUI(img: UIImage(named: "ic_no_cards")!, title: "No cards found", subTitle: screenType == .list ? "" : "Please add your card details, to continue.")
        }
        else if let cell = cell as? CardListCell {
            let card = arrCards[indexPath.row]
            cell.prepareUI(card, type: screenType, card == selectedCard)
            cell.action_updateCard = { [weak self] in
                guard let self = self else { return }
                if self.screenType == .list {
                    self.updateDefaultCard(indexPath.row)
                }
            }
            
            cell.action_deleteCard = { [weak self] in
                guard let self = self else { return }
                self.deleteCard(indexPath.row)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if screenType != .list && !arrCards.isEmpty {
            selectedCard = arrCards[indexPath.row]
            tableView.reloadData()
        }
    }
}

//MARK: - Notification Observers
extension CardListVC {
    
    func addObservers() {
        _defaultCenter.addObserver(self, selector: #selector(cardListUpdated(_:)), name: Notification.Name.cardListUpdate, object: nil)
    }
    
    @objc func cardListUpdated(_ notification: NSNotification){
        getCardList()
    }
}

// MARK: - Card API Call
extension CardListVC {
    
    func getCardList() {
        if !refresh.isRefreshing {
            showCentralSpinner()
        }
        WebCall.call.getCardList { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            self.refresh.endRefreshing()
            self.arrCards = []
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
                if let cards = data["card_detail"] as? [NSDictionary] {
                    cards.forEach { card in
                        self.arrCards.append(CardListModel(card))
                    }
                    if !self.arrCards.isEmpty {
                        self.selectedCard = self.arrCards.first(where: {$0.isDefault})
                    }
                }
                if self.arrCards.isEmpty && self.screenType == .booking {
                    let vc = AddCardVC.instantiate(from: .Profile)
                    vc.isFirstCard = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                self.tableView.reloadData()
                
                let cells = self.tableView.visibleCells(in: 0)
                UIView.animate(views: cells, animations: [self.tableLoadAnimation])
                
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    func deleteCardAPI(_ indx: Int) {
        let cardId: String = arrCards[indx].cardId
        showCentralSpinner()
        WebCall.call.deleteCard(cardId) { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.arrCards.remove(at: indx)
                self.tableView.reloadData()
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    func setDefaultCardAPI(_ indx: Int) {
        let cardId: String = arrCards[indx].cardId
        showCentralSpinner()
        WebCall.call.updateDefaultCard(cardId) { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.arrCards.forEach({$0.isDefault = false})
                let card = arrCards[indx]
                card.isDefault = true
                
                self.arrCards.remove(at: indx)
                self.arrCards.insert(card, at: 0)
                
                self.tableView.reloadData()
                ValidationToast.showStatusMessage(message: "Your default card is updated successfully.", yCord: _navigationHeight, withColor: AppColor.successToastColor)
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
}

// MARK: - Ride API
extension CardListVC {
    
    private func bookRide() {
        var param: [String: Any] = [:]
        param.merge(with: bookData.param)
        param["card_id"] = selectedCard!.id
        showCentralSpinner()
        WebCall.call.bookRide(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.showBookSuces()
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    private func payTip() {
        var param: [String: Any] = [:]
        param["card_id"] = selectedCard!.id
        param["book_ride_id"] = bookRideId
        param["tip_price"] = tipAmount
        
        param.merge(with: Setting.deviceInfo)
        showCentralSpinner()
        WebCall.call.payDriverTip(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.showSuccessMsg(data: json,yCord: _navigationHeight)
                _defaultCenter.post(name: Notification.Name.rideDetailsUpdate, object: nil)
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    fileprivate func showBookSuces() {
        let title: String = "Your booking request sent successfully!"
        let message: String = "Once the driver accepts your booking request we will notify you."
        let animation: LottieAnimationName = .requestSent
        let success = SuccessPopUpView.initWithWindow(title, message, anim: animation)
        success.callBack = { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popToViewController(ofClass: NTabBarVC.self)
        }
    }
}
