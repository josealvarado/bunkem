//
//  BKMMatchingService.swift
//  bunkem
//
//  Created by Jose Alvarado on 1/10/17.
//  Copyright © 2017 BunkEm. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SVProgressHUD

class BKMMatchingService: NSObject {

     class func interested(_ user: User, success:@escaping (_ matchedUser: User) -> Void, failure: @escaping (_ error: String) -> Void ) {
        
        
        
        let ref: FIRDatabaseReference = FIRDatabase.database().reference()
        ref.child("potentialMatch").child(CurrentUser.user.user.uid).child(user.identifier).updateChildValues(["match": true])
        
        
        ref.child("potentialMatch").child(user.identifier).child(CurrentUser.user.user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            guard let match = value?["match"] as? Bool, match else {
                failure("no match")
                return
            }
            
            ref.child("matches").child(CurrentUser.user.user.uid).child(user.identifier).updateChildValues(["match": true, "username": user.username, "identifier": user.identifier])
            
            ref.child("matches").child(user.identifier).child(CurrentUser.user.user.uid).updateChildValues(["match": true, "username": CurrentUser.user.username, "identifier": CurrentUser.user.user.uid])


            success(user)
            
        }) { (error) in
            print(error.localizedDescription)
        }

    }
    
    class func notInterested(_ user: User) {
        
        let ref: FIRDatabaseReference = FIRDatabase.database().reference()
        ref.child("potentialMatch").child(CurrentUser.user.user.uid).child(user.identifier).updateChildValues(["match": false])
    }
    
    class func firstTimeLeft(success:@escaping (_ firstTime: Bool) -> Void) -> Void {
        let ref: FIRDatabaseReference = FIRDatabase.database().reference()
        ref.child("settings").child(CurrentUser.user.user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            if let match = value?["firstTimeLeft"] as? Bool, match  {
                success(false)
            } else {
                ref.child("settings").child(CurrentUser.user.user.uid).updateChildValues(["firstTimeLeft": true])
                success(true)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    class func firstTimeRight(success:@escaping (_ firstTime: Bool) -> Void) -> Void {
        let ref: FIRDatabaseReference = FIRDatabase.database().reference()
        ref.child("settings").child(CurrentUser.user.user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            if let match = value?["firstTimeRight"] as? Bool, match  {
                success(false)
            } else {
                ref.child("settings").child(CurrentUser.user.user.uid).updateChildValues(["firstTimeRight": true])
                success(true)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
