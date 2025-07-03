//
//  AddProfilePicVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import Photos
import RSKImageCropper

// MARK: - AddProfilePicVC
class AddProfilePicVC: ParentVC {
    
    /// Variables
    var arrCells: [AddProfilePicCells] = [.title, .desc1, .desc2, .img, .btn]
    var titleHeight : CGFloat = 0
    var desc1Height : CGFloat = 0
    var desc2Height : CGFloat = 0
    var selectedImg: UIImage? = nil {
        didSet {
            if selectedImg != nil {
                arrCells = [.title, .desc3, .img, .confirm]
            } else {
                arrCells = [.title, .desc1, .desc2, .img, .btn]
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

// MARK: - UI Methods
extension AddProfilePicVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
//        if _user?.profilePic != "" {
//            selectedImg =
//        }
        if _user?.profilePic == nil {
            arrCells.removeLast()
        }
        registerCells()
    }
    
    func registerCells() {
//        TitleTVC.prepareToRegisterCells(tableView)
        ButtonTableCell.prepareToRegisterCells(tableView)
    }
    func countHeight() -> CGFloat{
         
        let height : CGFloat = _screenSize.height - (100 * _widthRatio) - titleHeight - desc1Height - desc2Height - 12 - additionalSafeAreaInsets.top - additionalSafeAreaInsets.bottom
        return height
    }
}

// MARK: - TableView Methods
extension AddProfilePicVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if EnumHelper.checkCases(cellType, cases: [.title, .desc1, .desc2, .desc3]) {
            if cellType == .title {
                let titleText = selectedImg != nil ? "Review your profile picture" : "Add your profile picture for safer pickups"
                titleHeight = TitleTVC.height(for: titleText, width: _screenSize.width - (40 * _widthRatio), font: AppFont.fontWithName(.mediumFont, size: 20 * _fontRatio)) + 4 * _widthRatio
                return TitleTVC.height(for: titleText, width: _screenSize.width - (40 * _widthRatio), font: AppFont.fontWithName(.mediumFont, size: 20 * _fontRatio)) + 4 * _widthRatio
            } else {
                if cellType == .desc1 {
                    desc1Height = TitleTVC.height(for: cellType.title, width: _screenSize.width - (40 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + 4 * _widthRatio
                }else if cellType == .desc2 {
                    desc2Height = TitleTVC.height(for: cellType.title, width: _screenSize.width - (40 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + 4 * _widthRatio
                }
                return TitleTVC.height(for: cellType.title, width: _screenSize.width - (40 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + 4 * _widthRatio
            }
        }else{
            if cellType == .img && selectedImg == nil{
                return self.countHeight()
            }else{
                return cellType.cellHeight
            }
        }
        return cellType.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellType = arrCells[indexPath.row]
        if cellType == .img && _user?.profilePic == "" && selectedImg == nil{
            return tableView.dequeueReusableCell(withIdentifier: "beforeProfileImageCell", for: indexPath)
        }else{
            return tableView.dequeueReusableCell(withIdentifier: arrCells[indexPath.row].cellId, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? TitleTVC {
            if cellType == .title {
                let titleText = selectedImg != nil ? "Review your profile picture" : "Add your profile picture for safer pickups"
                cell.prepareUI(titleText, AppFont.fontWithName(.mediumFont, size: 20 * _fontRatio), clr: AppColor.primaryText)
            } else {
                cell.prepareUI(cellType.title, AppFont.fontWithName(.regular, size: 14 * _fontRatio), clr: AppColor.primaryText)
            }
        }
        else if let cell = cell as? AddProfilePicImageCell {
            if let selectedImg {
                cell.imgView?.image = selectedImg
            } else {
                cell.imgView?.loadFromUrlString(_user?.profilePic ?? "", placeholder: _userPlaceImage)
            }
            cell.btnChooseOtherTap = { [weak self] (sender) in
                guard let weakSelf = self else { return }
                PhotoLibraryManager.shared.setup(.images ,in: weakSelf, source: sender)
            }
            cell.btnSubmitTap = { [ weak self] in
                guard let self = self else { return }
                self.updateProfileImageAPI()
            }
        }
        else if let cell = cell as? ButtonTableCell {
            cell.btn.setTitle("Select picture", for: .normal)
            cell.btnTapAction = { [weak self] (sender) in
                guard let weakSelf = self else { return }
                PhotoLibraryManager.shared.setup(.images, in: weakSelf, source: sender)
            }
        }
    }
}

//MARK: - PhotoLibraryDelegate
extension AddProfilePicVC: PhotoLibraryDelegate {
    
    func cameraMedia(_ image: UIImage) {
        DispatchQueue.main.async {
            self.openImageCropper(image, pickerController: self)
        }
    }
    
    func photoLibrary(didFinishedPicking media: [PHAsset]) {
        if let imageAsset = media.first {
            if imageAsset.mediaType == .image {
                let image = PhotoLibraryManager.shared.getImage(from: imageAsset)
                DispatchQueue.main.async {
                    self.openImageCropper(image, pickerController: self)
                }
            } else {
                nprint(items: "video is selected")
            }
        }
    }
    
    func didCancelPicking() {
        nprint(items: "Media pick canceled")
    }
}

// MARK: - UIImagePicker Delegate
extension AddProfilePicVC : RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource {
    
    /// Use to open crop image view, to cropping image
    ///
    /// - Parameter image: Need image to crop.
    func openImageCropper(_ image: UIImage, pickerController: UIViewController) {
        let vcImageCrop = RSKImageCropViewController(image: image, cropMode: .custom)
        vcImageCrop.delegate = self
        vcImageCrop.dataSource = self
        vcImageCrop.avoidEmptySpaceAroundImage = true
        vcImageCrop.isRotationEnabled = true
        vcImageCrop.view.tag = pickerController.view.tag
        if let vc = pickerController as? UIImagePickerController {
            vc.pushViewController(vcImageCrop, animated: true)
        } else {
            vcImageCrop.modalPresentationStyle = .fullScreen
            self.present(vcImageCrop, animated: true, completion: nil)
        }
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        let newImg = croppedImage.fixOrientation()!.scaleAndManageAspectRatio(_minImageSize.width)
        if newImg.fileSizeMB > 4 {
            ValidationToast.showStatusMessage(message: kImageSizeValidation)
        } else {
            self.selectedImg = newImg
        }
        controller.dismiss(animated: true) {
            self.tableView.reloadData()
        }
    }
    
    func imageCropViewControllerCustomMaskRect(_ controller: RSKImageCropViewController) -> CGRect {
        let width = _screenSize.width - (40 * _widthRatio)
        let height = width // (width * 9) / 16
        let yCordinate = (_screenSize.height - height) / 2
        let xCordinate = (_screenSize.width - width) / 2
        return CGRect(x: xCordinate, y: yCordinate, width: width, height: height)
    }
    
    func imageCropViewControllerCustomMaskPath(_ controller: RSKImageCropViewController) -> UIBezierPath {
        return UIBezierPath(rect: controller.maskRect)
    }
    
    func imageCropViewControllerCustomMovementRect(_ controller: RSKImageCropViewController) -> CGRect {
        return controller.maskRect
    }
}

// MARK: - API Call
extension AddProfilePicVC {
    
    func updateProfileImageAPI() {
        showCentralSpinner()
        let param: [String: Any] = ["type" : "profile_image"]
        WebCall.call.updateProfileImage(param: param, imgKey: "image", image: self.selectedImg!) { [weak self] (upProgress) in
            guard self != nil else { return }
            nprint(items: "Uploading Progress \(Int(upProgress.fractionCompleted * 100))%")
        } block: { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary  {
                let imgLink = data.getStringValue(key: "image")
                _user?.profilePic = imgLink
                _appDelegator.saveContext()
                
                self.showSuccessMsg(data: json)
                _defaultCenter.post(name: Notification.Name.userProfileUpdate, object: nil)
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                self.showError(data: json)
            }
        }
    }
}
