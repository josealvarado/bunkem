//
//  User.swift
//  bunkem
//
//  Created by Jose Alvarado on 11/27/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class User: NSObject {
        
    var identifier = ""
    var username = ""
    var email = ""
    var emailVerified = false
    var privateProfile = false
    var lastName = ""
    var firstName = ""
    var linkedFB = false
    var fbId = ""
    var walkthroughCompleted = false
    var status = ""
    var gender = ""
    var phoneNumber = ""
    var image: UIImage? = nil
    var imageFilePath: URL? = nil
    var imageId = ""
    var sharePhoneNumber = false
    
    var cityAndState = ""
    var dateOfBirth = ""
    var securityQuestion = ""
    var securityQuestionAnswer = ""
    var aboutYou = ""
    var enjoy = ""
    var lived = ""
    var visit = ""
    
    var photoURL = ""
    var images = [[String: AnyObject]]()
    
    
    var ref: FIRDatabaseReference?
    var user: FIRUser!

    override init() {
        super.init()
    }
    
    init(userJSON: [String: AnyObject]) {
        super.init()
        update(userJSON: userJSON)
    }
    
    init (snapshot: FIRDataSnapshot) {
        ref = snapshot.ref
        
        _ = snapshot.value as! Dictionary<String, String>
    }
    
    init(userFirebase: FIRUser?) {
        super.init()
        
        guard let user = userFirebase else { return }
        self.user = user
        
        if let email = user.email {
            self.email = email
        }
        
        if let displayName = user.displayName, displayName != "" {
            self.username = displayName
        }
       
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref = FIRDatabase.database().reference()
        ref?.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? [String : AnyObject] {
                self.update(userJSON: value)
            }            
        }) { (error) in
            print(error.localizedDescription)
        }

    }
    
    func update(userJSON: [String: AnyObject]) {
        if let identifier = userJSON["id"] as? String {
            self.identifier = identifier
        }
        
        if let username = userJSON["username"] as? String {
            self.username = username
        }
        
        if let email = userJSON["email"] as? String {
            self.email = email
        }
        
        if let emailVerified = userJSON["emailVerified"] as? Bool {
            self.emailVerified = emailVerified
        }
        
        if let privateProfile = userJSON["private"] as? Bool {
            self.privateProfile = privateProfile
        }
        
        if let lastName = userJSON["lastName"] as? String {
            self.lastName = lastName
        }
        
        if let firstName = userJSON["firstName"] as? String {
            self.firstName = firstName
        }
        
        if let phoneNumber = userJSON["phoneNumber"] as? String {
            self.phoneNumber = phoneNumber
        }
        
        if let linkedFB = userJSON["linkedFB"] as? Bool {
            self.linkedFB = linkedFB
        }
        
        if let walkthroughCompleted = userJSON["walkThrough"] as? Bool {
            self.walkthroughCompleted = walkthroughCompleted
        }
        
        if let status = userJSON["status"] as? String {
            self.status = status
        }
        
        if let fbId = userJSON["fbId"] as? String {
            self.fbId = fbId
        }
        
        if let gender = userJSON["gender"] as? String {
            self.gender = gender
        }
        
        if let imageId = userJSON["imageId"] as? String {
            self.imageId = imageId
        }
        
        if let cityAndState = userJSON["cityAndState"] as? String {
            self.cityAndState = cityAndState
        }
    
        if let dateOfBirth = userJSON["dateOfBirth"] as? String {
            self.dateOfBirth = dateOfBirth
        }
        
        if let securityQuestion = userJSON["securityQuestion"] as? String {
            self.securityQuestion = securityQuestion
        }
        
        if let securityQuestionAnswer = userJSON["securityQuestionAnswer"] as? String {
            self.securityQuestionAnswer = securityQuestionAnswer
        }
        
        if let aboutYou = userJSON["aboutYou"] as? String {
            self.aboutYou = aboutYou
        }
        
        if let enjoy = userJSON["enjoy"] as? String {
            self.enjoy = enjoy
        }
        
        if let lived = userJSON["lived"] as? String {
            self.lived = lived
        }
        
        if let visit = userJSON["visit"] as? String {
            self.visit = visit
        }
        
        if let photoURL = userJSON["photoURL"] as? String {
            self.photoURL = photoURL
        }
        
        if let sharePhoneNumber = userJSON["sharePhoneNumber"] as? Bool {
            self.sharePhoneNumber = sharePhoneNumber
        }
        
        self.images.removeAll()
        if let images = userJSON["images"] as? [String: AnyObject] {
            for (_, dict) in images {
                self.images.append(dict as! [String : AnyObject])
            }
        }
    }
    
    func toJSON(optional: [String: AnyObject]? = nil) -> Data? {
        var data:  [String : Any] = [
            "username": username,
            "email": email,
            "emailVerified": emailVerified,
            "private": privateProfile,
            "lastName": lastName,
            "firstName": firstName,
            "linkedFB": linkedFB,
            "fbId": fbId,
            "walkthroughCompleted": walkthroughCompleted,
            "status": status,
            "gender": gender,
            "phoneNumber": phoneNumber,
            "imageId": imageId,
            ]
        
        if let _ = optional?["createImage"] as? Bool {
            data["createImage"] = true
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            return jsonData
        } catch {
            return nil
        }
    }
    
}
