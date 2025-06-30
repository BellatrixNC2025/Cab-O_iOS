//
//  NotificationService.swift
//  CabONotifications
//
//  Created by Octos.
//

import UserNotifications
import Intents

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    
    /// This is called when a notification is received.
    /// - Parameters:
    ///   - request: The notification request.
    ///   - contentHandler: The callback that needs to be called when the notification is ready to be displayed.
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler

        // the OS already did some work for us so we do make a work copy. If something does not go the way we expect or we run in a timeout we still have an attempt that can be displayed.
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        // unwrapping makes the compiler happy
        if(bestAttemptContent == nil) {
            return;
        }

        // this is the FCM / APNS payload defined by the server / caller
        // adjust it to your needs. This is just an example.
        let payload: [AnyHashable : Any] = bestAttemptContent!.userInfo

        // we assume that we get a type in the payload
        // either remove this line or add a type to your payload
        let type: String? = payload["redirect_key"] as? String

        // this is set by the server to indicate that this is a chat message
        if(type == "chat_notification") {
            _handleChatMessage(payload: payload)
            return;
        }

        // if we do not know the type we just pass the notification through
        // this is the case when we get a plain FCM / APNS notification
        if let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    /// Handles a chat message notification. It tries to display it as a communication notification.
    /// - Parameter payload: The FCM / APNS payload, defined by the server / caller.
    func _handleChatMessage(payload: [AnyHashable : Any]) {
        guard let content = bestAttemptContent else {
            return
        }

        guard let contentHandler = contentHandler else {
            return
        }
        
        NSLog("UserINFO ####### - \(payload)")
        let data = payload as NSDictionary
        
        let senderId: String = "f91840a2-a1bd-4d7a-a7ea-b4c08f7292e0" // use whatever value you have from your backend

        let senderDisplayName: String = data["title"] as? String ?? "Eco Carpool"

        let senderThumbnail: String = data["user_image"] as? String ?? ""
        
        guard let senderThumbnailUrl = URL(string: senderThumbnail) else {
            print("Invalid sender thumbnail URL")
            return
        }

        let senderThumbnailFileName = senderThumbnailUrl.lastPathComponent

        guard let senderThumbnailImageFileUrl = downloadAttachmentWithTimeout(from: senderThumbnailUrl, timeout: 5.0),
              let senderThumbnailImageFileData = try? Data(contentsOf: senderThumbnailImageFileUrl) else {
            print("Failed to download or save user image within timeout")
            return
        }

//        guard let senderThumbnailUrl: URL = URL(string: senderThumbnail) else {
//            return
//        }
//
//        let senderThumbnailFileName: String = senderThumbnailUrl.lastPathComponent // we grab the last part in the hope it contains the actual filename (any-picture.jpg)
//
//        guard let senderThumbnailImageData: Data = try? Data(contentsOf: senderThumbnailUrl),
//        let senderThumbnailImageFileUrl: URL = try? downloadAttachment(data: senderThumbnailImageData, fileName: senderThumbnailFileName),
//        let senderThumbnailImageFileData: Data = try? Data(contentsOf: senderThumbnailImageFileUrl) else {
//
//            return
//        }

        // example for adding attachments. Will be displayed by the communication notification.
//        var attachments: [UNNotificationAttachment] = [];

        // Note: TODO -> Make sure that it has a file extension. Otherwise the creation of an attachment will fail and return nil.
//        let link: String? = "https://fastly.picsum.photos/id/368/536/354.jpg?hmac=2b0UU6Y-8XxkiRBhatgBJ-ni3aWJ5CcVVENpX-mEiIA" // payload["link"] as? String

//        if let link = link, !link.isEmpty {
//            let url = URL(string: link)
//            let fileName = url!.lastPathComponent // same here => we hope it contains a proper file extension.
//
//            let imageData = try? Data(contentsOf: url!)
//
//            if(imageData != nil) {
//                let attachment = createNotificationAttachment(identifier: "media", fileName: fileName, data: imageData!, options: nil)
//
//                if attachment != nil {
//                    attachments.append(attachment!)
//                }
//            }
//        }

        // Add a preview to the notification.
        // Maybe the sender attached a picture or a video.
        // Handle attachments here before converting it to a communication notification
        // as I had issues when trying adding attachments afterwards.
        // Note: Those can be reused in the Notification Content Extension
        
//        content.attachments = attachments

        // profile picture that will be displayed in the notification (left side)
        let senderAvatar: INImage = INImage(imageData: senderThumbnailImageFileData)

        var personNameComponents = PersonNameComponents()
        personNameComponents.nickname = senderDisplayName

        // the person that sent the message
        // we need that as it is used by the OS trying to identify/match the sender with a contact
        // Setting ".unknown" as type will prevent the OS from trying to match the sender with a contact
        // as here this is an internal identifier and not a Mobile Number or email
        let senderPerson = INPerson(
                                    personHandle: INPersonHandle(
                                                    value: senderId,
                                                    type: .unknown
                                                ),
                                    nameComponents: personNameComponents,
                                    displayName: senderDisplayName,
                                    image: senderAvatar,
                                    contactIdentifier: nil,
                                    customIdentifier: nil,
                                    isMe: false, // this makes the OS recognize this as a sender
                                    suggestionType: .none
                                )

        // this is just a dummy person that will be used as the recipient
        let selfPerson = INPerson(
                                    personHandle: INPersonHandle(
                                                    value: "00000000-0000-0000-0000-000000000000", // no need to set a real value here
                                                    type: .unknown
                                                ),
                                    nameComponents: nil,
                                    displayName: nil,
                                    image: nil,
                                    contactIdentifier: nil,
                                    customIdentifier: nil,
                                    isMe: true, // this makes the OS recognize this as "US"
                                    suggestionType: .none
                                )

        // the actual message. We use the OS to send us ourselves a message.
        let incomingMessagingIntent = INSendMessageIntent(
                                            recipients: [selfPerson],
                                            outgoingMessageType: .outgoingMessageText, // This marks the message as outgoing
                                            content: content.body, // this will replace the content.body
                                            speakableGroupName: nil,
                                            conversationIdentifier: senderDisplayName, // this will be used as the conversation title
                                            serviceName: nil,
                                            sender: senderPerson, // this marks the message sender as the person we defined above
                                            attachments: []
                                    )

        incomingMessagingIntent.setImage(senderAvatar, forParameterNamed: \.sender)

        let interaction = INInteraction(intent: incomingMessagingIntent, response: nil)

        interaction.direction = .incoming

        do {
            // we now update / patch / convert our attempt to a communication notification.
            bestAttemptContent = try content.updating(from: incomingMessagingIntent) as? UNMutableNotificationContent

            // everything went alright, we are ready to display our notification.
            contentHandler(bestAttemptContent!)
        } catch let error {
            print("error \(error)")
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    /// Shorthand for creating a notification attachment.
    /// - Parameters:
    ///   - identifier: Unique identifier for the attachment. So it can be referenced within a Notification Content extension for example.
    ///   - fileName: The name of the file. This is the name that will be used to store the name on disk.
    ///   - data: A Data object based on the remote url.
    ///   - options: A dictionary of options. See Apple's documentation for more information.
    /// - Returns: A UNNotificationAttachment object.
    func createNotificationAttachment(identifier: String, fileName: String, data: Data, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        do {
           if let fileURL: URL = downloadAttachment(data: data, fileName: fileName) {
                let attachment: UNNotificationAttachment = try UNNotificationAttachment.init(identifier: identifier, url: fileURL, options: options)

                return attachment
            }

            return nil
        } catch let error {
            print("error \(error)")
        }

        return nil
    }

    /// Downloads a file from a remote url and stores it in a temporary folder.
    /// - Parameters:
    ///   - data: A Data object based on the remote url.
    ///   - fileName: The name of the file. This is the name that will be used to store the name on disk.
    /// - Returns: A URL object pointing to the temporary file on the phone. This can be used by a Notification Content extension for example.
    func downloadAttachment(data: Data, fileName: String) -> URL? {
        // Create a temporary file URL to write the file data to
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)

        do {
            // prepare temp subfolder
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let fileURL: URL = tmpSubFolderURL.appendingPathComponent(fileName)

            // Save the image data to the local file URL
            try data.write(to: fileURL)

            return fileURL
        } catch let error {
            print("error \(error)")
        }

        return nil
    }

    func downloadAttachmentWithTimeout(from url: URL, timeout: TimeInterval = 5.0) -> URL? {
        if url.absoluteString.isEmpty {
            return nil
        }
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = timeout
        sessionConfig.timeoutIntervalForResource = timeout

        let session = URLSession(configuration: sessionConfig)
        let semaphore = DispatchSemaphore(value: 0)
        var downloadedFileURL: URL?

        let task = session.dataTask(with: url) { data, response, error in
            defer { semaphore.signal() }

            guard let data = data else {
                print("Error downloading file: \(error?.localizedDescription ?? "No error description available")")
                return
            }

            // Create a temporary file URL
            let fileManager = FileManager.default
            let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
            let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)

            do {
                try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
                let fileURL = tmpSubFolderURL.appendingPathComponent(url.lastPathComponent)

                try data.write(to: fileURL)
                downloadedFileURL = fileURL
            } catch {
                print("Error saving downloaded file: \(error.localizedDescription)")
            }
        }

        task.resume()
        _ = semaphore.wait(timeout: .now() + timeout)

        return downloadedFileURL
    }
}

/*
 
 override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
   // Extract details like sender name, message content, etc.
   // Create an INSendMessageIntent based on the extracted data
     print("hereeeeeeee")
     
   let intent = INSendMessageIntent()
   // ... fill intent properties
   
   // Initialize interaction
   let interaction = INInteraction(intent: intent, response: nil)
   interaction.direction = .incoming
   
   interaction.donate { (error) in
     if let error = error {
       print("Error donating interaction: \(error)")
       return
     }
     
     // Create new notification content
     let content = UNMutableNotificationContent()
     content.title = "New Message"
     content.body = "John Doe: Hi!"
//        content.categoryIdentifier = .message
     content.subtitle = "Chat Group"
     content.attachments = []
       contentHandler(content)
       
//          do {
//              // we now update / patch / convert our attempt to a communication notification.
//              content.attachments = [try UNNotificationAttachment(identifier: "groupIcon", url: URL(string: "https://picsum.photos/300")!)]
//
//              // everything went alright, we are ready to display our notification.
//              contentHandler(content)
//          } catch let error {
//              print("error \(error)")
//          }
     
     // Call content handler
     
   }
 }
 
 */
