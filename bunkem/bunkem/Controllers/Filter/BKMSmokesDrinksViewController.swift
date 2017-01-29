//
//  BKMSmokesDrinksViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 1/25/17.
//  Copyright © 2017 BunkEm. All rights reserved.
//

import UIKit
import FirebaseDatabase

class BKMSmokesDrinksViewController: UIViewController {

    @IBOutlet weak var drinksSwitch: UISwitch!
    @IBOutlet weak var smokesSwitch: UISwitch!
    
    var ref: FIRDatabaseReference?

    var drinksFilter = false
    var smokesFilter = false
    
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
                
                if let drinksFilter = userInfo["drinksFilter"] as? Bool {
                    self.drinksFilter = drinksFilter
                    
                    if drinksFilter {
                        self.drinksSwitch.setOn(true, animated: false)
                    } else {
                        self.drinksSwitch.setOn(false, animated: false)
                    }
                }
                
                if let smokesFilter = userInfo["smokesFilter"] as? Bool {
                    self.smokesFilter = smokesFilter
                    
                    if smokesFilter {
                        self.smokesSwitch.setOn(true, animated: false)
                    } else {
                        self.smokesSwitch.setOn(false, animated: false)
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
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        let userInfo = ["drinksFilter": drinksSwitch.isOn,
                        "smokesFilter": smokesSwitch.isOn]
        ref?.child("users").child(CurrentUser.user.user.uid).updateChildValues(userInfo as [NSObject : AnyObject])

    }

}
