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
    @IBOutlet weak var matchButton: UIButton!
    
    var ref: FIRDatabaseReference?

    var privacySetting = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ref = FIRDatabase.database().reference()

        everyoneButton.layer.cornerRadius = 15
        matchButton.layer.cornerRadius = 15
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ref?.child("users").child(CurrentUser.user.user.uid).observeSingleEvent(of: .value, with: { snapshot in
            if let userInfo = snapshot.value as? Dictionary<String, AnyObject> {
                
                if let privacySetting = userInfo["privacySetting"] as? String {
                    self.privacySetting = privacySetting
                    if privacySetting == "everyone" {
                        self.everyoneButton.backgroundColor = UIColor.green
                        self.matchButton.backgroundColor = UIColor.white
                    } else if privacySetting == "match" {
                        self.everyoneButton.backgroundColor = UIColor.white
                        self.matchButton.backgroundColor = UIColor.green
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
        if privacySetting == "everyone" {
            self.everyoneButton.backgroundColor = UIColor.white
            privacySetting = ""
        } else {
            self.everyoneButton.backgroundColor = UIColor.green
            privacySetting = "everyone"
            self.matchButton.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func matchButtonPressed(_ sender: UIButton) {
        if privacySetting == "match" {
            self.matchButton.backgroundColor = UIColor.white
            privacySetting = ""
        } else {
            self.matchButton.backgroundColor = UIColor.green
            privacySetting = "match"
            self.everyoneButton.backgroundColor = UIColor.white
        }
    }
    

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        guard privacySetting != "" else { return }
        let userInfo = ["privacySetting": privacySetting]  
        ref?.child("users").child(CurrentUser.user.user.uid).updateChildValues(userInfo as [NSObject : AnyObject])

    }
}
