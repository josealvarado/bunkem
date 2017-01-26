//
//  BKMPetPreferenceViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 1/25/17.
//  Copyright © 2017 BunkEm. All rights reserved.
//

import UIKit
import FirebaseDatabase

class BKMPetPreferenceViewController: UIViewController {

    @IBOutlet weak var petSwitch: UISwitch!
    @IBOutlet weak var textField: UITextField!
    
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
                
                if let petsAllowd = userInfo["petsAllowd"] as? Bool, petsAllowd {
                    self.petSwitch.setOn(true, animated: false)
                }
    
                if let petType = userInfo["petType"] as? String {
                    self.textField.text = petType
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
        let userInfo = ["petsAllowed": self.petSwitch.isOn,
                        "petType": self.textField.text ?? ""] as [String : Any]
        ref?.child("users").child(CurrentUser.user.user.uid).updateChildValues(userInfo as [NSObject : AnyObject])

    }
}
