import Foundation
import UIKit
import Photos
import PhotosUI
import MobileCoreServices

struct PhotoLibraryMessages {
    
    static let _NULL_STRING_ = ""
    static let cancel = "Cancel"
    static let settings = "Settings"
    static let ok = "Ok"
    
    struct PhotosError {
        static let cameraPermission = "Please enable camera permission in settings"
        static let photoLibraryDenied = "Please enable photo library permission in settings"
        
        static let cameraUnavailable = "Camera not found"
        
        static let selectionLimit = "Selection limit must be greater then 0!"
        static let delegateNotConform = "Please conform protocol for parent UIViewController [PhotoLibraryDelegate]"
        static let keyMisMatched = "\n---------------------------- ERROR ----------------------------\n ~> PhotoLibrary messages must be updated from the file itself. External/Static update may lead to crash or unexpected results\n==================== PHOTOLIBRARYMANAGER ====================\n"
    }
    
    struct PhotoKeys {
        static let camera = "Take photo"
        static let gallery = "Import from gallery"
    }
    
    struct PhotosMsgs {
        static let chooseGalleryCamera = "Select photo from"
    }
}

fileprivate enum PhotoAccess { case camera, gallery }

protocol PhotoLibraryDelegate: AnyObject {
    func cameraMedia(_ image: UIImage)
    func photoLibrary(didFinishedPicking media: [PHAsset])
    func didCancelPicking()
}

///Confirm with delegate protocol to receive selected image from camera or photo library. [PhotoLibraryDelegate]
final class PhotoLibraryManager: NSObject {
    
    /// Shared Instance
    static let shared = PhotoLibraryManager()
    
    /// Properties
    private weak var delegate: PhotoLibraryDelegate!
    private var selectedAssets: [PHAsset]?
    
    private var mediaPickerType: PHPickerFilter?
    private var selectionLimit: Int = 1
    private weak var parentVc: UIViewController!
    private var imagePicker: UIImagePickerController!
    private var source: AnyObject!
    
    /// Initialiser
    override private init() { }
}

//MARK: Alert Gallery Camera
extension PhotoLibraryManager {
    
    ///PhotoLibraryDelegate provides selected image asset(s) Conform before preceding
    func setup(_ mediaType: PHPickerFilter? = nil, selectionLimit: Int = 1, in vc: UIViewController, source rect: AnyObject) {
        if selectionLimit == 0 { fatalError(PhotoLibraryMessages.PhotosError.selectionLimit) }
        self.selectionLimit = selectionLimit
        mediaPickerType = mediaType
        parentVc = vc
        self.source = rect
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        guard let vc = vc as? any PhotoLibraryDelegate else { fatalError(PhotoLibraryMessages.PhotosError.delegateNotConform) }
        delegate = vc
        openCameraGallery(rect)
    }
    
    private func openCameraGallery(_ sender: AnyObject) {
        showAlert(msg: PhotoLibraryMessages.PhotosMsgs.chooseGalleryCamera, btnTitle: [PhotoLibraryMessages.PhotoKeys.camera, PhotoLibraryMessages.PhotoKeys.gallery, PhotoLibraryMessages.cancel]) { [weak self] selectedAction in
            guard let `self` = self else { return }
            if selectedAction == PhotoLibraryMessages.cancel || selectedAction == PhotoLibraryMessages._NULL_STRING_ { return }
            switch selectedAction {
                case PhotoLibraryMessages.PhotoKeys.camera: self.checkCameraPermission()
                case PhotoLibraryMessages.PhotoKeys.gallery: self.checkPhotoLibraryPermission()
                default: print(PhotoLibraryMessages.PhotosError.keyMisMatched)
            }
        }
    }
}

//MARK: Request Authorization
extension PhotoLibraryManager {
    
    /// Check Permissions
    private func checkPhotoLibraryPermission() {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized: openPhotoLibrary()
            
        case .limited: openLimitedLibrary()
            
        case .denied, .restricted: redirectSettings(.gallery)
            
        case .notDetermined: requestAuthorizationLibrary()
            
        default: redirectSettings(.gallery)
        }
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: openCamera()
                
            case .denied, .restricted: redirectSettings(.camera)
                
            case .notDetermined: requestAuthorizationCamera()
                
            default: redirectSettings(.camera)
        }
    }
    
    private func requestAuthorizationLibrary() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { [weak self] status in
            guard let `self` = self else { return }
            switch status {
            case .restricted, .denied: self.redirectSettings(.gallery)
                
            case .authorized: self.openPhotoLibrary()
                
            case .limited: self.openLimitedLibrary()
                
            default: self.redirectSettings(.gallery)
            }
        })
    }
    
    private func requestAuthorizationCamera() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] isGranted in
            guard let `self` = self else { return }
            guard isGranted else { self.redirectSettings(.camera); return }
            switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .authorized: self.openCamera()
                    
                case .denied, .restricted: self.redirectSettings(.camera)
                    
                default: self.redirectSettings(.camera)
            }
        }
    }
    
    //MARK: Open Settings
    private func redirectSettings(_ accessDenied: PhotoAccess) {
        DispatchQueue.main.async {
            self.showAlert(msg: accessDenied == .camera ? PhotoLibraryMessages.PhotosError.cameraPermission : PhotoLibraryMessages.PhotosError.photoLibraryDenied, btnTitle: [PhotoLibraryMessages.cancel, PhotoLibraryMessages.settings]) { [weak self] receivedAction in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    if receivedAction == PhotoLibraryMessages.settings && UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!) {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    } else {
                        self.parentVc.dismiss(animated: true)
                    }
                }
            }
        }
    }
}

//MARK: Open Camera or Gallery
extension PhotoLibraryManager {
    
    private func openLimitedLibrary() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: PhotoDictKeys.creationDate.rawValue, ascending: true)]
        options.includeAssetSourceTypes = .typeUserLibrary
        
        DispatchQueue.main.async {
            let assetVc = SelectedAssetsVc()
            assetVc.mediaPickerType = self.mediaPickerType
            assetVc.selectedAssets = []
            assetVc.maxSelectionLimit = self.selectionLimit
            assetVc.getSelectedImage = { arrSelectedAsset, isSelected in
                guard isSelected else { self.delegate.didCancelPicking(); return }
                if !isSelected {
                    self.delegate.didCancelPicking()
                    return
                }
                self.selectedAssets = arrSelectedAsset ?? []
                self.delegate?.photoLibrary(didFinishedPicking: self.selectedAssets!)
            }
            self.parentVc.present(assetVc, animated: true)
        }
    }
    
    private func openPhotoLibrary() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        if #available(iOS 15.0, *) {
            config.selection = .ordered
        } else {
            // Fallback on earlier versions
        }
        config.selectionLimit = selectionLimit
        config.filter = mediaPickerType
        DispatchQueue.main.async {
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            self.parentVc.present(picker, animated: true)
        }
    }
    
    private func openCamera() {
        DispatchQueue.main.async {
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.showAlert(msg: PhotoLibraryMessages.PhotosError.cameraUnavailable, btnTitle: [PhotoLibraryMessages.ok])
                return
            }
            self.imagePicker.sourceType = .camera
            self.imagePicker.cameraCaptureMode = .photo
            self.parentVc.present(self.imagePicker, animated: true)
        }
    }
}


//MARK: Get Image from PHAsset
extension PhotoLibraryManager {
    
    ///Convert PHAsset to UIImage
    func getImage(from asset: PHAsset, size: CGSize? = nil) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumb = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: size != nil ? size! : CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .default, options: option) { img, info in
            if let img {
                thumb = img
            }
        }
        return thumb
    }
}

//MARK: UIImagePickerController & UINavigationController Delegate
extension PhotoLibraryManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        DispatchQueue.main.async {
            self.imagePicker.dismiss(animated: true)
            if let selectedImage = info[.originalImage] as? UIImage {
                self.delegate?.cameraMedia(selectedImage)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        DispatchQueue.main.async {
            picker.dismiss(animated: true)
            self.delegate?.didCancelPicking()
        }
    }
}

//MARK: PHPickerViewController Delegate
extension PhotoLibraryManager: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if results.isEmpty { delegate.didCancelPicking(); return }
        let identifiers = results.compactMap({$0.assetIdentifier})
        _ = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        var assetImage: [PHAsset] = []
//        fetchResult.enumerateObjects { asset, assetIndex, _ in assetImage.append(asset) }
        for id in identifiers {
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
            if let result = fetchResult.firstObject {
                assetImage.append(result)
            }
        }
        delegate?.photoLibrary(didFinishedPicking: assetImage)
    }
}

//MARK: Manage Alert
extension PhotoLibraryManager {
    
    private func showAlert(title: String? = nil, msg: String?, btnTitle: [String], style: UIAlertController.Style = .actionSheet, completion: ((String) -> ())? = nil) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: style)
        btnTitle.forEach { actionTitle in alert.addAction(UIAlertAction(title: actionTitle, style: actionTitle == PhotoLibraryMessages.cancel ? .cancel : .default, handler: { [weak self] _ in
            guard let `self` = self else { return }
            if let completion {
                completion(actionTitle)
            }
            self.parentVc.dismiss(animated: true)
        }))}
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = source as? UIView
            popoverController.sourceRect = (source as? UIView)!.bounds
        }
        if _appTheme != .system {
            alert.overrideUserInterfaceStyle = appTheme
        }
        parentVc.present(alert, animated: true)
    }
}

//MARK: Access Keys
fileprivate enum PhotoDictKeys: String {
    case editedImage = "UIImagePickerControllerEditedImage"
    case originalImage = "UIImagePickerControllerOriginalImage"
    case creationDate = "creationDate"
}
