//
//  User.swift
//  bunkem
//
//  Created by Jose Alvarado on 11/27/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit
import FirebaseAuth

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
    
    override init() {
        super.init()
    }
    
    init(userJSON: [String: AnyObject]) {
        super.init()
        update(userJSON: userJSON)
    }
    
    init(userFirebase: FIRUser?) {
        super.init()
        
        guard let user = userFirebase else { return }
        
        if let email = user.email {
            self.email = email
        }
        
        if let displayName = user.displayName {
            self.username = displayName
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
