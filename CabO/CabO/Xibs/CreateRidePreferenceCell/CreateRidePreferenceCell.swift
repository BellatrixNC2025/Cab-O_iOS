//
//  CreateRidePreferenceCell.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class CreateRidePreferenceCell: ConstrainedTableViewCell {

    static var identifier: String = "CreateRidePreferenceCell"
    static var addHeight: CGFloat = 88 * _widthRatio
    static var addTitleHeight: CGFloat = 44 * _widthRatio
    static var prefHeight: CGFloat = (DeviceType.iPad ? 50 : 44) * _widthRatio
    
    /// Outlets
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// Variables
    var arrPrefs: [RidePrefModel]! = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    var selectedPref: [Int] = []
    var selectionCallBack: ((RidePrefModel) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CreateRidePreferenceCollectionCell.prepareToRegister(collectionView)
    }
    
    /// Prepare Cell UI
    func prepareUI(_ title: String = "Ride preferences", _ subTitle: String = "This helps the riders know about your extra space/preferences for your ride.", hideSubTitle: Bool = false, selectedPref: [Int] = []) {
        labelTitle.text = title
        labelSubTitle.text = subTitle
        labelSubTitle.isHidden = hideSubTitle
        if hideSubTitle {
            labelTitle.font = labelTitle.font.withSize(18 * _fontRatio)
        }
        self.selectedPref = selectedPref
        collectionView.reloadData()
    }
}

// MARK: - CollectionView Methods
extension CreateRidePreferenceCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrPrefs.count
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
        return collectionView.dequeueReusableCell(withReuseIdentifier: CreateRidePreferenceCollectionCell.identifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? CreateRidePreferenceCollectionCell {
            let pref = arrPrefs[indexPath.row]
            cell.prepareUI(pref, selectedPref.contains(pref.id))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pref = arrPrefs[indexPath.row]
        selectionCallBack?(pref)
        if selectedPref.contains(pref.id) {
            self.selectedPref.removeItem(pref.id)
        } else {
            selectedPref.append(pref.id)
        }
        collectionView.reloadData()
    }
}

//MARK: - Register Cell
extension CreateRidePreferenceCell {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "CreateRidePreferenceCell", bundle: nil), forCellReuseIdentifier: identifier)
    }
}
