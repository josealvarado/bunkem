//
//  BKMPrivacySettingsViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 12/3/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit
import FirebaseDatabase

class BKMPrivacySettingsViewController: UIViewController {

    @IBOutlet weak var everyoneButton: UIButton!
    
    var ref: FIRDatabaseReference?

    var privacySetting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ref = FIRDatabase.database().reference()

        everyoneButton.layer.cornerRadius = 15
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ref?.child("users").child(CurrentUser.user.user.uid).observeSingleEvent(of: .value, with: { snapshot in
            if let userInfo = snapshot.value as? Dictionary<String, AnyObject> {
                
                if let privacySetting = userInfo["sharePhoneNumber"] as? Bool {
                    self.privacySetting = privacySetting
                    
                    if privacySetting {
                        self.everyoneButton.backgroundColor = UIColor.green
                    } else {
                        self.everyoneButton.backgroundColor = UIColor.white
                    }
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
    
    @IBAction func everyoneButtonPressed(_ sender: UIButton) {
        if privacySetting {
            self.everyoneButton.backgroundColor = UIColor.white
            privacySetting = false
        } else {
            self.everyoneButton.backgroundColor = UIColor.green
            privacySetting = true
        }
    }

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        CurrentUser.user.sharePhoneNumber = privacySetting
        let userInfo = ["sharePhoneNumber": privacySetting]
        ref?.child("users").child(CurrentUser.user.user.uid).updateChildValues(userInfo as [NSObject : AnyObject])

    }
}
