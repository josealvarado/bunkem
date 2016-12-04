//
//  BKMChangeNameViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 12/2/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class BKMChangeNameViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var middleNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    var ref: FIRDatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        ref?.child("users").child(CurrentUser.user.user.uid).observeSingleEvent(of: .value, with: { snapshot in
            if let userInfo = snapshot.value as? Dictionary<String, AnyObject> {
            
                
                print("userInfo \(userInfo)")
                if let firstName = userInfo["firstName"] as? String {
                    self.firstNameTextField.text = firstName
                }
                if let middleName = userInfo["middleName"] as? String {
                    self.middleNameTextField.text = middleName
                }
                if let lastName = userInfo["lastName"] as? String {
                   self.lastNameTextField.text = lastName
                }
            }
        })
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
        var userInfo:[String:String] = [:]
        
        if let firstName = firstNameTextField.text {
            userInfo["firstName"] = firstName
        }
        if let middleName = middleNameTextField.text {
            userInfo["middleName"] = middleName
        }
        if let lastName = lastNameTextField.text {
            userInfo["lastName"] = lastName
        }
        
        print("USER \(CurrentUser.user.user)")
        print("userInfo \(userInfo)")
        print("ref \(ref)")
        ref?.child("users").child(CurrentUser.user.user.uid).updateChildValues(userInfo as [NSObject : AnyObject])
    }
}
