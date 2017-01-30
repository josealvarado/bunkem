//
//  BKMBudgetViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 1/29/17.
//  Copyright © 2017 BunkEm. All rights reserved.
//

import UIKit
import FirebaseDatabase

class BKMBudgetViewController: UIViewController {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var budgetLabel: UILabel!
    
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
                
                if let budgetFilter = userInfo["budgetFilter"] as? Float {
                    self.slider.value = Float(budgetFilter)
                    self.budgetLabel.text = "$\(budgetFilter)"
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
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.budgetLabel.text = "$\(sender.value)"
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let userInfo = ["budgetFilter": slider.value]
        ref?.child("users").child(CurrentUser.user.user.uid).updateChildValues(userInfo as [NSObject : AnyObject])
    }

}
