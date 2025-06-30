//
//  CarImageSliderTableCell.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class CarImageSliderTableCell: ConstrainedTableViewCell {

    static let identifier: String = "carImageSliderTableCell"
    static let cellHeight: CGFloat = 220 * _widthRatio
    
    /// Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topConstraints: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraints: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraints: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraints: NSLayoutConstraint!
    
    /// Variables
    var timer: Timer?
    var arrImages: [String]! = [] {
        didSet {
            prepareTime()
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CarImageSliderCollectionViewCell.prepareToRegister(collectionView)
    }
    
    override func prepareForReuse() {
        stopTimer()
    }
    
    /// Remove all side constranits
    func prepareDetailUI() {
        topConstraints.constant = 0
        bottomConstraints.constant = 0
        leadingConstraints.constant = 0
        trailingConstraints.constant = 0
    }
    
    @IBAction func btnPrevNextTap(_ sender: UIButton) {
        if sender.tag == 0 { // next button
            
        } else { // previous button
            
        }
    }
}

// MARK: - Timer
extension CarImageSliderTableCell {
    
    func prepareTime() {
        startTimer()
    }
    
    @objc func timerUpdate() {
        let paths = collectionView.indexPathsForVisibleItems
        if let idx = paths.last {
            if idx.row < arrImages.count - 1 {
                collectionView.scrollToItem(at: IndexPath(item: idx.row + 1, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
            } else {
                collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
            }
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { [weak self] (timer) in
            self?.timerUpdate()
        })
    }
    
    // invalidate display link if it's non-nil, then set to nil
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - CollectionView Methods
extension CarImageSliderTableCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size // CGSize(width: (_screenSize.width - (40)), height: 196 * _heightRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: CarImageSliderCollectionViewCell.identifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? CarImageSliderCollectionViewCell {
            cell.imgView.loadFromUrlString(arrImages[indexPath.row])
        }
    }
}

//MARK: - Register Cell
extension CarImageSliderTableCell {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "CarImageSliderTableCell", bundle: nil), forCellReuseIdentifier: identifier)
    }
}
