//
//  BKMMessageViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 12/18/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import SVProgressHUD

class BKMMessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var activeUser: User!
    
    var matchedUsers = [[String: AnyObject]]()
    var matchedUserIds = [Int]()
    
    lazy var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    var postRef: FIRDatabaseReference!
    var commentsRef: FIRDatabaseReference!
    var refHandle: FIRDatabaseHandle?

    private lazy var channelRef: FIRDatabaseReference = FIRDatabase.database().reference().child("channels")


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        postRef = ref.child("matches").child(CurrentUser.user.user.uid)
        
        // [START post_value_event_listener]
        refHandle = postRef.observe(FIRDataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            
            for (_, post) in postDict {
                
                if let match = post["match"] as? Bool, match {
                    self.matchedUsers.append(post as! [String : AnyObject])
                    
                    print("post \(post)")
                    
                    if let identifier = post["identifier"] as? String, identifier == self.activeUser.identifier{
                        print("SHOW USER")
                        
                        self.performSegue(withIdentifier: "ShowChannel", sender: post)

                    }
                }
            }
            
            // [START_EXCLUDE]
            self.tableView.reloadData()
            // [END_EXCLUDE]
        })
        // [END post_value_event_listener]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let refHandle = refHandle {
            postRef.removeObserver(withHandle: refHandle)
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ShowChannel" {
            if let chatVc = segue.destination as? BKMDetailMessageViewController, let matchObject = sender as? [String: AnyObject] {
                chatVc.matchObject = matchObject
                
                if let channelId = matchObject["channelId"] as? String {
                    chatVc.senderDisplayName = CurrentUser.user.username
                    chatVc.channelRef = channelRef.child(channelId)
                }
                
                chatVc.callback = { (value) in
                    print("value \(value)")
                    if value == "refresh" {
                        self.refreshTable()
                    }
                }
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return matchedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
     
        // Configure the cell...
        let user = matchedUsers[indexPath.row]
        
        print("user \(user)")
        if let username = user["username"] as? String, let label = cell.viewWithTag(10) as? UILabel {
            label.text = username
        }
        
        if let photoURL = user["photoURL"] as? String, photoURL != "" {
            print("photoURL \(photoURL)")
            
            let storageRef = FIRStorage.storage().reference(forURL: photoURL)
            storageRef.data(withMaxSize: INT64_MAX){ (data, error) in
                guard let imageView = cell.viewWithTag(11) as? UIImageView else { return }
                
                if let error = error {
                    print("Error downloading image data: \(error)")
                    return
                }
                
                print("data \(data)")
                if let photoImage = UIImage.init(data: data!) {
                    print("photoImage \(photoImage)")
                    imageView.image = photoImage
//                    cell.imageView?.image = photoImage
//                    cell.accessoryView = UIImageView(image: photoImage)
                }
            }
        }
        
        return cell
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(" \(indexPath.row)")
        
        let matchObject = matchedUsers[indexPath.row]
        self.performSegue(withIdentifier: "ShowChannel", sender: matchObject)        
    }
    
    func refreshTable() {
        SVProgressHUD.show()
        ref.child("matches").child(CurrentUser.user.user.uid).observeSingleEvent(of: .value, with: { (snapshot) in

            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            self.matchedUsers = [[String: AnyObject]]()
            
            for (_, post) in postDict {
                if let match = post["match"] as? Bool, match {
                    self.matchedUsers.append(post as! [String : AnyObject])
                }
            }
            
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }

}
