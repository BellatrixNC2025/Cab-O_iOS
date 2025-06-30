import UIKit
import Kingfisher
import Photos
import AVFoundation
import QuartzCore
import ImageIO
import Accelerate

// MARK: - Image Resize
public extension UIImage {
    
    func mask(maskImage: UIImage) -> UIImage? {
        var maskedImage: UIImage? = nil
        
        let maskRef = maskImage.cgImage as CGImage?
        
        let mask = CGImage(maskWidth: maskRef!.width,
                           height: maskRef!.height,
                           bitsPerComponent: maskRef!.bitsPerComponent,
                           bitsPerPixel: maskRef!.bitsPerPixel,
                           bytesPerRow: maskRef!.bytesPerRow,
                           provider: maskRef!.dataProvider!, decode: nil, shouldInterpolate: false) as CGImage?
        
        let maskedImageRef = self.cgImage!.masking(mask!)
        
        maskedImage = UIImage(cgImage: maskedImageRef!)
        
        return maskedImage
    }
    
    class func createImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)//CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func resize(size:CGSize)-> UIImage {
        
        let scale  = UIScreen.main.scale
        let newSize = CGSize(width: size.width  , height: size.height  )
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        let context = UIGraphicsGetCurrentContext()
        
        context!.interpolationQuality = CGInterpolationQuality.high
        self.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
}

// MARK: - Image File Size
extension UIImage {
    
    var fileSize: Double {
        let imgData = NSData(data: self.jpegData(compressionQuality: 1)!)
        let imageSize: Int = imgData.count
        let size = Double(imageSize) / 1000.0
        print("actual size of image in KB: %f ", size)
        return size
    }
    
    var fileSizeMB: Double {
        return self.fileSize / 1000
    }
}

// MARK: - UIImage extension
extension UIImage {
    
    //Convert image into JPEG Formate
    func jpegImage() -> UIImage {
        let image = self.jpegData(compressionQuality: 1)
        let img = UIImage(data: image!)
        return img!
    }
    
    //Rotate image by 90 degree
    func rotate() -> UIImage {
        var image = self
        if self.imageOrientation == .up {
            image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .right)
        } else if self.imageOrientation == .right {
            image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .down)
        } else if self.imageOrientation == .down {
            image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .left)
        } else if self.imageOrientation == .left {
            image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .up)
        }
        return image
    }
}

// MARK: - Load GIF in ImageView
extension UIImageView{
    
    func loadGif(name: String?) {
        if let gifName = name {
            let gif = UIImage.gifImageWithName(gifName)
            self.image = gif
        }
    }
    
    var stringProperty:String {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as! String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func rotateImageHalf(duration: Double, isForward: Bool){
        let rotation : CABasicAnimation = CABasicAnimation(keyPath:"transform.rotation.z")
        rotation.duration = duration
        rotation.isRemovedOnCompletion = false
        rotation.repeatCount = 1
        rotation.fillMode = CAMediaTimingFillMode.forwards
        rotation.fromValue = NSNumber(value: 0.0)
        rotation.toValue = NSNumber(value: (isForward == true ? 3.14 : -3.14))
        self.layer.add(rotation, forKey: "rotate")
    }
}

private var AssociatedObjectHandle: UInt8 = 0

// MARK: - Comeress images
extension UIImage {
    
    func getImageFromRect(frame: CGRect) -> UIImage {
        if let croppedImg = self.cgImage!.cropping(to: frame) {
            return UIImage(cgImage: croppedImg)
        }
        return self
    }
    
    func getSquareImage() -> UIImage {
        var xCord: CGFloat = 0
        var yCord: CGFloat = 0
        
        let diff = size.height - size.width
        if diff >= 0{
            // Change y cord
            yCord = CGFloat(diff / 2)
        }else{
            // chage in x cord
            xCord = CGFloat((diff * -1) / 2)
        }
        
        let heightWid = min(size.width, size.height)
        let origin =  CGPoint(x: xCord, y: yCord)
        let newSize = CGSize(width: heightWid, height: heightWid)
        if let croppedImg = self.cgImage!.cropping(to: CGRect(origin: origin, size: newSize)) {
            return UIImage(cgImage: croppedImg)
        }
        
        return self
    }
    
    func fixedOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
            break
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }
        
        let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        return UIImage(cgImage: ctx.makeImage()!)
    }
    
    
    /// It will used to scale image size to down and maintain image ration.
    ///
    /// - Parameter toWidth: CGFloat type value, expect width
    /// - Returns: UIImage type object
    func scaleWithAspectRatioTo(_ width:CGFloat) -> UIImage {
        let oldWidth = size.width
        let oldHeight = size.height
        if oldHeight < width && oldWidth < width {
            return self
        }
        let scaleFactor = oldWidth > oldHeight ? width/oldWidth : width/oldHeight
        let newHeight = oldHeight * scaleFactor
        let newWidth = oldWidth * scaleFactor;
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
    /// It will used to reduce image resolution and maintain aspect ratio.
    ///
    /// - Parameter width: Expected width to reduce resolution
    /// - Returns: UIImage object return
    func scaleAndManageAspectRatio(_ width: CGFloat) -> UIImage {
        if let cgImage = cgImage {
            let oldWidth = size.width
            let oldHeight = size.height
            if oldHeight < width && oldWidth < width {
                return self
            }
            let scaleFactor = oldWidth > oldHeight ? width/oldWidth : width/oldHeight
            let newHeight = oldHeight * scaleFactor
            let newWidth = oldWidth * scaleFactor;
            var format = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: nil, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),version: 0, decode: nil, renderingIntent: CGColorRenderingIntent.defaultIntent)
            var sourceBuffer = vImage_Buffer()
            defer {
                sourceBuffer.data.deallocate()
            }
            var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
            guard error == kvImageNoError else { return self }
            
            // create a destination buffer
            _ = self.scale
            let destWidth = Int(newWidth)
            let destHeight = Int(newHeight)
            let bytesPerPixel = cgImage.bitsPerPixel/8
            let destBytesPerRow = destWidth * bytesPerPixel
            let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destHeight * destBytesPerRow)
            defer {
                destData.deallocate()
            }
            var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: destBytesPerRow)
            
            // scale the image
            error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
            guard error == kvImageNoError else { return self }
            
            // create a CGImage from vImage_Buffer
            let destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)?.takeRetainedValue()
            guard error == kvImageNoError else { return self }
            
            // create a UIImage
            let imgOutPut = destCGImage.flatMap { (cgImage) -> UIImage? in
                return UIImage(cgImage: cgImage, scale: 0.0, orientation: imageOrientation)
            }
            return imgOutPut ?? self
        }else{
            return self
        }
    }
    
    func scaleImage(toSize size: CGSize) -> UIImage? {
//        nprint(items: "Original Size \(self.size)")
//        nprint(items: "Scalling Size \(size)")
        let scale = max(size.width / self.size.width, size.height / self.size.height)
        let newWidth = self.size.width * scale
        let newHeight = self.size.height * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return scaledImage
    }
}


// MARK: - Get Image From asset
extension PHAsset {
    
    func getDisplayImage(size: CGSize, comp: @escaping (UIImage?) -> ()){
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        PHImageManager.default().requestImage(for: self, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, info) -> Void in
            comp(image)
        })
    }
    
    func getFullImage(comp: @escaping (UIImage?) -> ()) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        PHImageManager.default().requestImage(for: self, targetSize: CGSize(width: 800, height: 800), contentMode: PHImageContentMode.aspectFit, options: options, resultHandler: { (image, info) -> Void in
            DispatchQueue.main.async {
                comp(image)
            }
        })
    }
}

func loadImage(from urlString: String, completion: @escaping (UIImage?) -> ()) {
    guard let imageUrl = URL(string: urlString) else {
        completion(nil)
        return
    }

    let resource = imageUrl // URL(string: imageUrl)! // ImageResource(downloadURL: imageUrl)

    KingfisherManager.shared.retrieveImage(with: resource) { result in
        switch result {
        case .success(let value):
            // The image was downloaded successfully
            let image = value.image
            completion(image)
        case .failure(let error):
            // Handle failure (e.g., show placeholder, log error, etc.)
            print("Error downloading image: \(error)")
            completion(nil)
        }
    }
}

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
        case let (l?, r?):
            return l < r
        case (nil, _?):
            return true
        default:
            return false
    }
}

// MARK: - Load GIF From Different Sources
extension UIImage {
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL = URL(string: gifUrl)
        else {
            print("image named \"\(gifUrl)\" doesn't exist")
            return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
            print("SwiftGif: This image named \"\(name)\" does not exist")
            return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a < b {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * 350.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 1000.0)
        return animation
    }
}


extension UIImageView {
    
    func loadFromUrlString(_ urlString:String?, placeholder:Placeholder? = nil, needAccess:Bool = true, completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) {
        if let place = placeholder as? UIImage {
            self.image = place
        }
        if (urlString == nil) {
            return
        }
        let urStr = urlString?.replacingOccurrences(of: "|", with: "%7c")
        guard let urString = urStr else {return}
        let url = URL(string: urString)
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url, placeholder: placeholder, completionHandler: completionHandler)

    }
    
    func loadFromUrlString(_ urlString:URL?, placeholder:Placeholder? = nil, needAccess:Bool = true, completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) {
        if let place = placeholder as? UIImage {
            self.image = place
        }
        if (urlString == nil) {
            return
        }
        guard let url = urlString else {return}
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url, placeholder: placeholder, completionHandler: completionHandler)

    }
}
