//
//  BKMChangeProfileImageViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 12/18/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase
import SVProgressHUD

class BKMChangeProfileImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var pictureButton: UIButton!
    var saveMode = false
    
    var images = [[String: AnyObject]]()
    var imageArray = [Int: UIImage]()
    
    var photoURLS = [String]()
    var ref: FIRDatabaseReference?

    var cellTapped: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        ref = FIRDatabase.database().reference()
        images = CurrentUser.user.images
        images = images.sorted { ($0["order"] as? Int)! < ($1["order"] as? Int)! }

        
        for (index, dict) in images.enumerated() {
            print("index \(index) \(dict)")
            if let photoURL = dict["photoURL"] as? String {
                photoURLS.append(photoURL)
            }
        }
        
        self.collectionView.reloadData()

        let storageRef = FIRStorage.storage().reference(forURL: "gs://bunkem-4799f.appspot.com/profile/Y94H9xX5ktTdPLT38maHAGCHdla2/506496732086/asset.jpg")
        storageRef.data(withMaxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            if let photoImage = UIImage.init(data: data!) {
                self.imageView.image = photoImage
            }
        }

    
        // Do any additional setup after loading the view.
        
//        if CurrentUser.user.photoURL != "" {
//            let storageRef = FIRStorage.storage().reference(forURL: CurrentUser.user.photoURL)
//            storageRef.data(withMaxSize: INT64_MAX){ (data, error) in
//                if let error = error {
//                    print("Error downloading image data: \(error)")
//                    return
//                }
//                
//                if let photoImage = UIImage.init(data: data!) {
//                    self.imageView.image = photoImage
//                }
//            }
//        }
        


        
//        let currentUser = FIRAuth.auth()!.currentUser!
//        print(currentUser)

//        // Get a reference to the storage service, using the default Firebase App
//        let storage = FIRStorage.storage()
//        
//        // This is equivalent to creating the full reference
//        let storageRef = storage.reference(forURL: "gs://bunkem-4799f.appspot.com")
//        
//        let downloadFilePath = "\(currentUser.uid)-pimg-\(0)"
//        let filePath = "images/profile/\(downloadFilePath)"
//        let spaceRef = storageRef.child(filePath)
//        // d4jEUAaToFNmRvFnTXjXf4fDK612/
//        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
//        
//        if let imageFilePath = SFDImageUploadDownloadService.initiateDownloadImage(fileName: filePath, downloadedFilePath: downloadFilePath) {
//            let downloadedImage = UIImage(contentsOfFile: imageFilePath.path)
//            
//                imageView.image = downloadedImage
//        } else {
//            spaceRef.data(withMaxSize: 1024 * 1024 * 1024) { (data, error) -> Void in
//                if (error != nil) {
//                    // Uh-oh, an error occurred!
//                    print("error \(error)")
//                } else {
//                    
//                    print("Successful download \(filePath)")
//                    // Data for "images/island.jpg" is returned
//                    
//                    if let data = data, let downloadedImage = UIImage(data: data) {
//                        
//                        let _ = SFDImageUploadDownloadService.saveImageLocally(image: downloadedImage, fileName: downloadFilePath)
//                        
//                        self.imageView.image = downloadedImage
//                    }
//                }
//            }
//        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        
        var newImage = 0
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/png"

        var imageCounter = 0
        SVProgressHUD.show()

        for (index, var dict) in images.enumerated() {
            
            print("index \(index) \(dict) ")
            guard let image = imageArray[index] else {
                imageCounter += 1
                if imageCounter == self.images.count {
                    SVProgressHUD.dismiss()
                }

                continue
            }
            guard let imageData = UIImageJPEGRepresentation(image, 1.0) else {
                imageCounter += 1
                if imageCounter == self.images.count {
                    SVProgressHUD.dismiss()
                }

                continue
            }
            
            guard let photoURL = dict["photoURL"] as? String else {
                // New Image
                print("New Image")
                let storageRef = FIRStorage.storage().reference(forURL: "gs://bunkem-4799f.appspot.com")
                
                
                let imagePath = "profile/" + CurrentUser.user.user.uid + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/asset.jpg"

                storageRef.child(imagePath).put(imageData, metadata: metadata) { (metadata, error) in
                    imageCounter += 1
                    if imageCounter == self.images.count {
                        SVProgressHUD.dismiss()
                    }

                    print("New Image \(index)")
                    

                    if let error = error {
                        print("Error uploading photo: \(error)")
                        
                        
                    } else {
                        let imageRef = self.ref?.child("users").child(CurrentUser.user.user.uid).child("images").childByAutoId()
                        
                        let imageItem = [
                            "photoURL": storageRef.child((metadata?.path)!).description,
                            "order": CurrentUser.user.images.count + newImage
                            ] as [String : Any]
                        
                        dict["photoURL"] = storageRef.child((metadata?.path)!).description as AnyObject?
                        
                        imageRef?.setValue(imageItem)
                        newImage = newImage + 1
                        
                        print("New Image  saved Image \(index) \(newImage)")
                        print("Image Item \(imageItem)")
                    }
                }
                continue
            }
            
            // Replace old Image
            print("OLD IMAGE")
            let storageRef = FIRStorage.storage().reference(forURL: photoURL)
            storageRef.child("").put(imageData, metadata: metadata) { (metadata, error) in
                print("OLD IMAGE \(index)")
                imageCounter += 1
                if imageCounter == self.images.count {
                    SVProgressHUD.dismiss()
                }

                if let error = error {
                    print("Error uploading photo: \(error)")
                    
                    return
                } else {
                    print("OLD saved Image \(index)")
                }
            }


            
//            guard index >= userImagesCopy.count else {
//                
//                print("replace")
//                
////                dict["order"] = index as AnyObject?
////                newImages.append(dict)
////                
////                guard let photoURL = dict["photoURL"] as? String else { continue }
////                
////                guard let imageData = UIImageJPEGRepresentation(imageArray[index], 1.0) else { continue }
////                
////                
////                let metadata = FIRStorageMetadata()
////                metadata.contentType = "image/png"
////                
////                let storageRef = FIRStorage.storage().reference(forURL: photoURL)
////                storageRef.child("").put(imageData, metadata: metadata) { (metadata, error) in
////                    
////                    if let error = error {
////                        print("Error uploading photo: \(error)")
////                        
////                        return
////                    }
////                }
//                
//                continue
//            }
//            
//            
//            print("new")
            
            
            
        }
        
        ////////////
        
//        guard let image = self.imageView.image else { return }
//        guard let imageData = UIImageJPEGRepresentation(image, 1.0) else { return }
//        
//        
//        let metadata = FIRStorageMetadata()
//        metadata.contentType = "image/png"
//
//        let storageRef = FIRStorage.storage().reference(forURL: CurrentUser.user.photoURL)
//        storageRef.child("").put(imageData, metadata: metadata) { (metadata, error) in
//            
//            if let error = error {
//                print("Error uploading photo: \(error)")
//                                    
//                return
//            }
//        }
        
        /////////////
        
            
//            // Get a reference to the storage service, using the default Firebase App
//            let storage = FIRStorage.storage()
//            
//            // This is equivalent to creating the full reference
//            let storageRef = storage.reference(forURL: "gs://bunkem-4799f.appspot.com")
//            
//            // Create the file metadata
//            let metadata = FIRStorageMetadata()
//            metadata.contentType = "image/png"
//            
//            // Upload file and metadata to the object 'images/mountains.jpg'
//            let uploadTask = storageRef.child("images/profile/\(CurrentUser.user.user.uid)/pimg-\(index)").put(UIImagePNGRepresentation(self.imageView.image!)!, metadata: metadata);
//            
//            // Listen for state changes, errors, and completion of the upload.
//            uploadTask.observe(.pause) { snapshot in
//                // Upload paused
//            }
//            
//            uploadTask.observe(.resume) { snapshot in
//                // Upload resumed, also fires when the upload starts
//            }
//            
//            uploadTask.observe(.progress) { snapshot in
//                // Upload reported progress
//                if let progress = snapshot.progress {
//                    _ = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
//                }
//            }
//            
//            uploadTask.observe(.success) { snapshot in
//                SVProgressHUD.dismiss()
//
//                print("Upload completed successfully")
//                
//                let _ = self.navigationController?.popViewController(animated: true)
//            }
//            
//            // Errors only occur in the "Failure" case
//            uploadTask.observe(.failure) { snapshot in
//                SVProgressHUD.dismiss()
//
//                guard let storageError = snapshot.error else { return }
//                
//                print("Error \(storageError)")
//            }
            
            
            

    }

    @IBAction func changeImageButtonPressed(_ sender: UIButton) {
        displayActionSheet()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        self.dismiss(animated: true, completion: {
            
            self.imageView.image = self.fixOrientation(image)

            if let cellTapped = self.cellTapped {
                self.imageArray[cellTapped] = self.fixOrientation(image)
            } else {
                
                let newImage = [
                    "order" : self.images.count
                    ] as [String : Any]
                
                self.imageArray[self.images.count] = self.fixOrientation(image)
                self.images.append(newImage as [String : AnyObject])
                
                if self.images.count > Profile.maximumImages {
                    self.pictureButton.isHidden = true
                    
                }
            }
            self.collectionView.reloadData()
        })
    }
    
    func fixOrientation(_ img:UIImage) -> UIImage {
        if (img.imageOrientation == UIImageOrientation.up) {
            return img;
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
    
    // MARK: UICollectionView Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileImage",
                                                      for: indexPath)
        
        cell.backgroundView = nil
        
        let row = indexPath.row
        let imageObject = images[row]

        print("row \(row) \(imageObject)")
        if let photoImage = imageArray[row] {
            print("re-use image \(row)")
//            let photoImage = imageArray[row]
            let imageView = UIImageView(image: photoImage)
            cell.backgroundView = imageView
            return cell
        }
        
        if let photoURL = imageObject["photoURL"] as? String, photoURL != "" {
            
            let storageRef = FIRStorage.storage().reference(forURL: photoURL)
            storageRef.data(withMaxSize: INT64_MAX){ (data, error) in
                if let error = error {
                    print("Error downloading image data: \(error)")
                    return
                }
                cell.backgroundView = nil

                if let photoImage = UIImage.init(data: data!) {
                    let imageView = UIImageView(image: photoImage)
                    cell.backgroundView = imageView
                    print("index \(row) \(photoURL) \(self.imageArray.count)")
                    self.imageArray[row] = photoImage
                    
//                    self.imageArray[self.images.count] = self.fixOrientation(image)

                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 330, height: 320)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        print("item \(row)")
        cellTapped = row
        
        displayActionSheet()
    }
    
    func displayActionSheet() {
        let otherAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            let printSomething = UIAlertAction(title: "Take a picture with camera", style: UIAlertActionStyle.default) { _ in
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = UIImagePickerControllerSourceType.camera
                self.present(picker, animated: true, completion:nil)
            }
            otherAlert.addAction(printSomething)
        }
        
        
        let callFunction = UIAlertAction(title: "Select a picture from photos", style: UIAlertActionStyle.default) { _ in
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
}
