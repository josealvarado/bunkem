//
//  BKMProfileDetailViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 12/14/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit
import FirebaseStorage

class BKMProfileDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cityAndStateLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var aboutYouTextView: UITextView!
    @IBOutlet weak var thingsYouEnjoyTextView: UITextView!
    @IBOutlet weak var livedTextView: UITextView!
    @IBOutlet weak var visitTextView: UITextView!
    
    var activeUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        nameLabel.text = activeUser.username
        cityAndStateLabel.text = "\(activeUser.cityAndState)"
        aboutYouTextView.text = activeUser.aboutYou
        thingsYouEnjoyTextView.text = activeUser.enjoy
        livedTextView.text = activeUser.lived
        visitTextView.text = activeUser.visit
        
        if activeUser.photoURL != "" {
            let storageRef = FIRStorage.storage().reference(forURL: activeUser.photoURL)
            storageRef.data(withMaxSize: INT64_MAX){ (data, error) in
                if let error = error {
                    print("Error downloading image data: \(error)")
                    return
                }
                
                if let photoImage = UIImage.init(data: data!) {
                    self.profileImageView.image = photoImage
                }
            }
        }
        
        
        
//        // Get a reference to the storage service, using the default Firebase App
//        let storage = FIRStorage.storage()
//        
//        // This is equivalent to creating the full reference
//        let storageRef = storage.reference(forURL: "gs://bunkem-4799f.appspot.com")
//        
//        let downloadFilePath = "\(activeUser.identifier)-pimg-\(0)"
//        let filePath = "images/profile/\(activeUser.identifier)/pimg-\(0)"
//        let spaceRef = storageRef.child(filePath)
//        // d4jEUAaToFNmRvFnTXjXf4fDK612/
//        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
//        
//        
//        if let imageFilePath = SFDImageUploadDownloadService.initiateDownloadImage(fileName: downloadFilePath) {
//            let downloadedImage = UIImage(contentsOfFile: imageFilePath.path)
//            profileImageView.image = downloadedImage
//        } else {
//            spaceRef.data(withMaxSize: 1024 * 1024 * 1024) { (data, error) -> Void in
//                if (error != nil) {
//                    // Uh-oh, an error occurred!
//                    
//                    print("error \(error)")
//                } else {
//                    print("Successful download \(filePath)")
//                    // Data for "images/island.jpg" is returned
//                    
//                    if let data = data, let downloadedImage = UIImage(data: data) {
//                        
//                        let _ = SFDImageUploadDownloadService.saveImageLocally(image: downloadedImage, fileName: downloadFilePath)
//                        self.profileImageView.image = downloadedImage
//                    }
//                }
//            }
//        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

   }
