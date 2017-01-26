//
//  BKMDistanceViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 1/25/17.
//  Copyright © 2017 BunkEm. All rights reserved.
//

import UIKit
import FirebaseDatabase

class BKMDistanceViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    var ref: FIRDatabaseReference?
    
    var dataSource = [1, 2, 3, 5, 10, 100, 200]
    var distance = 5

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
                
                if let distance = userInfo["distance"] as? Int {
                    self.distance = distance
                    
                    if let index = self.dataSource.index(of: distance) {
                        self.pickerView.selectRow(index, inComponent: 0, animated: true)
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
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(dataSource[row])"
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if row < self.dataSource.count {
            self.distance = self.dataSource[row]
        }
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let userInfo = ["distance": distance]
        ref?.child("users").child(CurrentUser.user.user.uid).updateChildValues(userInfo as [NSObject : AnyObject])

    }
}
