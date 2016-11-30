//
//  SignUpStepThreeViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 11/19/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpStepThreeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var cityStateContainerView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var aboutYouContainerView: UIView!
    @IBOutlet weak var aboutLabelContainerView: UIView!
    @IBOutlet weak var visitContainerView: UIView!
    @IBOutlet weak var visitLabelContainerView: UIView!
    
    var images = [UIImage]()
    var data = [String: String]()

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
    
    @IBAction func pictureButtonPressed(_ sender: UIButton) {
        print("Take picture")
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func createAccountButtonPressed(_ sender: UIButton) {
        let email = "josealvarado111+bunkem3@gmail.com"
        let password = "12345678"
        
//        if let email = data["email"], let password = data["password"] {
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
                self.signIn()
            })
//        }
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
    
    // MARK: - Other
    
    func signIn() {
        
    
        self.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        
//        let navCon = self.navigationController
//        navCon?.dismiss(animated: true, completion: nil)
//        self.dismiss(animated: true, completion: nil)
    }
}
