//
//  SignUpStepOneViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 11/19/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit

class SignUpStepOneViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    var datePicker: UIDatePicker!
    var date = ""
    
    var data = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SignUpStepOneViewController.donePicker))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.backgroundColor = .white
        dateOfBirthTextField.inputView = datePicker
        dateOfBirthTextField.inputAccessoryView = toolBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func donePicker()
    {
        print("selected \(datePicker.date)")
        dateOfBirthTextField.resignFirstResponder()
        
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: datePicker.date)
        
        if let year =  components.year, let month = components.month, let day = components.day {
            date =  "\(year)/\(month)/\(day)"
            dateOfBirthTextField.text = date
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "stepTwo" {
            if let controller = segue.destination as? SignUpStepTwoViewController {
                controller.data = self.data
            }
        }
    }
    
    // MARK: - User Interactions
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        if let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let dateOfBirth = dateOfBirthTextField.text, let email = emailTextField.text, firstName != "", lastName != "", dateOfBirth != "", email != "" {
            
            data["firstName"] = firstName
            data["lastName"] = lastName
            data["dateOfBirth"] = dateOfBirth
            data["email"] = email
        
            self.performSegue(withIdentifier: "stepTwo", sender: nil)
        } else {
            let alertController = UIAlertController(title: "Misisng data", message: "Enter missing information", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
