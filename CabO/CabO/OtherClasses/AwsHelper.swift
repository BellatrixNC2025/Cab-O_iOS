//
//  AwsHelper.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import AWSS3
import AWSCore

typealias progressBlock = (_ progress: Double) -> Void
typealias completionBlock = (_ response: Any?, _ error: Error?, _ presignedURL:String?) -> Void

// MARK: - AWSS3Manager
class AWSS3Manager {

    var preSignedURLString = ""
    static let shared = AWSS3Manager()
    private init () { }
    
    func getPreSignedURL( S3DownloadKeyName: String)->String{
        let getPreSignedURLRequest = AWSS3GetPreSignedURLRequest()
        getPreSignedURLRequest.httpMethod = AWSHTTPMethod.GET
        getPreSignedURLRequest.key = S3DownloadKeyName
        getPreSignedURLRequest.bucket = _aws_bucket_name
        getPreSignedURLRequest.expires = Date(timeIntervalSinceNow: 3600)
        
        AWSS3PreSignedURLBuilder.default().getPreSignedURL(getPreSignedURLRequest).continueWith { (task:AWSTask<NSURL>) -> Any? in
            if let error = task.error as NSError? {
                print("Error: \(error)")
                return nil
            }
            self.preSignedURLString = (task.result?.absoluteString)!
            return nil
        }
        return self.preSignedURLString
    }
    
    /// Upload Image to AWS
    /// - Parameters:
    ///   - image: UIImage
    ///   - progress: Returns upload progress
    ///   - completion: Completion block
    func uploadImage(image: UIImage, progress: progressBlock?, completion: completionBlock?) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            let error = NSError(domain:"", code:402, userInfo:[NSLocalizedDescriptionKey: "invalid image"])
            completion?(nil, error,"")
            return
        }
        
        let imageName = "\(Int((Date().timeIntervalSince1970))).png"
        let fileUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(imageName)
//        let fileName = "hopp_images/" + imageName
        let fileName = "ecp/" + imageName
            
        do {
            try imageData.write(to: fileUrl)
            self.uploadfile(fileUrl: fileUrl, fileName: fileName, contenType: "image", progress: progress, completion: completion)
        } catch {
            let error = NSError(domain:"", code:402, userInfo:[NSLocalizedDescriptionKey: "invalid image"])
            completion?(nil, error, "")
        }
    }
    
    // MARK: - AWS file upload

    private func uploadfile(fileUrl: URL, fileName: String, contenType: String, progress: progressBlock?, completion: completionBlock?) {
        // Upload progress block
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task, awsProgress) in
            guard let uploadProgress = progress else { return }
            DispatchQueue.main.async {
                uploadProgress(awsProgress.fractionCompleted)
            }
        }
        
        // Completion block
        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                if error == nil {
                    let url = AWSS3.default().configuration.endpoint.url
                    let publicURL = url?.appendingPathComponent(_aws_bucket_name).appendingPathComponent(fileName)
                    print("Uploaded to:\(String(describing: publicURL))")
                    if let completionBlock = completion {
                        completionBlock(publicURL?.absoluteString, nil,publicURL?.absoluteString)
                    }
                } else {
                    if let completionBlock = completion {
                        completionBlock(nil, error,"")
                    }
                }
            })
        }
        
        // Start uploading using AWSS3TransferUtility
        let awsTransferUtility = AWSS3TransferUtility.default()
        awsTransferUtility.uploadFile(fileUrl, bucket: _aws_bucket_name, key: fileName, contentType: contenType, expression: expression, completionHandler: completionHandler).continueWith { (task) -> Any? in
            if let error = task.error {
                print("error is: \(error.localizedDescription)")
            }
            if let _ = task.result {
                // your uploadTask
            }
            return nil
        }
    }
    
}

extension AWSS3Manager{
    
    // Upload video from local path url
    func uploadVideo(videoUrl: URL, progress: progressBlock?, completion: completionBlock?) {
        let fileName = self.getUniqueFileName(fileUrl: videoUrl)
        self.uploadfile(fileUrl: videoUrl, fileName: fileName, contenType: "video/mp4", progress: progress, completion: completion)
    }
    
    // Upload auido from local path url
    func uploadAudio(audioUrl: URL, progress: progressBlock?, completion: completionBlock?) {
        let fileName = self.getUniqueFileName(fileUrl: audioUrl)
        self.uploadfile(fileUrl: audioUrl, fileName: fileName, contenType: "audio", progress: progress, completion: completion)
    }
    
    // Upload files like Text, Zip, etc from local path url
    func uploadOtherFile(fileUrl: URL, conentType: String, progress: progressBlock?, completion: completionBlock?) {
        let fileName = self.getUniqueFileName(fileUrl: fileUrl)
        self.uploadfile(fileUrl: fileUrl, fileName: fileName, contenType: conentType, progress: progress, completion: completion)
    }
    
    // Get unique file name
    func getUniqueFileName(fileUrl: URL) -> String {
        let strExt: String = "." + (URL(fileURLWithPath: fileUrl.absoluteString).pathExtension)
        let imageName = "\(Int((Date().timeIntervalSince1970)))" + strExt
//        let fileName = "ysi_images/" + imageName
        let fileName = imageName

        return fileName
    }
}
