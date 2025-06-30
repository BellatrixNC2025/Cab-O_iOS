//
//  IdVerificationVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import Photos
import VHUD
import RSKImageCropper

class IdVerificationVC: ParentVC {
    
    /// Variables
    var arrCells: [IdVerificationCellType]! {
        didSet {
            tableView.reloadData()
        }
    }
    
    var data = IdVerificationData()
    var isEdit: Bool = false
    var imageLicence: UIImage?
    var isFirstTimeAdd: Bool!
    
    var progressLoader: VHUDContent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressLoader = VHUDContent(.percentComplete)
        progressLoader.style = appTheme == .unspecified ? UITraitCollection.current.userInterfaceStyle == .dark ? .light : .dark : appTheme == .light ? .dark : .light
        progressLoader.background = .color(UIColor.clear)
        
        prepareUI()
        getVerificationDetails()
    }
}

// MARK: - UI Methods
extension IdVerificationVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        registerCells()
    }
    
    func prepareCellsUI() {
        if isFirstTimeAdd {
            self.arrCells = [.addLicenceTitle, .addLicenceInfo, .addLicenceImage, .addLIcenceButton]
        } else {
            if let status = data.status {
                if status == .verified {
                    self.arrCells = [.enterNameTitle, .firstName, .midName, .lastName, .uploadLicenceTitle, .info, .imageUpload, .verifyStatus, .addLIcenceButton ]
                } else if status == .pending {
                    self.arrCells = [.enterNameTitle, .firstName, .midName, .lastName, .imageUpload, .verifyStatus ]
                } else {
                    self.arrCells = [.enterNameTitle, .firstName, .midName, .lastName, .uploadLicenceTitle, .info, .imageUpload, .verifyStatus, .rejectInfo, .addLIcenceButton ]
                }
            } else {
                self.arrCells = [.enterNameTitle, .firstName, .midName, .lastName, .uploadLicenceTitle, .info, .imageUpload, .addLIcenceButton ]
            }
        }
    }
    
    func registerCells() {
        TitleTVC.prepareToRegisterCells(tableView)
        InputCell.prepareToRegisterCells(tableView)
        DualInputCell.prepareToRegisterCells(tableView)
        ButtonTableCell.prepareToRegisterCells(tableView)
    }
}

// MARK: - Actions
extension IdVerificationVC {
    
    func action_submitTap() {
        let valid = data.isValid()
        if valid.0 {
            showConfirmationPopUpView("Confirmation",isEdit ? "Are you sure you want to update your existing licence with this new one?" : "Are you sure you want to use this as your licence?", btns: [.cancel, .yes]) { btn in
                if btn == .yes{
                    self.addVerificationDetails()
                }
            }
        } else {
            ValidationToast.showStatusMessage(message: valid.1, yCord: _navigationHeight)
        }
    }
    
    func openFullsScreenDoc(_ obj: Any) {
        let vc = KPImagePreview.init(objs: [obj], sourceRace: nil, selectedIndex: nil, placeImg: _dummyPlaceImage)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

// MARK: - TableView Methods
extension IdVerificationVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells == nil ? 0 : arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if EnumHelper.checkCases(cellType, cases: [.addLicenceTitle, .addLicenceInfo, .enterNameTitle, .uploadLicenceTitle]) {
            var height = cellType.title.heightWithConstrainedWidth(width: _screenSize.width - (40 * _widthRatio), font: cellType.titleFont)
            if cellType == .addLicenceInfo {
                height += 12
            }
            return height + 12
        } else if cellType == .rejectInfo {
            if data.rejectStr!.isEmpty {
                return 0
            } else {
                return data.rejectStr!.heightWithConstrainedWidth(width: _screenSize.width - (108 * _widthRatio), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio)) + 48 * _widthRatio
            }
        }
        return cellType.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrCells[indexPath.row]
        return tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? TitleTVC {
            if cellType == .rejectInfo {
                cell.prepareUI(data.rejectStr ?? "", AppFont.fontWithName(.regular, size: 12 * _fontRatio), clr: AppColor.primaryText)
            } else {
                cell.prepareUI(cellType.title, cellType.titleFont, clr: AppColor.primaryText)
                cell.action_infoView = { [weak self] (btn) in
                    guard let self = self else {return}
                    self.openPopOver(view: btn, msg: "Please upload a high-quality, legible scan of a JPEG, PNG of your car registration.")
                }
            }
        }
        else if let cell = cell as? InputCell {
            cell.tag = indexPath.row
            cell.delegate = self
            
            if isEdit && data.status == .pending {
                cell.isUserInteractionEnabled = false
                cell.alpha = 0.5
            }
        }
        else if let cell = cell as? DualInputCell {
            cell.tag = indexPath.row
            cell.delegate = self
            
            if isEdit && data.status == .pending {
                cell.isUserInteractionEnabled = false
                cell.alpha = 0.5
            }
        }
        else if let cell = cell as? AddCarDocumentPickerCell {
            if self.isEdit {
                if let img = self.data.imgLicence {
                    cell.prepareUI(img)
                } else {
                    cell.prepareUI(self.data.imgStr)
                }
            } else {
                cell.prepareUI(self.data.imgLicence)
            }
            if let status = data.status {
                cell.buttonDelete.isHidden = status == .pending && self.data.imgLicence == nil
            } else {
                cell.buttonDelete.isHidden = self.data.id == nil && self.data.imgLicence == nil
            }
            
            cell.action_btnUploadTap = { [weak self] (btn) in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    PhotoLibraryManager.shared.setup(.images, in: self, source: btn)
                }
            }
            cell.action_btnDeleteTap = { [weak self] (btn) in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    PhotoLibraryManager.shared.setup(.images, in: self, source: btn)
                }
            }
        }
        else if let cell = cell as? CarDetailCell {
            cell.lblTitle?.text = "Driving licence"
            cell.prepareCarStatusUI(data.status!)
            cell.action_viewTap = { [weak self] in
                guard self != nil else { return }
                //                weakSelf.openFullsScreenDoc()
            }
        }
        else if let cell = cell as? ButtonTableCell {
            cell.btn.setTitle(isFirstTimeAdd ? "Add driving licence" : isEdit ? "Update" : "Submit", for: .normal)
            cell.btnTapAction = { [weak self] _ in
                guard let weakSelf = self else { return }
                if weakSelf.isFirstTimeAdd {
                    weakSelf.isFirstTimeAdd = false
                    weakSelf.prepareCellsUI()
                    weakSelf.tableView.reloadData()
                } else {
                    weakSelf.action_submitTap()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = arrCells[indexPath.row]
        if cell == .imageUpload {
            var lImg: Any!
            if self.isEdit {
                if let img = self.data.imgLicence {
                    lImg = img
                } else {
                    lImg = self.data.imgStr
                }
            } else {
                lImg = self.data.imgLicence
            }
            if lImg != nil {
                openFullsScreenDoc(lImg as Any)
            }
        }
    }
}

//MARK: - PhotoLibraryDelegate
extension IdVerificationVC: PhotoLibraryDelegate {
    
    func cameraMedia(_ image: UIImage) {
        DispatchQueue.main.async {
            self.openImageCropper(image, pickerController: self)
        }
    }
    
    func photoLibrary(didFinishedPicking media: [PHAsset]) {
        if let imageAsset = media.first {
            let image = PhotoLibraryManager.shared.getImage(from: imageAsset)
            DispatchQueue.main.async {
                self.openImageCropper(image, pickerController: self)
            }
        }
    }
    
    func didCancelPicking() {
        nprint(items: "Media pick canceled")
    }
}

// MARK: - UIImagePicker Delegate
extension IdVerificationVC : RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource {
    
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
            self.data.imgLicence = newImg
        }
        controller.dismiss(animated: true) {
            self.tableView.reloadData()
        }
    }
    
    func imageCropViewControllerCustomMaskRect(_ controller: RSKImageCropViewController) -> CGRect {
        let width: CGFloat = _screenSize.width - (40 * _widthRatio)
        let height: CGFloat = (width * 9) / 16
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


// MARK: - Web Call
extension IdVerificationVC {
    
    func getVerificationDetails() {
        showCentralSpinner()
        WebCall.call.getLicenceDetails { [weak self] (json, status) in
            guard let weakSelf = self else { return }
            weakSelf.hideCentralSpinner()
            if status == 200, let dict = json as? NSDictionary {
                if let data = dict["data"] as? NSDictionary {
                    weakSelf.data = IdVerificationData(data)
                    weakSelf.isEdit = true
                    weakSelf.isFirstTimeAdd = false
                } else {
                    weakSelf.isEdit = false
                    weakSelf.isFirstTimeAdd = true
                }
                weakSelf.prepareCellsUI()
            } else {
                weakSelf.showError(data: json)
            }
        }
    }
    
    func addVerificationDetails() {
        VHUD.show(progressLoader)
        WebCall.call.addLicenceDetails(param: data.param, imgKey: "driving_license", licenceImage: self.data.imgLicence!) { [weak self] (upProgress) in
            guard let `self` = self else { return }
            nprint(items: "Uploading Progress \(Int(upProgress.fractionCompleted * 100))%")
            let prog = CGFloat(upProgress.fractionCompleted)
            VHUD.updateProgress(CGFloat(prog))
            if prog == 1.0 {
                VHUD.dismiss(1.0)
                self.showCentralSpinner()
            }
        } block: { [weak self] (json, status) in
            guard let `self` = self else { return }
            VHUD.dismiss(1.0)
            self.hideCentralSpinner()
            if status == 200 {
                self.showSuccessMsg(data: json, yCord: _navigationHeight)
                self.navigationController?.popViewController(animated: true)
            } else {
                nprint(items: Date())
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
}
