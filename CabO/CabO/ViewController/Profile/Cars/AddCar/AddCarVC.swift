//
//  AddCarVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import Photos
import VHUD
import RSKImageCropper

// MARK: - CarMasterDetailsType
fileprivate enum CarMasterDetailsType {
    case company, model, year, color
    
    var apiParam: String {
        switch self {
        case .company: return "car_company"
        case .model: return "car_company_model"
        case .year: return "car_manufacture_year"
        case .color: return "car_company_model_color"
        }
    }
}

// MARK: - AddCarImageModel
class AddCarImageModel {
    var originalImage: UIImage!
    var croppedImage: UIImage?
    var carImage: UIImage? = nil
    
    var img: UIImage {
        return croppedImage ?? originalImage
    }
    
    var isRemoveBG: Bool = false {
        didSet {
            if isRemoveBG == true {
                carImage = img.removeBackground(returnResult: .finalImage)
            } else {
                carImage = nil
            }
        }
    }
    
    var image: UIImage {
        return isRemoveBG ? carImage! : img
    }
    
    init(_ img: UIImage) {
        originalImage = img
    }
}

// MARK: - AddCarVC
class AddCarVC: ParentVC {
    
    /// Variables
    var arrCells: [AddCarCellType] = [.addcarImage, .imageCollection, .info, .make, .model, .yearAndColor, .licencePlate, .availableSeat, .uploadDocTitle, .info, .carRegTitle, .carRegistration, .insuranceTitle, .insurance, .btn]
    var docPickerCellType : AddCarCellType!
    var data: AddCarModel = AddCarModel()
    var isEdit: Bool = false
    var deletedImgs: [String] = []
    var arrCarCompanies: [CarCompanyModel]!
    var arrCarModels: [CarNameModel]!
    var arrCarYears: [CarYearModel]!
    var arrCarColors: [CarColorModel]!
    var arrSeats: [Int] = []
    var progressLoader: VHUDContent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 1..._appDelegator.config.addCarMaxSeat {
            arrSeats.append(i)
        }
        
        progressLoader = VHUDContent(.percentComplete)
        progressLoader.style = appTheme == .unspecified ? UITraitCollection.current.userInterfaceStyle == .dark ? .light : .dark : appTheme == .light ? .dark : .light
        progressLoader.background = .color(UIColor.clear)
        
        prepareUI()
        getCarAddDetails(.company)
    }
}

// MARK: - UI Methods
extension AddCarVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        lblTitle?.text = isEdit ? "Edit car details" : "Add car details"
        
        registerCells()
        addKeyboardObserver()
    }
    
    func registerCells() {
        ImageCollectionCell.prepareToRegisterCells(tableView)
        TitleTVC.prepareToRegisterCells(tableView)
        InputCell.prepareToRegisterCells(tableView)
        DualInputCell.prepareToRegisterCells(tableView)
        AvailableSeatsCell.prepareToRegisterCells(tableView)
        ButtonTableCell.prepareToRegisterCells(tableView)
    }
}

// MARK: - Actions
extension AddCarVC {
    
    func buttonSubmitCarTap() {
        let valid = isEdit ? data.isEditValid() : data.isValid()
        if valid.0 {
            addUpdateCar()
        } else {
            ValidationToast.showStatusMessage(message: valid.1, yCord: _navigationHeight)
        }
    }
    
    func btnOpenDocumentPicker(_ sender: AnyObject) {
        var selectionLimit: Int = 1
        let maxAllow = _appDelegator.config.addCarMaxImage!
        DispatchQueue.main.async {
            if self.docPickerCellType == .addcarImage || self.docPickerCellType == .imageCollection {
                selectionLimit = self.isEdit ? (maxAllow - self.data.editCarImages.count) : (maxAllow - self.data.carImages.count)
            }
            if selectionLimit == 0 {
                ValidationToast.showStatusMessage(message: "Maximum \(maxAllow) images are allowed", yCord: _navigationHeight)
            } else {
                PhotoLibraryManager.shared.setup(.images, selectionLimit: selectionLimit, in: self, source: sender)
            }
        }
    }
    
    func fetchMasterDetail(for cellType: AddCarCellType) {
        let type: CarMasterDetailsType = cellType == .make ? .model : cellType == .model ? .year : .color
        getCarAddDetails(type, company: data.carCompany)
    }
}

// MARK: - TableView Methods
extension AddCarVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if cellType == .addcarImage {
            if isEdit {
                return (data.editCarImages.isEmpty && data.carImages.isEmpty) ? 90 * _widthRatio : 0
            } else {
                return data.carImages.isEmpty ? 90 * _widthRatio : 0
            }
        }
        else if cellType == .imageCollection {
            let count = self.isEdit == true ? data.editCarImages.count : data.carImages.count
//            let data = self.isEdit == true ? (self.data.editCarImages.compactMap({$0.img}) + self.data.carImages) : self.data.carImages
            let column: CGFloat = DeviceType.iPad ? 7 : 4
            let cellWidth   = (((_screenSize.width - (40 * _widthRatio)) / column) - column)
            if count == 0 {
               return 0
            }
            else {
                let rows = Int(ceil(Double(count) / column))
                return count == 0 ? 0 : ((cellWidth * CGFloat(rows)) + CGFloat((12 * Int(_widthRatio)) * rows) * _widthRatio) + ((DeviceType.iPad ? 36 : 24) * _widthRatio)
            }
        } else if cellType == .info {
            return UITableView.automaticDimension
            let str = arrCells[indexPath.row - 1] == .imageCollection ? "Please upload a high-quality of a JPEG, PNG of your car photo." : "Please upload a high-quality, legible scan of a JPEG, PNG of your car registration."
            return str.heightWithConstrainedWidth(width: _screenSize.width - (64 * _widthRatio), font: AppFont.fontWithName(.regular, size: (12 * _fontRatio))) + (18 * _heightRatio)
        }
        else if EnumHelper.checkCases(cellType, cases: [.uploadDocTitle, .carRegTitle, .insuranceTitle]) {
            return cellType.title.0.heightWithConstrainedWidth(width: _screenSize.width - (40 * _widthRatio), font: AppFont.fontWithName(.mediumFont, size: cellType == .uploadDocTitle ? (18 * _fontRatio) : (14 * _fontRatio))) + (18 * _heightRatio)
        }
        return cellType.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrCells[indexPath.row]
        if indexPath.row != 0 && arrCells[indexPath.row - 1] == .imageCollection {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath) as! TitleTVC
            cell.prepareUI("Please upload a high-quality of a JPEG, PNG of your car photo.", AppFont.fontWithName(.regular, size: 12 * _fontRatio), clr: AppColor.primaryText)
            return cell
        }
        else if cellType == .info {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath) as! TitleTVC
            cell.prepareUI("Please upload a high-quality, legible scan of a JPEG, PNG of your car registration.", AppFont.fontWithName(.regular, size: 12 * _fontRatio), clr: AppColor.primaryText)
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? ImageCollectionCell {
            if isEdit {
                cell.editImages = self.data.editCarImages
            } else {
                cell.arrImages = self.data.carImages
            }
            cell.action_rightButtonTap = {[weak self] (btn) in
                guard let `self` = self else { return }
                self.docPickerCellType = cellType
                self.btnOpenDocumentPicker(btn)
            }
            cell.action_deleteImage = { [weak self] (indx) in
                guard let `self` = self else { return }
                self.showConfirmationPopUpView("Confirmation!", "Are you sure you want to delete this image?", btns: [.cancel, .yes]) { button in
                    if button == .yes {
                        if self.isEdit {
                            if let img = self.data.editCarImages[indx] as? CarImageModel {
                                self.deletedImgs.append(img.id)
                            }
                            self.data.editCarImages.remove(at: indx)
                        } else {
                            self.data.carImages.remove(at: indx)
                        }
                        self.tableView.reloadRows(at: [IndexPath(row: self.arrCells.firstIndex(of: cellType)!, section: 0)], with: .automatic)
                    }
                }
            }
        }
        else if let cell = cell as? TitleTVC {
            if arrCells[indexPath.row - 1] == .imageCollection {
                cell.prepareUI("Please upload a high-quality of a JPEG, PNG of your car photo.", AppFont.fontWithName(.regular, size: 12 * _fontRatio), clr: AppColor.primaryText)
            } else if arrCells[indexPath.row - 1] == .uploadDocTitle {
                cell.prepareUI("Please upload a high-quality, legible scan of a JPEG, PNG of your car registration.", AppFont.fontWithName(.regular, size: 12 * _fontRatio), clr: AppColor.primaryText)
            } else {
                cell.prepareUI(cellType.title.0, AppFont.fontWithName(.mediumFont, size: cellType == .uploadDocTitle ? (18 * _fontRatio) : (14 * _fontRatio)), clr: AppColor.primaryText)
            }
        }
        else if let cell = cell as? InputCell {
            cell.tag = indexPath.row
            cell.delegate = self
        }
        else if let cell = cell as? DualInputCell {
            cell.tag = indexPath.row
            cell.delegate = self
        }
        else if let cell = cell as? AvailableSeatsCell {
            cell.lblRideFull.isHidden = true
            cell.arrSeats = self.arrSeats
            cell.selectedSeat = data.seats
            cell.seatSelectionCallBack = { [weak self] (seat) in
                guard let self = self else { return }
                self.data.seats = seat
            }
        }
        else if let cell = cell as? CarDetailCell {
            cell.prepareUI(cellType.title.0, AppFont.fontWithName(.mediumFont, size: cellType == .uploadDocTitle ? (18 * _fontRatio) : (14 * _fontRatio)), clr: AppColor.primaryText)
            
            cell.prepareCarStatusUI(cellType == .carRegTitle ? self.data.registrationStatus : data.insuranceStatus ,(isEdit && cellType == .carRegTitle ? data.registrationImageStr != nil : data.insuranceImageStr != nil))
        }
        else if let cell = cell as? AddCarDocumentPickerCell {
            if isEdit {
                if cellType == .carRegistration {
                    let isEditable = EnumHelper.checkCases(self.data.registrationStatus!, cases: [.expired, .rejected]) || self.data.registrationImageStr == nil
                    if let regImage = data.registrationImage {
                        cell.prepareUI(regImage, isEditable: true)
                    } else {
                        cell.prepareUI(self.data.registrationImageStr, isEditable: isEditable)
                    }
                } else {
                    let isEditable = EnumHelper.checkCases(self.data.insuranceStatus!, cases: [.expired, .rejected]) || self.data.insuranceImageStr == nil
                    if let insImage = data.insuranceImage {
                        cell.prepareUI(insImage, isEditable: true)
                    } else {
                        cell.prepareUI(self.data.insuranceImageStr, isEditable: isEditable)
                    }
                }
            } else {
                cell.prepareUI(cellType == .carRegistration ? self.data.registrationImage : self.data.insuranceImage)
            }
            
            cell.action_btnUploadTap = { [weak self] (btn) in
                guard let `self` = self else { return }
                self.docPickerCellType = cellType
                self.btnOpenDocumentPicker(btn)
            }
            cell.action_btnDeleteTap = { [weak self] (btn) in
                guard let `self` = self else { return }
                self.showConfirmationPopUpView("Confirmation!", "Are you sure you want delete this image?", btns: [.cancel, .yes]) { button in
                    if button == .yes {
                        if cellType == .carRegistration {
                            if self.isEdit {
                                self.data.registrationImage = nil
                                self.data.registrationImageStr = nil
                            } else {
                                self.data.registrationImage = nil
                            }
                        } else {
                            if self.isEdit {
                                self.data.insuranceImage = nil
                                self.data.insuranceImageStr = nil
                            } else {
                                self.data.insuranceImage = nil
                            }
                        }
                        self.tableView.reloadRows(at: [IndexPath(row: self.arrCells.firstIndex(of: cellType)!, section: 0), IndexPath(row: self.arrCells.firstIndex(of: cellType)! - 1, section: 0)], with: .automatic)
                    }
                }
            }
        }
        else if let cell = cell as? ButtonTableCell {
            cell.btn.setTitle(isEdit ? "Update" : "Submit", for: .normal)
            cell.btnTapAction = { [ weak self] (_) in
                guard let `self` = self else { return }
                self.buttonSubmitCarTap()
            }
        }
    }
}

//MARK: - PhotoLibraryDelegate
extension AddCarVC: PhotoLibraryDelegate {
    
    func cameraMedia(_ image: UIImage) {
        if (docPickerCellType != .imageCollection && docPickerCellType != .addcarImage) {
            DispatchQueue.main.async {
                self.openImageCropper(image, pickerController: self)
            }
        } else {
            self.openImagePreview(img: image)
        }
    }
    
    func photoLibrary(didFinishedPicking media: [PHAsset]) {
        if docPickerCellType != .imageCollection && docPickerCellType != .addcarImage {
            if let imageAsset = media.first {
                let image = PhotoLibraryManager.shared.getImage(from: imageAsset)
                DispatchQueue.main.async {
                    self.openImageCropper(image, pickerController: self)
                }
            }
        } else {
            self.openImagePreview(img: nil, imgs: media)
        }
    }
    
    private func openImagePreview(img: UIImage? = nil, imgs: [PHAsset]? = nil) {
        let allowRemoveBg: Bool = true
        Task {
            var data: [AddCarImageModel] = []
            if let img {
                data = [AddCarImageModel(img)]
            }
            if let imgs {
                data = imgs.compactMap({AddCarImageModel(PhotoLibraryManager.shared.getImage(from: $0))})
            }
            
            //        if data.contains(where: {$0.image.fileSizeMB > 4}) {
            //            ValidationToast.showStatusMessage(message: kImageSizeValidation)
            //            data.removeAll(where: {$0.image.fileSizeMB > 4})
            //        }
            
            @MainActor func addCarImages() {
                if self.isEdit {
                    self.data.editCarImages.append(contentsOf: data.compactMap({$0.image}))
                } else {
                    self.data.carImages.append(contentsOf: data.compactMap({$0.image}))
                }
                self.docPickerCellType = nil
                self.tableView.reloadData()
            }
            
            if allowRemoveBg && !data.isEmpty {
                ///This code is for image background removable
                let vc = KPImagePreview.init(objs: data, sourceRace: nil, selectedIndex: nil, placeImg: _dummyPlaceImage, type: .addCar)
                vc.modalPresentationStyle = .fullScreen
                vc.callBack = { [ weak self] _ in
                    guard self != nil else { return }
                    addCarImages()
                }
                delay(0.15) {
                    self.present(vc, animated: true, completion: nil)
                }
            }
            else {
                ///this code is for using original image
                addCarImages()
            }
        }
    }
    
    func didCancelPicking() {
        docPickerCellType = nil
        nprint(items: "Media pick canceled")
    }
}

// MARK: - UIImagePicker Delegate
extension AddCarVC : RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource {
    
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
        docPickerCellType = nil
        controller.dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        let newImg = croppedImage.fixOrientation()!.scaleAndManageAspectRatio(_minImageSize.width)
        if self.docPickerCellType == .carRegistration {
            if newImg.fileSizeMB > 4 {
                ValidationToast.showStatusMessage(message: kImageSizeValidation)
            } else {
                self.data.registrationImage = newImg
            }
        } else if self.docPickerCellType == .insurance {
            if newImg.fileSizeMB > 4 {
                ValidationToast.showStatusMessage(message: kImageSizeValidation)
            } else {
                self.data.insuranceImage = newImg
            }
        } else {
            if self.isEdit {
                data.editCarImages.append(newImg)
            } else {
                self.data.carImages.append(newImg)
            }
        }
        docPickerCellType = nil
        controller.dismiss(animated: true) {
            self.tableView.reloadData()
        }
    }
    
    func imageCropViewControllerCustomMaskRect(_ controller: RSKImageCropViewController) -> CGRect {
        let width: CGFloat = _screenSize.width - (40 * _widthRatio)
        var height: CGFloat = (width * 3) / 4
        if self.docPickerCellType == .carRegistration || self.docPickerCellType == .insurance {
            height = (width * 9) / 16
        } else {
            height = (width * 3) / 4
        }
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

// MARK: - UIKeyboard Observer
extension AddCarVC {
    
    func addKeyboardObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 10, right: 0)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification){
        guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        tableView.contentInset = UIEdgeInsets.zero
    }
}

// MARK: - API Calls
extension AddCarVC {
    
    fileprivate func getCarAddDetails(_ type: CarMasterDetailsType, company: CarCompanyModel? = nil, modelId: String? = nil ) {
        var param: [String: Any] = [:]
        param["type"] = type.apiParam
        if type == .model {
            param["car_company_id"] = company?.id
        }
        if type == .year || type == .color {
            param["car_company_model_id"] = modelId
        }
        self.view.endEditing(true)
        showCentralSpinner()
        WebCall.call.getCarMasterDetails(param: param) { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            if type == .company {
                self.arrCarCompanies = []
                self.arrCarModels = []
                self.arrCarYears = []
                self.arrCarColors = []
            } else if type == .model {
                self.arrCarModels = []
                self.arrCarYears = []
                self.arrCarColors = []
            } else if type == .year {
                self.arrCarYears = []
                self.arrCarColors = []
            } else {
                self.arrCarColors = []
            }
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
                if type == .company {
                    if let cars = data["car_company"] as? [NSDictionary] {
                        for car in cars {
                            self.arrCarCompanies.append(CarCompanyModel(car))
                        }
                    }
                } else if type == .model {
                    if let models = data["car_company_model"] as? [NSDictionary] {
                        for model in models {
                            self.arrCarModels.append(CarNameModel(model))
                        }
                    }
                } else if type == .year {
                    if let years = data["car_manufacture_year"] as? [NSDictionary] {
                        for year in years {
                            self.arrCarYears.append(CarYearModel(year))
                        }
                    }
                } else {
                    if let colors = data["car_company_model_color"] as? [NSDictionary] {
                        for color in colors {
                            self.arrCarColors.append(CarColorModel(color))
                        }
                    }
                }
                self.tableView.reloadData()
            } else {
                self.showError(data: json)
            }
        }
        
    }
    
    func addUpdateCar() {
        var param: [String : Any] = [:]
        param = data.addParam
        param["deleted_images"] = deletedImgs
        
        var carImgs: [UIImage] = []
        var regImage: UIImage?
        var insImage: UIImage?
        
        if isEdit {
            param["car_id"] = data.id
            for img in data.editCarImages {
                if let image = img as? UIImage {
                    carImgs.append(image)
                }
            }
            if data.registrationImageStr == nil {
                regImage = data.registrationImage
            }
            if data.insuranceImageStr == nil {
                insImage = data.insuranceImage
            }
        } else {
            carImgs = data.carImages
            regImage = data.registrationImage
            insImage = data.insuranceImage
        }
        if carImgs.isEmpty && regImage == nil && insImage == nil {
            showCentralSpinner()
        } else {
            VHUD.show(progressLoader)
        }
        nprint(items: Date())
        WebCall.call.addUpdateCar(param: Setting.deviceInfo.merged(with: param), imgKey: "car_image[]", carImages: carImgs, regImage: regImage, insuranceImage: insImage) { [weak self] (upProgress) in
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
                _defaultCenter.post(name: Notification.Name.carListUpdate, object: nil)
                if data.id != nil {
                    _defaultCenter.post(name: Notification.Name.carDetailsUpdate, object: nil)
                }
                if self.isEdit {
                    self.showSuccessMsg(data: json, yCord: _navigationHeight)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.showSucessMsg()
                }
            } else {
                nprint(items: Date())
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    private func showSucessMsg() {
        let title: String = "Your car details added successfully!"
        let message: String = "Once our team verifies your car details and documents, you will get a notification."
        let success = SuccessPopUpView.initWithWindow(title, message, anim: .addCar)
        success.callBack = { [weak self] in
            guard let `self` = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
    }
}
