//
//  BKMUpdateProfileViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 1/16/17.
//  Copyright © 2017 BunkEm. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SVProgressHUD

class BKMUpdateProfileViewController: UIViewController {

    @IBOutlet weak var aboutYouTextView: UITextView!
    @IBOutlet weak var enjoyTextField: UITextView!
    @IBOutlet weak var livedTextView: UITextView!
    @IBOutlet weak var visitTextView: UITextView!
    
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
                
                CurrentUser.user.update(userJSON: userInfo)
                
                if let aboutYou = userInfo["aboutYou"] as? String {
                    self.aboutYouTextView.text = aboutYou
                }
                
                if let enjoy = userInfo["enjoy"] as? String {
                    self.enjoyTextField.text = enjoy
                }
                
                if let seekInARoommate = userInfo["seekInARoommate"] as? String {
                    self.livedTextView.text = seekInARoommate
                }
                
                if let visit = userInfo["visit"] as? String {
                    self.visitTextView.text = visit
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

    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        SVProgressHUD.show()
        var userInfo:[String:String] = [:]
        
        if let firstName = aboutYouTextView.text {
            userInfo["aboutYou"] = firstName
        }
        if let middleName = enjoyTextField.text {
            userInfo["enjoy"] = middleName
        }
        if let lastName = livedTextView.text {
            userInfo["seekInARoommate"] = lastName
        }
        if let lastName = visitTextView.text {
            userInfo["visit"] = lastName
        }
        
        ref?.child("users").child(CurrentUser.user.user.uid).updateChildValues(userInfo as [NSObject : AnyObject])
        SVProgressHUD.dismiss()
        
        let _ = self.navigationController?.popViewController(animated: true)
//        self.dismiss(animated: true, completion: nil)
    }
}
