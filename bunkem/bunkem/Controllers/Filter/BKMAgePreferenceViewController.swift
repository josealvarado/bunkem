//
//  BKMAgePreferenceViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 1/25/17.
//  Copyright © 2017 BunkEm. All rights reserved.
//

import UIKit
import FirebaseDatabase

class BKMAgePreferenceViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var pickerView: UIPickerView!
    var ref: FIRDatabaseReference?
    
    var lowerBoundAge = [18, 19, 20, 21]
    var topBoundAge = [32, 33, 34, 35]
    
    var low = 18
    var top = 35
    
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
                
                if let low = userInfo["lowerBoundAge"] as? Int {
                    
                    self.low = low
                    
                    if let index = self.lowerBoundAge.index(of: low) {
                        self.pickerView.selectRow(index, inComponent: 0, animated: true)
                    }
                }
                
                if let top = userInfo["topBoundAge"] as? Int {
                    self.top = top
                    
                    if let index = self.topBoundAge.index(of: top) {
                        self.pickerView.selectRow(index, inComponent: 1, animated: true)
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
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return lowerBoundAge.count
        }
        
        return topBoundAge.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            return "\(lowerBoundAge[row])"
        }

        
        return "\(topBoundAge[row])"
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0 && row < lowerBoundAge.count {
            self.low = self.lowerBoundAge[row]
        }
        
        if row < self.topBoundAge.count {
            self.top = self.topBoundAge[row]
        }
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        let userInfo = ["lowerBoundAge": low, "topBoundAge": top]
        ref?.child("users").child(CurrentUser.user.user.uid).updateChildValues(userInfo as [NSObject : AnyObject])

    }

}
