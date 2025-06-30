//
//  RideFilterModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit
import RangeSeekSlider

// MARK: - RideFilter CellType
enum RideFilterCellType {
    case datePicker, rangeMeter, seatRequired, ridePrefs, tripFilter
    
    var cellId: String {
        switch self {
        case .datePicker: return DatePickerCell.identifier
        case .rangeMeter: return "sliderCell"
        case .seatRequired: return AvailableSeatsCell.identifier
        case .ridePrefs: return CreateRidePreferenceCell.identifier
        case .tripFilter: return "tripFilterCell"
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .datePicker: return DatePickerCell.height
        case .seatRequired: return AvailableSeatsCell.titleCellHeight
        case .ridePrefs: return CreateRidePreferenceCell.addTitleHeight
        default: return UITableView.automaticDimension
        }
    }
}

// MARK: - RideFilter Cell
class RideFilterCell: ConstrainedTableViewCell {
    
    @IBOutlet weak var btnStopOver: UIButton!
    @IBOutlet weak var btnNoStopOver: UIButton!
    
    var action_stopover_selection: ((Int) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareUI(_ selected: Int?) {
        if let selected {
            btnStopOver.isSelected = selected == 0
            btnNoStopOver.isSelected = selected == 1
        } else {
            btnStopOver.isSelected = false
            btnNoStopOver.isSelected = false
        }
    }
    
    @IBAction func btnStopOverSelection(_ sender: UIButton) {
        prepareUI(sender.tag)
        action_stopover_selection?(sender.tag)
    }
}

// MARK: - RangeMeterCell
class RangeMeterCell: UITableViewCell {
    
    /// Outlets
    @IBOutlet weak var slider: UISlider!
//    @IBOutlet weak var sliderValue: UILabel!
    @IBOutlet weak var minValue: UILabel!
    @IBOutlet weak var maxValue: UILabel!
    
    let sliderValueLabel = UILabel()
    
    /// Variables
    var action_slider_changes: ((Float) -> ())?
    var action_info: ((AnyObject) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        slider.minimumValue = Float(_appDelegator.config.range_min)
        slider.maximumValue = Float(_appDelegator.config.range_max)
        
        self.minValue.text = "\(_appDelegator.config.range_min!) \nKms"
        self.maxValue.text = "\(_appDelegator.config.range_max!) \nKms"
        
        // Initial setup for the slider label
        sliderValueLabel.text = "0" // "0 Kms"
        sliderValueLabel.textAlignment = .center
        sliderValueLabel.font = AppFont.fontWithName(.regular, size: 10 * _fontRatio)
        sliderValueLabel.textColor = AppColor.primaryText
//        sliderValueLabel.backgroundColor = AppColor.primaryText
//        sliderValueLabel.layer.cornerRadius = 5
        sliderValueLabel.sizeToFit()
        
        // Add the label to the superview (not the slider itself)
        self.addSubview(sliderValueLabel)
        
        // Position the label for the first time
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateSliderLabelPosition()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSliderLabelPosition()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        updateSliderLabelPosition()
    }
    
    func setValue(_ value: Float) {
        slider.value = value
        sliderChanges(slider)
    }
    
    @IBAction func btnInfoTap(_ sender: UIButton) {
        action_info?(sender)
    }
    
    @IBAction func sliderChanges(_ sender: UISlider) {
        let val = Int(sender.value)
        action_slider_changes?(Float(val))
        
        let currentValue = Int(sender.value.rounded())
        sliderValueLabel.text = "\(currentValue)" // Kms"
        sliderValueLabel.sizeToFit()
        
        // Update the position of the label above the slider's thumb
        updateSliderLabelPosition()
    }
    
    func updateSliderLabelPosition() {
        guard let thumbFrame = sliderThumbFrame(slider: slider) else { return }
        
        let labelX = thumbFrame.midX
        let labelY = slider.frame.origin.y - sliderValueLabel.frame.height + (DeviceType.iPad ? (8 * _widthRatio) : 0)
        
        sliderValueLabel.center = CGPoint(x: labelX, y: labelY)
    }
    
    // Helper function to get the UISlider thumb rect
    func sliderThumbFrame(slider: UISlider) -> CGRect? {
        let trackRect = slider.trackRect(forBounds: slider.bounds)
        let thumbRect = slider.thumbRect(forBounds: slider.bounds, trackRect: trackRect, value: slider.value)
        return slider.convert(thumbRect, to: self)
    }
}

extension UILabel {
    func addPadding(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        let paddingView = UIView()
        paddingView.backgroundColor = self.backgroundColor
        paddingView.layer.cornerRadius = self.layer.cornerRadius
        paddingView.clipsToBounds = true

        self.translatesAutoresizingMaskIntoConstraints = false
        paddingView.addSubview(self)
        paddingView.translatesAutoresizingMaskIntoConstraints = false

        self.leadingAnchor.constraint(equalTo: paddingView.leadingAnchor, constant: left).isActive = true
        self.trailingAnchor.constraint(equalTo: paddingView.trailingAnchor, constant: -right).isActive = true
        self.topAnchor.constraint(equalTo: paddingView.topAnchor, constant: top).isActive = true
        self.bottomAnchor.constraint(equalTo: paddingView.bottomAnchor, constant: -bottom).isActive = true
    }
}
