import UIKit
import Photos

final class SelectedAssetsCell: UICollectionViewCell {

    //----------------------------
    //MARK: IBOulet
    @IBOutlet private weak var imgAsset: UIImageView!
    @IBOutlet private weak var imgTickRight: UIImageView!
    @IBOutlet private weak var labelDuration: UILabel!
    
    //----------------------------
    //MARK: Properties
    static let identifier: String = "\(classForCoder())"
    
    //----------------------------
    //MARK: View LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.labelDuration.font = UIFont.systemFont(ofSize: DeviceType.iPad ? 20 : 14, weight: .bold)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgTickRight.layer.cornerRadius = imgTickRight.frame.height / 2
    }
    
    func setup(assetImg: PHAsset, isSelected: Bool) {
        DispatchQueue.main.async {
            self.labelDuration.isHidden = assetImg.mediaType == .image
            self.labelDuration.text = self.formatVideoDuration(assetImg.duration)
            self.imgAsset.image = PhotoLibraryManager.shared.getImage(from: assetImg, size: CGSize(width: 200, height: 200))
            self.imgTickRight.isHidden = !isSelected
        }
    }
    
    func formatVideoDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad

        return formatter.string(from: duration) ?? "00:00"
    }
}
