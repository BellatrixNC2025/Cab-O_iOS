//
//  RideFilterStatusCell.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class RideFilterStatusCell: ConstrainedTableViewCell {
    
    static var identifier: String = "RideFilterStatusCell"
    static var addHeight: CGFloat = 88 * _widthRatio
    static var addTitleHeight: CGFloat = 52 * _widthRatio
    static var prefHeight: CGFloat = (DeviceType.iPad ? 50 : 44) * _widthRatio
    
    /// Outlets
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// Variables
    var arrStatus: [RideStatus]! = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var isMultiSelect: Bool = false
    var arrSelectedStatus: [RideStatus] = []
    var selectedStatus: RideStatus?
    var selectionCallBack: ((RideStatus) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        RideFilterStatusCollectionCell.prepareToRegister(collectionView)
    }
    
    /// Prepare Cell UI
    func prepareUI(_ title: String = "Status", isMultiSelect: Bool = false, selectedStatus: RideStatus?, arrSelectedStatus: [RideStatus] = []) {
        labelTitle.text = title
        self.isMultiSelect = isMultiSelect
        self.selectedStatus = selectedStatus
        self.arrSelectedStatus = arrSelectedStatus
        collectionView.reloadData()
    }
}

// MARK: - CollectionView Methods
extension RideFilterStatusCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrStatus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = DeviceType.iPad ? 3 : 2
        return CGSize(width: (((_screenSize.width - (40 * _widthRatio)) / columns) - (columns * 4)), height: (DeviceType.iPad ? 50 : 44) * _widthRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4 * _widthRatio
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4 * _widthRatio
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: RideFilterStatusCollectionCell.identifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? RideFilterStatusCollectionCell {
            let pref = arrStatus[indexPath.row]
            if !isMultiSelect {
                cell.prepareUI(pref, pref == selectedStatus)
            } else {
                cell.prepareUI(pref, arrSelectedStatus.contains(pref))
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pref = arrStatus[indexPath.row]
        selectionCallBack?(pref)
        if !isMultiSelect {
            selectedStatus = pref
        } else {
            if arrSelectedStatus.contains(pref) {
                self.arrSelectedStatus.remove(pref)
            } else {
                arrSelectedStatus.append(pref)
            }
        }
        collectionView.reloadData()
    }
}

//MARK: - Register Cell
extension RideFilterStatusCell {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "RideFilterStatusCell", bundle: nil), forCellReuseIdentifier: identifier)
    }
}
