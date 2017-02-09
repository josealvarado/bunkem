//
//  LoginViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 11/18/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rememberSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)

        let defaults = UserDefaults.standard
        if let email = defaults.object(forKey: "email") as? String {
            usernameTextField.text = email
            
            if let password = defaults.object(forKey: "password") as? String {
                
                signInWithEmail(email, password: password)
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        if let email = usernameTextField.text, let password = passwordTextField.text {
            
            signInWithEmail(email, password: password)
        }
        
    }
    

    func signInWithEmail(_ email: String, password: String) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
            if let user = user {
                let defaults = UserDefaults.standard
                
                if self.rememberSwitch.isOn {
                    defaults.set(email, forKey: "email")
                    defaults.set(password, forKey: "password")
                } else {
                    defaults.removeObject(forKey: "email")
                }
                
                defaults.set(user.refreshToken, forKey: "token")
                
                CurrentUser.user = User(userFirebase: user)
                self.dismiss(animated: true, completion: nil)
            } else if let error = error {
                let alertController = UIAlertController(title: "Authentication Failed", message: error.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
