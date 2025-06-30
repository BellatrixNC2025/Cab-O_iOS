//
//  ImageCollectionCell.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class ImageCollectionCell: ConstrainedTableViewCell {

    static let identifier: String = "imageCollectionCell"
    
    /// Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var rightTitleButton: UIButton!
    
    /// Variables
    var editImages: [Any]! = [] {
        didSet {
            let count = editImages.count
            labelTitle?.text = "\(count) \(count > 1 ? "photos" : "photo") uploaded"
            collectionView.reloadData()
        }
    }
    
    var arrImages: [UIImage]! = [] {
        didSet {
            let count = arrImages.count
            labelTitle?.text = "\(count) \(count > 1 ? "photos" : "photo") uploaded"
            collectionView.reloadData()
        }
    }
    var action_deleteImage: ((Int) -> ())?
    var action_rightButtonTap: ((AnyObject) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ImageCollectionViewCell.prepareToRegister(collectionView)
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    /// Add Button Tap Action
    @IBAction func btnAddTap(_ sender: UIButton) {
        action_rightButtonTap?(sender)
    }
}

// MARK: - CollectionView Methods
extension ImageCollectionCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return !editImages.isEmpty ? editImages.count : arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let column: CGFloat = DeviceType.iPad ? 7 : 4
        let cellWidth   = (((_screenSize.width - (40 * _widthRatio)) / column) - column)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ImageCollectionViewCell {
            if !editImages.isEmpty {
                if let img = editImages[indexPath.row] as? CarImageModel {
                    cell.imgView.loadFromUrlString(img.imgStr, placeholder: _carPlaceImage?.withTintColor(AppColor.primaryText))
                } else {
                    cell.imgView.image = editImages[indexPath.row] as? UIImage
                }
                cell.action_deleteImage = {
                    self.action_deleteImage?(indexPath.row)
                }
            } else {
                cell.imgView.image = arrImages[indexPath.row]
                cell.action_deleteImage = {
                    self.action_deleteImage?(indexPath.row)
                }
            }
        }
    }
}

//MARK: - Register Cell
extension ImageCollectionCell {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "ImageCollectionCell", bundle: nil), forCellReuseIdentifier: identifier)
    }
}
