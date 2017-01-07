//
//  GeneralSettingsTableViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 12/2/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit
import FirebaseDatabase

class GeneralSettingsTableViewController: UITableViewController {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var ref: FIRDatabaseReference?
    
    var keyRows = ["aboutYou", "thingsEnjoy", "placesLived", "placesVisit"]
    
    var keyDict = ["aboutYou": "", "thingsEnjoy": "", "placesLived": "", "placesVisit": ""]


    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
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
                
                var fullName = ""
                print("userInfo \(userInfo)")
                if let firstName = userInfo["firstName"] as? String {
                    fullName = "\(firstName)"
                }
                if let middleName = userInfo["middleName"] as? String {
                    fullName = "\(fullName) \(middleName)"
                }
                if let lastName = userInfo["lastName"] as? String {
                    fullName = "\(fullName) \(lastName)"
                }
                self.fullNameLabel.text = fullName
                
                if let email = userInfo["email"] as? String {
                    self.emailLabel.text = email
                }
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(" \(indexPath.row)")
        
        if indexPath.row == 4 {
            self.performSegue(withIdentifier: "bio", sender: keyRows[indexPath.row - 4])
        } else if indexPath.row == 5 {
            self.performSegue(withIdentifier: "bio", sender: keyRows[indexPath.row - 4])

        } else if indexPath.row == 6 {
            self.performSegue(withIdentifier: "bio", sender: keyRows[indexPath.row - 4])

        } else if indexPath.row == 7 {
            self.performSegue(withIdentifier: "bio", sender: keyRows[indexPath.row - 4])

        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "bio" {
            guard let vc = segue.destination as? BKMChangeBioViewController else { return }
            
            guard let key = sender as? String else { return }
            
            vc.key = key
        }
    }
    

}
