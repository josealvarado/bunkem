//
//  ForgotPasswordViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 11/18/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    @IBAction func sendEmailButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text {
            FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error) in
                
                var message = "Please check your email to reset your password"
                if let error = error {
                    message = error.localizedDescription
                }
                
                let alertController = UIAlertController(title: "Authentication Failed", message: message, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
