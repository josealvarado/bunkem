//
//  BKMChangeEmailViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 12/3/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class BKMChangeEmailViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let oldEmail = CurrentUser.user.user.email {
            emailTextField.text = oldEmail
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        if let email = emailTextField.text, let oldEmail = CurrentUser.user.user.email, email != oldEmail {
            
            FIRAuth.auth()?.currentUser?.updateEmail(email, completion: { (error) in
                if let error = error {
                    print("error one updateEmail:  \(error)")
                    
                    var passwordTextField: UITextField? = nil
                    
                    let alert = UIAlertController(title: "Authentication required when updating email", message: "For security purposes please enter your password", preferredStyle: .alert)
                    alert.addTextField { (textField) in
                        textField.placeholder = "Password"
                        passwordTextField = textField
                    }
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{ (UIAlertAction)in
                        
                        SVProgressHUD.show()
                        let password = passwordTextField?.text ?? ""
                        let credential = FIREmailPasswordAuthProvider.credential(withEmail: oldEmail, password: password)
                        FIRAuth.auth()?.currentUser?.reauthenticate(with: credential) { error in
                            if let error = error {
                                SVProgressHUD.dismiss()
                                print("error two updateEmail:  \(error)")
                                self.displayFailedUpdateAlert(message: error.localizedDescription)
                                
                                FIRAuth.auth()?.sendPasswordReset(withEmail: CurrentUser.user.email, completion: { (error) in
                                    if let error = error {
                                        print("error \(error)")
                                    }
                                })
                            } else {
                                // User re-authenticated.
                                FIRAuth.auth()?.currentUser?.updateEmail(oldEmail, completion: { (error) in
                                    SVProgressHUD.dismiss()
                                    if let error = error {
                                        print("error three updateEmail:  \(error)")
                                        self.displayFailedUpdateAlert(message: error.localizedDescription)
                                        
                                        FIRAuth.auth()?.sendPasswordReset(withEmail: oldEmail, completion: { (error) in
                                            if let error = error {
                                                print("error \(error)")
                                            }
                                        })
                                    } else {
                                        CurrentUser.user.email = email
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                })
                            }
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    CurrentUser.user.email = email
                    self.dismiss(animated: true, completion: nil)
                }
            })
            
        }
    }
    
    func displayFailedUpdateAlert(message: String? = "Please try again") {
        let alertController = UIAlertController(title: "Authentication Failed", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
