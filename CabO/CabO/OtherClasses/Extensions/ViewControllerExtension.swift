//
//  ViewControllerExtension.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

enum AppStoryboard : String {
    case Main
    case Auth
    case Home
    case Chat
    case Profile
    case CMS
    
    var instance : UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    func viewController<T : UIViewController>(viewControllerClass : T.Type, function : String = #function, line : Int = #line, file : String = #file) -> T {
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            fatalError("ViewController with identifier \(storyboardID), not found in \(self.rawValue) Storyboard.\nFile : \(file) \nLine Number : \(line) \nFunction : \(function)")
        }
        return scene
    }
    
    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }
}

extension UIViewController {
    
    // Not using static as it wont be possible to override to provide custom storyboardID then
    class var storyboardID : String {
        return "\(self)"
    }
    
    static func instantiate(from appStoryboard: AppStoryboard) -> Self {
        return appStoryboard.viewController(viewControllerClass: self)
    }
    
    func applyRoundedBackground(to cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView, isBottomRadius : Bool = false, isTopRadius : Bool = false) {
        // Remove old background if any
        cell.contentView.subviews.forEach {
            if $0.tag == 999 { $0.removeFromSuperview() }
        }

        let totalRows = tableView.numberOfRows(inSection: indexPath.section)

        let bgView = UIView()
        bgView.tag = 999
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = AppColor.vwBgColor

        cell.contentView.insertSubview(bgView, at: 0)

        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 7),
            bgView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -7),
            bgView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: -0.5),
            bgView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: 0)
        ])

        let cornerRadius: CGFloat = 19
        var maskedCorners: CACornerMask = []

        if totalRows == 1 {
            // Single cell
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if indexPath.row == 0 {
            // Top cell
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == totalRows - 1 {
            // Bottom cell
            maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }else{
            if isTopRadius {
                maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else if isBottomRadius {
                maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
        }

        bgView.layer.cornerRadius = cornerRadius
        bgView.layer.maskedCorners = maskedCorners
        bgView.layer.masksToBounds = false

        cell.backgroundColor = .clear // Required to show the custom background
    }

}


func delay(_ delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}
