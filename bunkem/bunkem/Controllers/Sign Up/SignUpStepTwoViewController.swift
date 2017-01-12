//
//  SignUpStepTwoViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 11/19/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit

class SignUpStepTwoViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyPasswordTextField: UITextField!
    @IBOutlet weak var securityQuestionTextField: UITextField!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    var securityQuestion = ""
    
    var data = [String: String]()
    
    let passwordMinimumLength = 7

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let identifier = segue.identifier, identifier == "securityQuestions" {
            if let controller = segue.destination as? SignUpSecurityQuestionsViewController {
                
                controller.securityQuestionSelected = { (securityQuestion) in
                    self.securityQuestion = securityQuestion
                    self.securityQuestionTextField.text = securityQuestion
                    print("\(self.securityQuestion) ")
                }
            }
        } else if let identifier = segue.identifier, identifier == "stepThree" {
            if let controller = segue.destination as? SignUpStepThreeViewController {
                controller.data = self.data as [String : AnyObject]
            }
        }
    }

    // MARK: - User Interactions
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {

        if let username = usernameTextField.text, let password = passwordTextField.text, let verifyPassword = verifyPasswordTextField.text, let answer = answerTextField.text, let phoneNumber = phoneNumberTextField.text, username != "", password != "", verifyPassword != "", answer != "", securityQuestion != "" {

            guard password.characters.count >= passwordMinimumLength else {
                let alertController = UIAlertController(title: "Incorrect Password Length", message: "Password must have at least 7 characters", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            guard password == verifyPassword else {
                let alertController = UIAlertController(title: "Incorrect Passwords", message: "Passwords don't match", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            data["displayName"] = username
            data["username"] = username
            data["password"] = password
            data["securityQuestion"] = securityQuestion
            data["securityQuestionAnswer"] = answer
            data["phoneNumber"] = phoneNumber

            self.performSegue(withIdentifier: "stepThree", sender: nil)
        } else {
            let alertController = UIAlertController(title: "Misisng data", message: "Enter missing information", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - TextField Keyboard
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
