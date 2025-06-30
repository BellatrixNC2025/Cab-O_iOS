//
//  WalkthroughVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

// MARK: - Walkthrought steps
enum WalkthroughSteps:Int, CaseIterable {
    case one = 1, two, three
    
    var title: String {
        switch self {
        case .one: return "Welcome to Cab-O"
        case .two: return "Safe and Secure"
        case .three: return "Easy Ride Booking"
        }
    }
    
    var desc: String {
        switch self {
        case .one: return "Your reliable travel companion to get your where you need to go. Quickly and safely."
        case .two: return "Your safety is our priority. Enjoy secure rides with verified drivers and in-app emergency support."
        case .three: return "Book a ride with just a few tape. Choose your pickup and drop off locations, and we'll handle the rest."
        }
    }
    
    var img: UIImage {
        switch self {
        case .one: return UIImage(named: "ic_walk_one")!
        case .two: return UIImage(named: "ic_walk_two")!
        case .three: return UIImage(named: "ic_walk_three")!
        }
    }
}

// MARK: - WalkthroughVC
class WalkthroughVC: ParentVC {
    
    /// Outlets
    @IBOutlet var vwProgress: [UIView]!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var viewBack: RoundGradientView!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet var btnProgress: [UIButton]!
    /// Variables
    var arrCells: [WalkthroughSteps] = WalkthroughSteps.allCases
    var currentStep: WalkthroughSteps! = .one {
        didSet {
            updateProgress()
        }
    }
    var currentPage : Int = 0{
        didSet {
            updateProgress()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        var img = UIImage(named: "ic_back")!.withTintColor(.white)
//        img = img.scaleImage(toSize: img.size * _widthRatio)!
//        btnNext.setImage(img.withHorizontallyFlippedOrientation(), for: .normal)
//        btnBack.setImage(img, for: .normal)
        currentStep = .one
    }
    
    func updateProgress() {
        btnProgress.forEach { btn in
            btn.isSelected = btn.tag == currentPage ? true : false
        }
        vwProgress.forEach { view in
            view.backgroundColor = view.tag == (currentStep.rawValue - 1) ? AppColor.themeGreen : AppColor.themeGray
        }
    }
}

//MARK: - Button Actions
extension WalkthroughVC {
    
    @IBAction func btnNextTap(_ sender: UIButton) {
//        if currentStep == .three {
        _userDefault.set(false, forKey: "firstOpen")
        _userDefault.synchronize()
            _appDelegator.redirectToLoginScreen()
//        } else {
//            if currentStep == .one {
//                currentStep = .two
//            } else {
//                currentStep = .three
//                UIView.animate(withDuration: 0.3) {
//                    self.btnSkip.alpha = 0
//                }
//            }
//            collectionView.scrollToItem(at: IndexPath(item: arrCells.firstIndex(of: currentStep)!, section: 0), at: .left, animated: true)
//        }
//        
//        if currentStep != .one {
//            UIView.animate(withDuration: 0.3) {
//                self.viewBack.alpha = 1
//            }
//        }
    }
    
    @IBAction func btnBackTap(_ sender: UIButton) {
        if currentStep == .three {
//            UIView.animate(withDuration: 0.3) {
//                self.btnSkip.alpha = 1
//            }
            currentStep = .two
        } else {
            currentStep = .one
            UIView.animate(withDuration: 0.3) {
                self.viewBack.alpha = 0
            }
        }
        collectionView.scrollToItem(at: IndexPath(item: arrCells.firstIndex(of: currentStep)!, section: 0), at: .left, animated: true)
    }
    
    @IBAction func btnSkipTap(_ sender: UIButton) {
        _userDefault.set(false, forKey: "firstOpen")
        _userDefault.synchronize()
        _appDelegator.redirectToLoginScreen()
    }
}

//MARK: - CollectinView Methods
extension WalkthroughVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: _screenSize.width, height: _screenSize.height - (_statusBarHeight + _bottomBarHeight + (80 * _heightRatio)))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "walkthroughCell", for: indexPath) as! WalkthroughCell
        cell.prepareUI(arrCells[indexPath.row])
        return cell
//        return collectionView.dequeueReusableCell(withReuseIdentifier: "walkthroughCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if let cell = cell as? WalkthroughCell {
//            cell.prepareUI(arrCells[indexPath.row], currentStep: currentPage)
//        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(collectionView.contentOffset.x / (_screenSize.width - (40 * _widthRatio))))
        currentPage = page
        if currentPage == 2 {
            self.btnSkip.isHidden = true
        }else{
            self.btnSkip.isHidden = false
        }
//        startTimer()
    }
}

// MARK: - WalkthroughCell
class WalkthroughCell: ConstrainedCollectionViewCell {
    
    /// Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// Prepare UI
    func prepareUI(_ step: WalkthroughSteps) {
        lblTitle.text = step.title
        lblDesc.text = step.desc
        imgView.image = step.img
        
        
    }
}
