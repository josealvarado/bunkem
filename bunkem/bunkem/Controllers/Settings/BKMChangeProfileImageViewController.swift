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

class BKMChangeProfileImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    var saveMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        let currentUser = FIRAuth.auth()!.currentUser!
//        let loadedUser = CurrentUser.user.user
        print(currentUser)
        // Get a reference to the storage service, using the default Firebase App
        let storage = FIRStorage.storage()
        
        // This is equivalent to creating the full reference
        let storageRef = storage.reference(forURL: "gs://bunkem-4799f.appspot.com")
        
        let downloadFilePath = "\(currentUser.uid)-pimg-\(0)"
        let filePath = "images/profile/\(downloadFilePath)"
        let spaceRef = storageRef.child(filePath)
        // d4jEUAaToFNmRvFnTXjXf4fDK612/
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        
        if let imageFilePath = SFDImageUploadDownloadService.initiateDownloadImage(fileName: filePath, downloadedFilePath: downloadFilePath) {
            let downloadedImage = UIImage(contentsOfFile: imageFilePath.path)
            
                imageView.image = downloadedImage
        } else {
            spaceRef.data(withMaxSize: 1024 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    // Uh-oh, an error occurred!
                    print("error \(error)")
                } else {
                    
                    print("Successful download \(filePath)")
                    // Data for "images/island.jpg" is returned
                    
                    if let data = data, let downloadedImage = UIImage(data: data) {
                        
                        let _ = SFDImageUploadDownloadService.saveImageLocally(image: downloadedImage, fileName: downloadFilePath)
                        
                        self.imageView.image = downloadedImage
                    }
                }
            }
        }
        
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
        print("done button pressed")
        if saveMode {
            SVProgressHUD.show()
            
            // Get a reference to the storage service, using the default Firebase App
            let storage = FIRStorage.storage()
            
            // This is equivalent to creating the full reference
            let storageRef = storage.reference(forURL: "gs://bunkem-4799f.appspot.com")
            
            // Create the file metadata
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/png"
            
            // Upload file and metadata to the object 'images/mountains.jpg'
            let uploadTask = storageRef.child("images/profile/\(CurrentUser.user.user.uid)/pimg-\(index)").put(UIImagePNGRepresentation(self.imageView.image!)!, metadata: metadata);
            
            // Listen for state changes, errors, and completion of the upload.
            uploadTask.observe(.pause) { snapshot in
                // Upload paused
            }
            
            uploadTask.observe(.resume) { snapshot in
                // Upload resumed, also fires when the upload starts
            }
            
            uploadTask.observe(.progress) { snapshot in
                // Upload reported progress
                if let progress = snapshot.progress {
                    _ = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                }
            }
            
            uploadTask.observe(.success) { snapshot in
                SVProgressHUD.dismiss()

                print("Upload completed successfully")
                
                let _ = self.navigationController?.popViewController(animated: true)
            }
            
            // Errors only occur in the "Failure" case
            uploadTask.observe(.failure) { snapshot in
                SVProgressHUD.dismiss()

                guard let storageError = snapshot.error else { return }
                
                print("Error \(storageError)")
            }
            
            
            

        } else {
            saveBarButtonItem.title = "Save"
            saveMode = true
            
            print("Take picture")
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePickerController.allowsEditing = false
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }

    @IBAction func changeImageButtonPressed(_ sender: UIButton) {
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        self.dismiss(animated: true, completion: {
            
            self.imageView.image = self.fixOrientation(image)
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
}
