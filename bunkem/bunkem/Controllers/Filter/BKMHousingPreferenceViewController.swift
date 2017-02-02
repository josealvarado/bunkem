//
//  BKMHousingPreferenceViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 1/25/17.
//  Copyright © 2017 BunkEm. All rights reserved.
//

import UIKit
import FirebaseDatabase

class BKMHousingPreferenceViewController: UIViewController {

    @IBOutlet weak var houseView: UIView!
    @IBOutlet weak var duplexView: UIView!
    @IBOutlet weak var apartmentView: UIView!
    @IBOutlet weak var condoView: UIView!
    @IBOutlet weak var otherView: UIView!
    
    var ref: FIRDatabaseReference?
    
    var houseSelected = false
    var duplexSelected = false
    var apartmentSelected = false
    var condoSelected = false
    var otherSelected = false
    
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
                

                if let housingPreferenceString = userInfo["housingPreference"] as? String {
                    let housingPreferenceStringArray = housingPreferenceString.components(separatedBy: ",")
                    
                    print("housingPreferenceString \(housingPreferenceString)")
                    
                    for houseingPreference in housingPreferenceStringArray {
                        
                        if houseingPreference == "house" {
                            self.houseView.backgroundColor = UIColor.green
                            self.houseSelected = true
                        } else if houseingPreference == "duplex" {
                            self.duplexView.backgroundColor = UIColor.green
                            self.duplexSelected = true
                        } else if houseingPreference == "apartment" {
                            self.apartmentView.backgroundColor = UIColor.green
                            self.apartmentSelected = true
                        } else if houseingPreference == "condo" {
                            self.condoView.backgroundColor = UIColor.green
                            self.condoSelected = true
                        } else if houseingPreference == "other" {
                            self.otherView.backgroundColor = UIColor.green
                            self.otherSelected = true
                        }
                        
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
    
    // MARK: - User Interactions

    @IBAction func houseButtonPressed(_ sender: UIButton) {
        if houseSelected {
            houseSelected = false
            houseView.backgroundColor = UIColor.white
        }else {
            houseSelected = true
            houseView.backgroundColor = UIColor.green
        }
    }
    
    @IBAction func duplexButtonPressed(_ sender: UIButton) {
        if duplexSelected {
            duplexSelected = false
            duplexView.backgroundColor = UIColor.white
        }else {
            duplexSelected = true
            duplexView.backgroundColor = UIColor.green
        }
    }
    
    @IBAction func apartmentButtonPressed(_ sender: UIButton) {
        if apartmentSelected {
            apartmentSelected = false
            apartmentView.backgroundColor = UIColor.white
        }else {
            apartmentSelected = true
            apartmentView.backgroundColor = UIColor.green
        }
    }
    
    @IBAction func condoButtonPressed(_ sender: UIButton) {
        if condoSelected {
            condoSelected = false
            condoView.backgroundColor = UIColor.white
        }else {
            condoSelected = true
            condoView.backgroundColor = UIColor.green
        }
    }
    
    @IBAction func otherButtonPressed(_ sender: UIButton) {
        if otherSelected {
            otherSelected = false
            otherView.backgroundColor = UIColor.white
        }else {
            otherSelected = true
            otherView.backgroundColor = UIColor.green
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        var housingPreferences = [String]()
        
        if houseSelected {
            housingPreferences.append("house")
        }
        if duplexSelected {
            housingPreferences.append("duplex")
        }
        if apartmentSelected {
            housingPreferences.append("apartment")
        }
        if condoSelected {
            housingPreferences.append("condo")
        }
        if otherSelected {
            housingPreferences.append("other")
        }
        
        print("housingPreferences \(housingPreferences)")
        
        let stringRepresentation = housingPreferences.joined(separator: ",") // "1-2-3"
        
        print("stringRepresentation \(stringRepresentation)")
        
        let userInfo = ["housingPreference": stringRepresentation]
        ref?.child("users").child(CurrentUser.user.user.uid).updateChildValues(userInfo as [NSObject : AnyObject])
    }
    
}
