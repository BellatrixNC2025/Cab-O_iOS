import UIKit
import PhotosUI
import Photos

final class SelectedAssetsVc: UIViewController {

    //----------------------------
    //MARK: IBOulet
    @IBOutlet private weak var collView: UICollectionView!
    @IBOutlet weak var btnManage: UIButton!
    
    //----------------------------
    //MARK: Properties
    var fetchResult: PHFetchResult<PHAsset>?
    var selectedAssets: [PHAsset] = []
    var getSelectedImage: ((_ assets: [PHAsset]?, _ isSelected: Bool) -> ())?
    let imageManager = PHCachingImageManager()
    var mediaPickerType: PHPickerFilter?
    
    var shouldManagePhotos: (() -> ())?
    
    var maxSelectionLimit: Int = 1
    
    //----------------------------
    //MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if _appTheme != .system {
            self.overrideUserInterfaceStyle = appTheme
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}

//MARK: UI & Utility Methods
extension SelectedAssetsVc {

    private func setup() {
        collView.register(UINib(nibName: SelectedAssetsCell.identifier, bundle: nil), forCellWithReuseIdentifier: SelectedAssetsCell.identifier)
        
        btnManage.isHidden = false
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        if let mediaPickerType {
            fetchResult = PHAsset.fetchAssets(with: mediaPickerType == .images ? .image : .video, options: options)
        } else {
            fetchResult = PHAsset.fetchAssets(with: options)
        }
        
        collView.reloadData()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    private func updateSelection(indexPath: IndexPath) {
        guard let asset = fetchResult?[indexPath.item] else { return }
        if maxSelectionLimit > 1 {
            if selectedAssets.contains(asset) {
                selectedAssets.removeAll(where: {$0 == asset})
            } else if selectedAssets.count == maxSelectionLimit {
                ValidationToast.showStatusMessage(message: "You can select maximum \(maxSelectionLimit) photos")
                return
            } else {
                selectedAssets.append(asset)
            }
            collView.reloadItems(at: [indexPath])
        } else {
            selectedAssets.removeAll()
            selectedAssets.append(asset)
            getSelectedImage?(selectedAssets, true)
            dismiss(animated: true)
        }
//        if selectedAssets.count == maxSelectionLimit {
//            dismiss(animated: true)
//        }
    }
}

//MARK: IBAction
extension SelectedAssetsVc {
    
    @IBAction private func btnCancelClicked() {
        if let getSelectedImage {
            getSelectedImage(nil, false)
        }
        dismiss(animated: true)
    }
    
    @IBAction private func btnManageClicked() {
        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
    }
    
    @IBAction private func btnDoneClicked() {
        if let getSelectedImage {
            getSelectedImage(selectedAssets, true)
        }
        dismiss(animated: true)
    }
}

extension SelectedAssetsVc: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            guard let fetchResult = self.fetchResult else { return }
            if let changeDetails = changeInstance.changeDetails(for: fetchResult) {
                self.fetchResult = changeDetails.fetchResultAfterChanges
                self.collView.reloadData()
            }
        }
    }
}

//MARK: UICollectionView Delegate & DataSource
extension SelectedAssetsVc: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3, height: collectionView.frame.width / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collView.dequeueReusableCell(withReuseIdentifier: SelectedAssetsCell.identifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? SelectedAssetsCell {
            guard let asset = fetchResult?[indexPath.item] else { return }
            cell.setup(assetImg: asset, isSelected: selectedAssets.contains(asset))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateSelection(indexPath: indexPath)
    }
}
