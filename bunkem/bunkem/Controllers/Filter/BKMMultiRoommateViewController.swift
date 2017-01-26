//
//  BKMMultiRoommateViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 1/25/17.
//  Copyright © 2017 BunkEm. All rights reserved.
//

import UIKit
import FirebaseDatabase

class BKMMultiRoommateViewController: UIViewController {

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
                
                if let multiroommate = userInfo["multiroommate"] as? Int {
                    self.textField.text = "\(multiroommate)"
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
        let roommate = Int(self.textField.text!) ?? 0
        let userInfo = ["multiroommate": roommate]
        ref?.child("users").child(CurrentUser.user.user.uid).updateChildValues(userInfo as [NSObject : AnyObject])

    }
}
