import Foundation
import UIKit

enum SliderType {
    case ad, image
}

class SliderCell: ConstrainedCollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class SliderView: ConstrainedTableViewCell {

    static let identifier: String = "sliderView"
    static let cellHeight: CGFloat = 246 * _widthRatio
    static let advHeight: CGFloat = 51 * _widthRatio
    
    /// Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewContainer: NRoundView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var training: NSLayoutConstraint!
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var bottom: NSLayoutConstraint!
    
    /// Variables
    var sliderType: SliderType = .image
    var timer: Timer?
    var seconds: Int! = 5
    var selectionCall: ((Int) -> ())?
    var currentIdx: Int = 0
    var imgs: [Any] = [] {
        didSet {
            prepareUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(UINib(nibName: "SliderCell", bundle: nil), forCellWithReuseIdentifier: "cell")
    }
    
    override func prepareForReuse() {
        stopTimer()
    }
    
    /// Initialiser
    class func initView() -> SliderView {
        let obj = Bundle.main.loadNibNamed("SliderView", owner: nil, options: nil)?.first as! SliderView
        return obj
    }
    
    class func initWith(view: UIView) -> SliderView {
        let obj = Bundle.main.loadNibNamed("SliderView", owner: nil, options: nil)?.first as! SliderView
        view.addSubview(obj)
        obj.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
        return obj
    }
}

// MARK: - UI Methods
extension SliderView {
    
    func prepareAdUI(ads: [AdDetails]) {
        self.sliderType = .ad
        self.imgs = ads
        viewContainer.borderWidth = 0
    }
    
    func prepareUI() {
        pageControl.hidesForSinglePage = true
        pageControl.numberOfPages = imgs.count
        collectionView.reloadData()
        prepareTime()
    }
    
    func prepareZoomedUI() {
        leading.constant = 0
        training.constant = 0
        top.constant = 0
        bottom.constant = 0
        viewContainer.borderWidth = 0
    }
}

// MARK: Display Link
extension SliderView {
    
    func prepareTime() {
        if !imgs.isEmpty {
            startTimer()
        }
    }
    
    @objc func timerUpdate() {
        let paths = collectionView.indexPathsForVisibleItems
        if let idx = paths.last {
            if idx.row < imgs.count - 1 {
                DispatchQueue.main.async {
                    self.collectionView.scrollToItem(at: IndexPath(item: idx.row + 1, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
                }
            }
        }
    }
    
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: Double(seconds), repeats: false, block: { [weak self] (timer) in
            self?.timerUpdate()
        })
    }
    
    // invalidate display link if it's non-nil, then set to nil
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Collectionview methods
extension SliderView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SliderCell
        if imgs.isEmpty {
            cell.imgView.image = _carPlaceImage
        } else {
            let img = imgs[indexPath.row]
            if sliderType == .image {
                cell.imgView.loadFromUrlString(img as! String, placeholder: _carPlaceImage)
            } else {
                cell.imgView.loadFromUrlString((img as! AdDetails).url, placeholder: _carPlaceImage)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            if self.sliderType == .ad {
                let img = self.imgs[indexPath.row] as! AdDetails
                if !img.url.isEmpty {
                    if UIApplication.shared.canOpenURL(img.redirectUrl) {
                        UIApplication.shared.open(img.redirectUrl)
                    }
                }
            }
            self.selectionCall?(indexPath.row)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(collectionView.contentOffset.x / (_screenSize.width - (40 * _widthRatio))))
        pageControl.currentPage = page
        if sliderType == .ad {
            seconds = (imgs[page] as! AdDetails).seconds
        }
        startTimer()
    }
}

//MARK: - Register Cell
extension SliderView {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "SliderView", bundle: nil), forCellReuseIdentifier: identifier)
    }
}
