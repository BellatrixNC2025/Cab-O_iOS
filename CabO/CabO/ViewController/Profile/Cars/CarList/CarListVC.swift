//
//  CarListVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class CarListVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var btnAddCar: RoundGradientButton!
    @IBOutlet weak var btnView: RoundGradientView!
    
    /// Variables
    var isChangeCar: Bool = false
    var arrCars: [CarListModel]!
    
    var selectedCar: CarListModel?
    var seatBooked: Int?
    var rideData : CreateRideData!
    var update_callBack: ((CarListModel?) -> ())?
    var redirect_car_id: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        checkForRedirect()
    }
}

// MARK: - UI Methods
extension CarListVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        lblTitle?.text = isChangeCar ? "Select car" : "Cars"
        btnAddCar.setTitle(isChangeCar ? "Done" : "Add car", for: .normal)
        
        registerCells()
        getMyCars()
        addObservers()
        addRefresh()
    }
    
    func addRefresh() {
        refresh.addTarget(self, action: #selector(self.refreshing(_:)), for: .valueChanged)
        self.tableView.refreshControl = refresh
    }
    
    @objc private func refreshing(_ sender: UIRefreshControl) {
//        loadMore = LoadMore()
        self.getMyCars()
    }
    
    func registerCells() {
        NoDataCell.prepareToRegisterCells(tableView)
        CarListCell.prepareToRegisterCells(tableView)
    }
    
    func checkForRedirect() {
        if let redirect_car_id {
            let vc = CarDetailsVC.instantiate(from: .Profile)
            vc.carId = redirect_car_id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - Actions
extension CarListVC {
    
    @IBAction func btnAddCarTap(_ sender: UIButton) {
        if isChangeCar {
            checkCarAndUpdateRide()
        } else {
            let vc = AddCarVC.instantiate(from: .Profile)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - TableView Methods
extension CarListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCars != nil ? arrCars!.isEmpty ? 1 : arrCars.count : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arrCars.isEmpty {
            return _isLandScape ? tableView.frame.width : tableView.frame.height
        } else {
            return CarListCell.normalHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if arrCars.isEmpty {
            return tableView.dequeueReusableCell(withIdentifier: NoDataCell.identifier, for: indexPath)
        } else {
            return tableView.dequeueReusableCell(withIdentifier: CarListCell.identifier, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? NoDataCell {
            cell.prepareUI(img: UIImage(named: "no_car")!, title: "No cars found", subTitle: "")
        }
        else if let cell = cell as? CarListCell {
            let car = arrCars[indexPath.row]
            if isChangeCar {
                cell.prepareUI(car, (selectedCar != nil && selectedCar!.id == car.id) )
            } else {
                cell.prepareUI(car)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isChangeCar {
            let car = arrCars[indexPath.row]
            if car.carStatus == .verified {
                if car.availableSeats.integerValue! < self.seatBooked! {
                    ValidationToast.showStatusMessage(message: "You can't choose this car because it has fewer seats than booked seats.", yCord: _navigationHeight)
                } else {
                    self.selectedCar = car
                    self.tableView.reloadData()
                }
            } else {
                ValidationToast.showStatusMessage(message: car.carStatusString, yCord: _navigationHeight)
            }
        } else {
            if !arrCars.isEmpty {
                let vc = CarDetailsVC.instantiate(from: .Profile)
                vc.carId = arrCars[indexPath.row].id
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}


//MARK: - Notification Observers
extension CarListVC {
    
    func addObservers() {
        _defaultCenter.addObserver(self, selector: #selector(carListUpdated(_:)), name: Notification.Name.carListUpdate, object: nil)
    }
    
    @objc func carListUpdated(_ notification: NSNotification){
        getMyCars()
    }
    
}

// MARK: - API Call
extension CarListVC {
    
    func getMyCars() {
        let param = ["status": DocStatus.verified.apiValue]
        if !refresh.isRefreshing {
            showCentralSpinner()
        }
        WebCall.call.getMyCarList(param: isChangeCar ? param : [:]) { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            self.refresh.endRefreshing()
            self.arrCars = []
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? [NSDictionary] {
                for car in data {
                    self.arrCars.append(CarListModel(car))
                }
                self.tableView.reloadData()
                
                let cells = self.tableView.visibleCells(in: 0)
                UIView.animate(views: cells, animations: [self.tableLoadAnimation])
            } else {
                self.showError(data: json)
            }
        }
    }
    
    func checkCarAndUpdateRide() {
        if rideData.selectedCar!.id == selectedCar!.id {
            self.update_callBack?(nil)
            self.navigationController?.popViewController(animated: true)
        } else {
            var param: [ String: Any ] = [:]
            param["car_id"] = selectedCar!.id
            param["from_date"] = Date.serverDateString(from: rideData.rideDate)
            param["timezone"] = self.rideData.start?.timeZoneId
            
            showSpinnerIn(container: self.btnView, control: self.btnAddCar, isCenter: true)
            WebCall.call.checkRidePrefs(param) { [weak self] (json, status) in
                guard let self = self else { return }
                self.hideSpinnerIn(container: self.btnView, control: self.btnAddCar)
                if status == 200 {
                    self.update_callBack?(self.selectedCar)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.showError(data: json, yCord: _navigationHeight)
                }
            }
        }
    }
}
