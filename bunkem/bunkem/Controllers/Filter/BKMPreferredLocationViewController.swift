//
//  BKMPreferredLocationViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 2/1/17.
//  Copyright © 2017 BunkEm. All rights reserved.
//

import UIKit
import FirebaseDatabase

class BKMPreferredLocationViewController: UIViewController {

    @IBOutlet weak var cityAndStateTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        ref?.child("users").child(CurrentUser.user.user.uid).observeSingleEvent(of: .value, with: { snapshot in
            if let userInfo = snapshot.value as? Dictionary<String, AnyObject> {
                
                if let preferredCityAndState = userInfo["preferredCityAndState"] as? String {
                    self.cityAndStateTextField.text = preferredCityAndState
                }
                
                if let preferredZipCode = userInfo["preferredZipCode"] as? String {
                    self.zipCodeTextField.text = preferredZipCode
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
        let userInfo = ["preferredCityAndState": cityAndStateTextField.text ?? "",
                        "preferredZipCode": zipCodeTextField.text ?? ""]
        ref?.child("users").child(CurrentUser.user.user.uid).updateChildValues(userInfo as [NSObject : AnyObject])

    }
}
