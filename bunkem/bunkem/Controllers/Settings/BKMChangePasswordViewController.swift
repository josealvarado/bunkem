//
//  BKMChangePasswordViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 12/3/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit
import SVProgressHUD
import FirebaseAuth
import FirebaseDatabase

class BKMChangePasswordViewController: UIViewController {

    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    
    var ref: FIRDatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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

    @IBAction func updateButtonPressed(_ sender: UIButton) {
        
        if let currentPassword = currentPasswordTextField.text, let newPassword = newPasswordTextField.text, let confirmPassword = confirmNewPasswordTextField.text {
            
            guard newPassword.characters.count >= 7 else {
                displayFailedUpdateAlert(message: "New passwords must be at least 7 characters long")
                return
            }
            
            guard newPassword == confirmPassword else {
                displayFailedUpdateAlert(message: "New passwords don't match")
                return
            }

            SVProgressHUD.show()
            let credential = FIREmailPasswordAuthProvider.credential(withEmail: CurrentUser.user.user.email!, password: currentPassword)
            FIRAuth.auth()?.currentUser?.reauthenticate(with: credential) { error in
                if let error = error {
                    SVProgressHUD.dismiss()
                    print("error two updateEmail:  \(error)")
                    self.displayFailedUpdateAlert(message: error.localizedDescription)
                    
                } else {
                    // User re-authenticated.
                    FIRAuth.auth()?.currentUser?.updatePassword(newPassword) { (error) in
                        SVProgressHUD.dismiss()
                        if let error = error {
                            print("error two updateEmail:  \(error)")
                            self.displayFailedUpdateAlert(message: error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    func displayFailedUpdateAlert(message: String? = "Please try again") {
        let alertController = UIAlertController(title: "Authentication Failed", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
