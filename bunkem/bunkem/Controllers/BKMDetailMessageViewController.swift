//
//  BKMDetailMessageViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 1/11/17.
//  Copyright © 2017 BunkEm. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController
import Photos

class BKMDetailMessageViewController: JSQMessagesViewController {

    var matchObject: [String: AnyObject]?
    var channelRef: FIRDatabaseReference?
//    var channel: Channel? {
//        didSet {
//            title = channel?.name
//        }
//    }
    
    var messages = [JSQMessage]()
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    private lazy var messageRef: FIRDatabaseReference = self.channelRef!.child("messages")
    private var newMessageRefHandle: FIRDatabaseHandle?
    
    lazy var storageRef: FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://bunkem-4799f.appspot.com")
    private let imageURLNotSetKey = "NOTSET"
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    
    private var updatedMessageRefHandle: FIRDatabaseHandle?

    var ref: FIRDatabaseReference!
    var matchedUser: User?
    
    var callback: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.senderId = CurrentUser.user.identifier
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        observeMessages()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.jsq_defaultTypingIndicator(), style: .plain, target: self, action: #selector(BKMDetailMessageViewController.didPressRightBarButtonItem(button:)))

        print("matchObject \(matchObject)")
        
        if let username = matchObject?["username"] as? String {
            self.title = username
        }
        
        guard let matchIdentifier = matchObject?["identifier"] as? String else { return }
        
        ref = FIRDatabase.database().reference()
        
        ref.child("users").child(matchIdentifier).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Get user value
            guard let matchedUserJSON = snapshot.value as? [String: AnyObject] else {
                print("NO USER FOUND")
                return
            }

            self.matchedUser = User(userJSON: matchedUserJSON)
            self.matchedUser?.identifier = matchIdentifier
            
            print("value \(matchedUserJSON)")
        }) { (error) in
            print(error.localizedDescription)
        }

    }
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func didPressRightBarButtonItem(button: UIBarButtonItem)  {
        print("TOP RIGHT")
        
        guard let activeUser = matchedUser else { return }
        
        let otherAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let callFunction = UIAlertAction(title: "View Profile", style: UIAlertActionStyle.default) { _ in
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "BKMProfileDetailViewController") as? BKMProfileDetailViewController {
                vc.activeUser = activeUser
//                vc.displayExtraNavBarButton = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        otherAlert.addAction(callFunction)
        
        let unMatchAction = UIAlertAction(title: "Unmatch/Block", style: UIAlertActionStyle.default) { _ in
            
            print("activeUser \(activeUser.identifier)")
            
            BKMMatchingService.unMatch(activeUser)
            
            self.callback!("refresh")
            let _ = self.navigationController?.popViewController(animated: true)
        }
        otherAlert.addAction(unMatchAction)
        
        let dismiss = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        otherAlert.addAction(dismiss)
        
        present(otherAlert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - JSQMessageData Protocol
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    // MARK: - User Interactions

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId() // 1
        let messageItem = [ // 2
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            ]
        
        itemRef.setValue(messageItem) // 3
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        
        finishSendingMessage() // 5
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
//        let picker = UIImagePickerController()
//        picker.delegate = self
//        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
//            picker.sourceType = UIImagePickerControllerSourceType.camera
//        } else {
//            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
//        }
//        
//        present(picker, animated: true, completion:nil)
        
        self.inputToolbar.contentView.textView.resignFirstResponder()

        let otherAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        if let matchedUser = matchedUser, matchedUser.sharePhoneNumber {
            print("shared user lets me call them")
            print("do I ? ", CurrentUser.user.sharePhoneNumber)
        }
        
        if let matchedUser = matchedUser,  let url = NSURL(string: "tel://\(matchedUser.phoneNumber)"), UIApplication.shared.canOpenURL(url as URL) && matchedUser.sharePhoneNumber && CurrentUser.user.sharePhoneNumber {
            let printSomething = UIAlertAction(title: "Make a call", style: UIAlertActionStyle.default) { _ in
                UIApplication.shared.openURL(url as URL)
            }
            otherAlert.addAction(printSomething)
        }
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            let printSomething = UIAlertAction(title: "Take a picture with camera", style: UIAlertActionStyle.default) { _ in
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = UIImagePickerControllerSourceType.camera
                self.present(picker, animated: true, completion:nil)
            }
            otherAlert.addAction(printSomething)
        }
        
        
        let callFunction = UIAlertAction(title: "Send a picture from photos", style: UIAlertActionStyle.default) { _ in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(picker, animated: true, completion:nil)
        }
        otherAlert.addAction(callFunction)
        
        let dismiss = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        otherAlert.addAction(dismiss)
        
        present(otherAlert, animated: true, completion: nil)
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    
    
    // MARK: - JSQMessagesCollectionViewDataSource

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    // Remove the Avatars
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = messages[indexPath.item] // 1
        
        print("message \(message)")
        
        if message.isMediaMessage {
            let mediaIteam = message.media
            
//            if (mediaIteam?.isKind(of: JSQPhotoMediaItem.))! {
//                
//            }
            
            if let photoItem = mediaIteam as? JSQPhotoMediaItem {
                let image = photoItem.image
                
                
            }
        }

    }
    
    // Other
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId!,
            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef.key
    }
    
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }
    
    private func observeMessages() {
        messageRef = channelRef!.child("messages")
        // 1.
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        // 2. We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            // 3
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                // 4
                self.addMessage(withId: id, name: name, text: text)
                
                // 5
                self.finishReceivingMessage()
            } else if let id = messageData["senderId"] as String!,
                let photoURL = messageData["photoURL"] as String! { // 1
                // 2
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    // 3
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    // 4
                    if photoURL.hasPrefix("gs://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
            } else {
                print("Error! Could not decode message data")
            }
        })
        
        // We can also use the observer method to listen for
        // changes to existing messages.
        // We use this to be notified when a photo has been stored
        // to the Firebase Storage, so we can update the message data
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String> // 1
            
            if let photoURL = messageData["photoURL"] as String! { // 2
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] { // 3
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key) // 4
                }
            }
        })
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        // 1
        let storageRef = FIRStorage.storage().reference(forURL: photoURL)
        
        // 2
        storageRef.data(withMaxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            // 3
            storageRef.metadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                // 4
                if (metadata?.contentType == "image/gif") {
//                    mediaItem.image = UIImage.gifWithData(data!)
                    mediaItem.image = UIImage.init(data: data!)

                } else {
                    mediaItem.image = UIImage.init(data: data!)
                }
                self.collectionView.reloadData()
                
                // 5
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }
}

// MARK: Image Picker Delegate
extension BKMDetailMessageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        
        guard let channelId = matchObject?["channelId"] as? String else { return }

        // 1
        if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
//            // Handle picking a Photo from the Photo Library
//            // 2
//            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
//            let asset = assets.firstObject
//            
//            // 3
//            if let key = sendPhotoMessage() {
//                // 4
//                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
//                    let imageFileURL = contentEditingInput?.fullSizeImageURL
//                    
//                    // 5
//                    let path = "channel/\(channelId)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
//                    
//                    // 6
//                    self.storageRef.child(path).putFile(imageFileURL!, metadata: nil) { (metadata, error) in
//                        if let error = error {
//                            print("Error uploading photo: \(error.localizedDescription)")
//                            return
//                        }
//                        // 7
//                        self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
//                    }
//                })
//            }
            
            do {
                let _ = try FileManager.default.createDirectory(
                    at: NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("download")!,
                    withIntermediateDirectories: true,
                    attributes: nil)
                
                let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("fileName.jpg")
                
                let image = info[UIImagePickerControllerOriginalImage]
                
                try UIImageJPEGRepresentation(image as! UIImage,1.0)?.write(to: fileURL!, options: [])
                
                if let key = sendPhotoMessage() {
                    // 4
//                    asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
//                        let imageFileURL = contentEditingInput?.fullSizeImageURL
                    
                        // 5
                        let path = "channel/\(channelId)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
                        
                        // 6
                        self.storageRef.child(path).putFile(fileURL!, metadata: nil) { (metadata, error) in
                            if let error = error {
                                print("Error uploading photo: \(error.localizedDescription)")
                                return
                            }
                            // 7
                            self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                        }
//                    })
                }
            }
            catch {
                print("error is ", error)
            }
        } else {
            // Handle picking a Photo from the Camera
            // 1
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            // 2
            if let key = sendPhotoMessage() {
                // 3
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                // 4
                let imagePath = "channel/" + channelId + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
                // 5
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpeg"
                // 6
                storageRef.child(imagePath).put(imageData!, metadata: metadata) { (metadata, error) in
                    if let error = error {
                        print("Error uploading photo: \(error)")
                        return
                    }
                    // 7
                    self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}
