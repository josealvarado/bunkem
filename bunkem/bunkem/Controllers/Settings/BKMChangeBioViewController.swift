//
//  BKMChangeBioViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 1/5/17.
//  Copyright © 2017 BunkEm. All rights reserved.
//

import UIKit
import FirebaseDatabase

class BKMChangeBioViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var ref: FIRDatabaseReference?

    var key = ""
    
    var keyDict = ["aboutYou": "About You", "thingsEnjoy": "Things you enjoy", "placesLived": "Places you've lived", "placesVisit": "PLaces you want to visit"]

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        ref = FIRDatabase.database().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        print("key \(key)")
        
        self.title = keyDict[key]
        
        print("USER \(CurrentUser.user.user)")

        if key == "aboutYou" {
            textView.text = CurrentUser.user.aboutYou
        } else if key == "thingsEnjoy" {
            textView.text = CurrentUser.user.enjoy
        } else if key == "placesLived" {
            textView.text = CurrentUser.user.lived
        } else if key == "placesVisit" {
            textView.text = CurrentUser.user.visit
        }
    }

    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        var userInfo:[String:String] = [:]
        
        if key == "aboutYou" {
            userInfo["aboutYou"] = textView.text
            CurrentUser.user.aboutYou = textView.text
        } else if key == "thingsEnjoy" {
            userInfo["enjoy"] = textView.text
            CurrentUser.user.enjoy = textView.text
        } else if key == "placesLived" {
            userInfo["lived"] = textView.text
            CurrentUser.user.lived = textView.text
        } else if key == "placesVisit" {
            userInfo["visit"] = textView.text
            CurrentUser.user.visit = textView.text
        }
        
        print("USER \(CurrentUser.user.user)")
        print("userInfo \(userInfo)")
        print("ref \(ref)")
        
        ref?.child("users").child(CurrentUser.user.user.uid).updateChildValues(userInfo as [NSObject : AnyObject])
        
        self.dismiss(animated: true, completion: nil)
    }
}
