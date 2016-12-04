//
//  BKMNotificationSettingsViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 12/3/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit
import FirebaseDatabase

class BKMNotificationSettingsViewController: UIViewController {

    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var emailNotificationsSwitch: UISwitch!
    
    var ref: FIRDatabaseReference?
    
    var notifications = false
    var emailNotifications = false

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
                
                if let notifications = userInfo["notifications"] as? Bool, notifications {
                    self.notifications = true
                    self.notificationsSwitch.setOn(true, animated: false)
                } else {
                    self.notifications = false
                    self.notificationsSwitch.setOn(false, animated: false)
                }
                
                if let emailNotifications = userInfo["emailNotifications"] as? Bool, emailNotifications {
                    self.emailNotifications = true
                    self.emailNotificationsSwitch.setOn(true, animated: false)
                } else {
                    self.emailNotifications = false
                    self.emailNotificationsSwitch.setOn(false, animated: false)
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
        
        let userInfo = ["notifications": notifications,
                        "emailNotifications": emailNotifications]
        ref?.child("users").child(CurrentUser.user.user.uid).updateChildValues(userInfo as [NSObject : AnyObject])
    }
}
