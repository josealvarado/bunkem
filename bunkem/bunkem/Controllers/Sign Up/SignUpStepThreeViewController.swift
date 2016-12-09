//
//  SignUpStepThreeViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 11/19/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpStepThreeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var cityStateContainerView: UIView!
    @IBOutlet weak var cityStateLabel: UITextField!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var aboutYouContainerView: UIView!
    @IBOutlet weak var aboutYouTextView: UITextView!
    @IBOutlet weak var aboutLabelContainerView: UIView!
    @IBOutlet weak var visitContainerView: UIView!
    @IBOutlet weak var visitLabelContainerView: UIView!
    @IBOutlet weak var visitTextView: UITextView!
    
    var images = [UIImage]()
    var data = [String: String]()
    
    var ref: FIRDatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        cityStateContainerView.layer.borderColor = UIColor.black.cgColor
        cityStateContainerView.layer.borderWidth = 1
        
        
        aboutYouContainerView.layer.borderColor = UIColor.black.cgColor
        aboutYouContainerView.layer.borderWidth = 1
        aboutLabelContainerView.layer.borderColor = UIColor.black.cgColor
        aboutLabelContainerView.layer.borderWidth = 1
        
        visitContainerView.layer.borderColor = UIColor.black.cgColor
        visitContainerView.layer.borderWidth = 1
        visitLabelContainerView.layer.borderColor = UIColor.black.cgColor
        visitLabelContainerView.layer.borderWidth = 1
        
        ref = FIRDatabase.database().reference()
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
    
    // MARK: - User Interactions
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pictureButtonPressed(_ sender: UIButton) {
        print("Take picture")
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func createAccountButtonPressed(_ sender: UIButton) {
//        let email = "josealvarado111+bunkem3@gmail.com"
//        let password = "12345678"
        
        if let email = data["email"], let password = data["password"] {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                        switch errCode {
                        case .errorCodeInvalidEmail:
                            self.showAlert("Enter a valid email.")
                        case .errorCodeEmailAlreadyInUse:
                            self.showAlert("Email already in use.")
                        default:
                            self.showAlert("Error: \(error.localizedDescription)")
                        }
                    }
                    return
                }
                
                CurrentUser.user = User(userFirebase: user)
                
                if let cityAndState = self.cityStateLabel.text {
                    self.data["cityAndState"] = cityAndState
                }
                
                if let aboutYou = self.aboutYouTextView.text {
                    self.data["aboutYou"] = aboutYou
                }
                
                if let placesLikeToVisit = self.visitTextView.text {
                    self.data["placesLikeToVisit"] = placesLikeToVisit
                }
                
                self.ref?.child("users").child(CurrentUser.user.user.uid).updateChildValues(self.data as [NSObject : AnyObject])

                // Get a reference to the storage service, using the default Firebase App
                let storage = FIRStorage.storage()
                
                // This is equivalent to creating the full reference
                let storageRef = storage.reference(forURL: "gs://bunkem-4799f.appspot.com")

                // Create the file metadata
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/png"
                
                for (index, image) in self.images.enumerated() {
                    // Upload file and metadata to the object 'images/mountains.jpg'
                    let uploadTask = storageRef.child("images/profile/\(CurrentUser.user.user.uid)/pimg-\(index)").put(UIImagePNGRepresentation(image)!, metadata: metadata);
                    
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
                        print("Upload completed successfully")
                    }
                    
                    // Errors only occur in the "Failure" case
                    uploadTask.observe(.failure) { snapshot in
                        guard let storageError = snapshot.error else { return }
                        
                        print("Error \(storageError)")
                        
//                        guard let errorCode = FIRStorageErrorCode(rawValue: storageError.code) else { return }
//                        switch errorCode {
//                        case .ObjectNotFound:
//                            // File doesn't exist
//                            break
//                        case .Unauthorized:
//                            // User doesn't have permission to access file
//                            break
//                        case .Cancelled:
//                            // User canceled the upload
//                            break
//                        case .Unknown:
//                            break
//                        default:
//                            break
//                        }
                    }
                    
                }
                
                self.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)

                self.showAlert("By choosing to continue, I certify that I am at least 18 years old and have read & agreed to the Bunk'Em privacy policy & terms of use.")
            })
        }
    }
    
    // MARK: - Alerts
    
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "Bunk'Em App", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        self.dismiss(animated: true, completion: {
            
//            let indexPath = IndexPath(row: self.images.count, section: 0)
            self.images.append(self.fixOrientation(image))

//            self.collectionView.insertItems(at: [indexPath])
            
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
    
    // MARK: - CollectionView Delegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "signUpImage",
                                                      for: indexPath)
        let image = images[indexPath.row]
        cell.backgroundView = UIImageView(image: image)
        return cell
    }
    
    // MARK: - TextField Keyboard
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - TextView Keyboard
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

}
