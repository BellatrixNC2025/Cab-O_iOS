import Foundation
import UIKit

// MARK: - Ratio Extension for device based scalling

struct DeviceType {
    static let iPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone
    static let iPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
}

//let _heightRatio : CGFloat = _screenSize.height / 667
//let _widthRatio : CGFloat = _screenSize.width / 375
//let _fontRatio: CGFloat = DeviceType.iPad ? _screenSize.height / 768 : _screenSize.width / 375

//let _heightRatio : CGFloat = DeviceType.iPad ? 1 : _screenSize.height / 667
//let _widthRatio : CGFloat = DeviceType.iPad ? 1 : _screenSize.width / 375
//let _fontRatio: CGFloat = DeviceType.iPad ? 1 : _screenSize.width / 375

let _heightRatio : CGFloat = DeviceType.iPad ? ((_screenSize.height / 768) * 0.8 ) : _screenSize.height / 667
let _widthRatio : CGFloat = DeviceType.iPad ? ((_screenSize.height / 768) * 0.8 ) : _screenSize.width / 375
let _fontRatio: CGFloat = DeviceType.iPad ? ((_screenSize.height / 768) * 0.8 ) : _screenSize.width / 375

extension CGFloat {

    var widthRatio: CGFloat{
        return self * _widthRatio
    }

    var heightRatio: CGFloat{
        return self * _heightRatio
    }
    
    var fontRatio: CGFloat{
        return self * _fontRatio
    }
}

extension Int {
    
    var widthRatio: CGFloat{
        return CGFloat(self) * _widthRatio
    }
    
    var heightRatio: CGFloat{
        return CGFloat(self) * _heightRatio
    }
    
    var fontRatio: CGFloat{
        return CGFloat(self) * _fontRatio
    }
}

extension Float {
    
    var widthRatio: CGFloat{
        return CGFloat(self) * _widthRatio
    }
    
    var heightRatio: CGFloat{
        return CGFloat(self) * _heightRatio
    }
    
    var fontRatio: CGFloat{
        return CGFloat(self) * _fontRatio
    }
}

extension Double {
    
    var widthRatio: CGFloat{
        return CGFloat(self) * _widthRatio
    }
    
    var heightRatio: CGFloat{
        return CGFloat(self) * _heightRatio
    }
    
    var fontRatio: CGFloat{
        return CGFloat(self) * _fontRatio
    }
}

