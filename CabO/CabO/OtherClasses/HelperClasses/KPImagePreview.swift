
import UIKit
import Photos
import RSKImageCropper
import Mantis

enum KPImagePreviewType {
    case preview, send, addCar
}

/// It will be used for display Image Preview
class KPImagePreview: UIViewController {
    
    fileprivate var collectionView: UICollectionView!
    fileprivate var imgs: [Any?] = []
    fileprivate var btnClose : UIButton!
    fileprivate var btnCrop : UIButton!
    fileprivate var btnSend : UIButton!
    fileprivate var bgView: UIView!
    fileprivate var placeHolderImg: UIImage?
    fileprivate var previewType: KPImagePreviewType = .preview
    var scrollDirection = UICollectionView.ScrollDirection.horizontal
    
    fileprivate let sourceRect: CGRect?
    fileprivate var selectIndex: Int?
    var callBack: ((ChatSendImg?) -> ())?
    
    var removeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Remove Background", for: .normal)
        button.titleLabel?.font = AppFont.fontWithName(.mediumFont, size: 12 * _fontRatio)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(KPImagePreview.backgroundToggleAction), for: .touchUpInside)
        return button
    }()
    
    var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = false // Initially set to off
        switchControl.addTarget(self, action: #selector(KPImagePreview.backgroundSwitchChanged), for: .valueChanged)
        return switchControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hundelTapGesture))
        self.view.addGestureRecognizer(tap)
        
        if previewType == .preview {
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
            swipeGesture.direction = .down
            view.addGestureRecognizer(swipeGesture)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareUI()
        prepareUICollection()
        prepareUIButton()
        if previewType == .send {
            prepareSendButton()
            prepareCropButton()
        }
        if previewType == .addCar {
            prepareSendButton()
            prepareRemoveBgButton()
            prepareCropButton()
        }
        if let rect = sourceRect {
            addAnimatedImage(rect: rect, idx: selectIndex)
        }
        
        if let idx = selectIndex {
            self.collectionView.scrollToItem(at: IndexPath(row: idx, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
        }
    }
    
    /// It will initialise Image Preview View with given source of image and will present image from `sourceRect`
    /// - Parameters:
    ///   - objs: Objects of image (i,g: UIImage, Image URL)
    ///   - sourceRace: Source Rect from which Image Preview opened
    ///   - selectedIndex: Index of Current Image from objects
    ///   - placeImg: Pcaceholder image
    init(objs: [Any?],sourceRace: CGRect?, selectedIndex: Int?, placeImg: UIImage? = nil, type: KPImagePreviewType = .preview) {
        imgs = objs
        sourceRect = sourceRace
        selectIndex = selectedIndex
        placeHolderImg = placeImg
        self.previewType = type
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        nprint(items: "Deinit")
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    @objc func hundelTapGesture(sender: UITapGestureRecognizer) {
//        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .down {
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UIRelated methods
extension KPImagePreview{
    
    fileprivate func prepareUI(){
        bgView = UIView(frame: _screenFrame)
        bgView.backgroundColor = UIColor.black
        self.view.addSubview(bgView)
    }
    
    fileprivate func prepareUICollection(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        var rect = CGRect.zero
        if scrollDirection == .horizontal{
            rect = CGRect(x: -12.5, y: 0, width: _screenSize.width + 25, height: _screenSize.height)
        }else{
            rect = CGRect(x: 0, y: -12.5, width: _screenSize.width, height: _screenSize.height + 25)
        }
        collectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        self.view.addSubview(collectionView)
        collectionView.register(KPImgCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.reloadData()
    }
    
    fileprivate func prepareUIButton(){
        btnClose = UIButton(frame: CGRect(x: (20 * _widthRatio), y: _statusBarHeight + (10 * _widthRatio), width: (40 * _widthRatio), height: (40 * _widthRatio)))
        let img = UIImage(systemName: "xmark")!.withTintColor(.white)
        btnClose.setImage(img.scaleImage(toSize: img.size * _widthRatio), for: UIControl.State.normal)
        btnClose.addTarget(self, action: #selector(KPImagePreview.closeAction), for: UIControl.Event.touchUpInside)
        btnClose.layer.cornerRadius = 20 * _widthRatio
        btnClose.backgroundColor = AppColor.themePrimary
        btnClose.tintColor = UIColor.white
        self.view.addSubview(btnClose)
    }
    
    fileprivate func prepareCropButton(){
        btnCrop = UIButton(frame: CGRect(x: (_screenSize.width - (60 * _widthRatio)), y: _statusBarHeight + (10 * _widthRatio), width: (40 * _widthRatio), height: (40 * _widthRatio)))
        let img = UIImage(systemName: "crop.rotate")!.withTintColor(.white)
        btnCrop.setImage(img.scaleImage(toSize: img.size * _widthRatio), for: UIControl.State.normal)
        btnCrop.addTarget(self, action: #selector(KPImagePreview.cropImage), for: UIControl.Event.touchUpInside)
        btnCrop.layer.cornerRadius = 20 * _widthRatio
        btnCrop.backgroundColor = AppColor.themePrimary
        btnCrop.tintColor = UIColor.white
        self.view.addSubview(btnCrop)
    }
    
    fileprivate func prepareSendButton(){
        btnSend = UIButton(frame: CGRect(x: _screenSize.width - (70 * _widthRatio), y: _screenSize.height - _bottomAreaSpacing - (70 * _widthRatio), width: (50 * _widthRatio), height: (50 * _widthRatio)))
        let img = UIImage(systemName: previewType == .addCar ? "checkmark" : "paperplane")!.withTintColor(.white)
        btnSend.setImage(img.scaleImage(toSize: img.size * _widthRatio), for: UIControl.State.normal)
        btnSend.addTarget(self, action: #selector(KPImagePreview.sendAction), for: UIControl.Event.touchUpInside)
        btnSend.layer.cornerRadius = 25 * _widthRatio
        btnSend.backgroundColor = AppColor.themePrimary
        btnSend.tintColor = UIColor.white
        self.view.addSubview(btnSend)
    }
    
    fileprivate func prepareRemoveBgButton() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(removeButton)
        
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(switchControl)
        
        // Layout constraints for button
        removeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12 * _widthRatio).isActive = true
        removeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8 * _widthRatio).isActive = true
        removeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8 * _widthRatio).isActive = true
        
        // Layout constraints for switch
        switchControl.leadingAnchor.constraint(equalTo: removeButton.trailingAnchor, constant: 12 * _widthRatio).isActive = true
        switchControl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12 * _widthRatio).isActive = true
        switchControl.centerYAnchor.constraint(equalTo: removeButton.centerYAnchor).isActive = true
        
        containerView.backgroundColor = AppColor.themePrimary
        containerView.layer.cornerRadius = 24 * _widthRatio
        containerView.clipsToBounds = true
        
        view.addSubview(containerView)
        
        // Position the button as needed
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12 * _widthRatio),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50 * _widthRatio)
        ])
    }
    
    /// It will add image to given rect if id is provided then it will display image at given ID in Array of image objects otherwise it will display first image
    /// - Parameters:
    ///   - rect: Rect to display image
    ///   - idx: Index of image
    fileprivate func addAnimatedImage(rect: CGRect, idx: Int?){
        let imgView = UIImageView(frame: rect)
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        
        if let _ = idx{
            if let url = imgs[idx!] as? URL{
                imgView.loadFromUrlString(url, placeholder: placeHolderImg)
            } else if let asset = imgs[idx!] as? PHAsset {
                imgView.image = placeHolderImg
                asset.getFullImage { (img) in
                    imgView.image = img
                }
            } else if let img = imgs[idx!] as? UIImage {
                imgView.image = img
            } else {
                imgView.image = placeHolderImg
            }
        }else{
            if let url = imgs[0] as? URL{
                imgView.loadFromUrlString(url, placeholder: placeHolderImg)
            } else if let asset = imgs[0] as? PHAsset {
                imgView.image = placeHolderImg
                asset.getFullImage { (img) in
                    imgView.image = img
                }
            } else if let img = imgs[0] as? UIImage {
                imgView.image = img
            } else {
                imgView.image = placeHolderImg
            }
        }
        self.collectionView.isHidden = true
        self.view.addSubview(imgView)
        bgView.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {
            imgView.frame = _screenFrame
            self.bgView.alpha = 1.0
            }) { (done) in
                imgView.removeFromSuperview()
                self.collectionView.isHidden = false
        }
    }
    
    @objc fileprivate func closeAction(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func sendAction(sender: UIButton){
        self.dismiss(animated: true) {
            if let img = self.imgs.first as? ChatSendImg {
                self.callBack?(img)
            } else {
                self.callBack?(nil)
            }
        }
    }
    
    // MARK: - Crop Image
    @objc fileprivate func cropImage() {
        var img: UIImage!
        if previewType == .addCar {
            img = (imgs[selectIndex ?? 0] as? AddCarImageModel)?.originalImage
        } else if previewType == .send {
            img = (imgs[selectIndex ?? 0] as? ChatSendImg)?.img
        }
        guard let img = img else { return }
        let vc = Mantis.cropViewController(image: img)
        vc.config.presetFixedRatioType = .canUseMultiplePresetFixedRatio()
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    // Function to handle button tap
    @objc func backgroundToggleAction(_ sender: UIButton) {
        
    }
    
    // Function to handle switch value change
    @objc func backgroundSwitchChanged(_ sender: UISwitch) {
        debugPrint(sender.isOn)
        let indexPaths = collectionView.indexPathsForVisibleItems
        if  !indexPaths.isEmpty {
            if let firstIndexPath = indexPaths.first {
                let currentIndex = firstIndexPath.item
                let med = imgs[currentIndex] as! AddCarImageModel
                med.isRemoveBG = sender.isOn
                collectionView.reloadData()
            }
        }
    }
}

// MARK: - Collection view methods
extension KPImagePreview: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return _screenSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        if scrollDirection == .horizontal{
            return UIEdgeInsets.init(top: 0, left: 12.5, bottom: 0, right: 12.5)
        }else{
            return UIEdgeInsets.init(top: 12.5, left: 0, bottom: 12.5, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 25
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! KPImgCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let imCell = cell as? KPImgCell{
            imCell.parent = self
            if previewType == .addCar {
                imCell.setImage(obj: (imgs[indexPath.row] as! AddCarImageModel).image)
            } else {
                imCell.setImage(obj: imgs[indexPath.row])
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Get the index path of the cell that is currently visible
        let indexPaths = collectionView.indexPathsForVisibleItems
        if  !indexPaths.isEmpty {
            if let firstIndexPath = indexPaths.first {
                let currentIndex = firstIndexPath.item
                selectIndex = currentIndex
                print("Current index: \(currentIndex)")
                if previewType == .addCar {
                    let img = imgs[currentIndex] as! AddCarImageModel
                    switchControl.isOn = img.isRemoveBG
                }
            }
        }
    }
}

// MARK: - CropViewControllerDelegate
extension KPImagePreview: CropViewControllerDelegate {
    
    func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation, cropInfo: Mantis.CropInfo) {
        if previewType == .send {
            let img = imgs[selectIndex ?? 0] as! ChatSendImg
            img.croppedImg = cropped
            img.transformation = transformation
            img.cropInfo = cropInfo
        } else if previewType == .addCar {
            let img = imgs[selectIndex ?? 0] as! AddCarImageModel
            let isRemoveBG = img.isRemoveBG
            img.croppedImage = cropped
            img.isRemoveBG = isRemoveBG
        }
        collectionView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        dismiss(animated: true, completion: nil)
    }
}

/// This cell will be used in KPImagePreview for displaying image
class KPImgCell: UICollectionViewCell, UIScrollViewDelegate{
    
    var imgView: UIImageView!
    var scrollView: UIScrollView!
    weak var parent: KPImagePreview!
      
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollView = UIScrollView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        self.addSubview(scrollView)
        imgView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        imgView.center = scrollView.center
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFit
        scrollView.addSubview(imgView)
    }

    override func prepareForReuse() {
        scrollView.setZoomScale(1.0, animated: false)
    }
    
    /// It will set image if object is not nil otherwise it will use  placeholder image
    fileprivate func setImage(obj: Any?){
        scrollView.setZoomScale(1.0, animated: false)
        if let url = obj as? URL{
            imgView.loadFromUrlString(url, placeholder: parent.placeHolderImg)
        } else if let img = obj as? UIImage{
            imgView.image = img
        } else if let asset = obj as? PHAsset {
            imgView.image = parent.placeHolderImg
            asset.getFullImage { (img) in
                self.imgView.image = img
            }
        } else if let str = obj as? String {
            imgView.loadFromUrlString(str, placeholder: parent.placeHolderImg)
        } else if let img = obj as? ChatSendImg {
            imgView.image = img.image
        } else {
            imgView.image = parent.placeHolderImg
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgView
    }
}
