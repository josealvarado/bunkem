//
//  BKMChangePhoneNumberViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 1/15/17.
//  Copyright © 2017 BunkEm. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

class BKMChangePhoneNumberViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextField: UITextField!
    
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
                if let firstName = userInfo["phoneNumber"] as? String {
                    self.phoneNumberTextField.text = firstName
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
    
    // MARK: - User Interactions
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        SVProgressHUD.show()
        var userInfo:[String:String] = [:]
        
        if let firstName = phoneNumberTextField.text {
            userInfo["phoneNumber"] = firstName
        }

        print("userInfo \(userInfo)")
        ref?.child("users").child(CurrentUser.user.user.uid).updateChildValues(userInfo as [NSObject : AnyObject])
        SVProgressHUD.dismiss()
    }

}
