//
//  BKMProfileDetailViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 12/14/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit
import FirebaseStorage

class BKMProfileDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cityAndStateLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var aboutYouTextView: UITextView!
    @IBOutlet weak var thingsYouEnjoyTextView: UITextView!
    @IBOutlet weak var livedTextView: UITextView!
    @IBOutlet weak var visitTextView: UITextView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var displayExtraNavBarButton = false
    
    var activeUser: User!
    
    var images = [[String: AnyObject]]()
    var imageArray = [Int: UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        images = activeUser.images
        images = images.sorted { ($0["order"] as? Int)! < ($1["order"] as? Int)! }
        
        self.collectionView.reloadData()
        
        
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
        livedTextView.text = activeUser.seekInARoommate
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
        
        if activeUser.images.count > 0 {
//            for imageObject in activeUser.images {
//                guard let photoURL = imageObject["photoURL"] as? String else { return }
//                
//                
//            }
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
        
        if self.displayExtraNavBarButton {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.jsq_defaultTypingIndicator(), style: .plain, target: self, action: #selector(BKMDetailMessageViewController.didPressRightBarButtonItem(button:)))
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UICollectionView Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileImage",
                                                      for: indexPath)
        
//        print("indexPath.row \(indexPath.row)")
//        let row = indexPath.row
//        
//        if row < activeUser.images.count {
//            let imageObject = activeUser.images[row]
//            if let photoURL = imageObject["photoURL"] as? String, photoURL != "" {
//                
//                
//                let storageRef = FIRStorage.storage().reference(forURL: photoURL)
//                storageRef.data(withMaxSize: INT64_MAX){ (data, error) in
//                    if let error = error {
//                        print("Error downloading image data: \(error)")
//                        return
//                    }
//                    
//                    if let photoImage = UIImage.init(data: data!) {
//                        let imageView = UIImageView(image: photoImage)
//                        cell.backgroundView = imageView
//                    }
//                }
//            }
//
//        }
        
        cell.backgroundView = nil
        
        let row = indexPath.row
        let imageObject = images[row]
        
        print("row \(row) \(imageObject)")
        if let photoImage = imageArray[row] {
            print("re-use image \(row)")
            let imageView = UIImageView(image: photoImage)
            cell.backgroundView = imageView
            return cell
        }
        
        if let photoURL = imageObject["photoURL"] as? String, photoURL != "" {
            
            let storageRef = FIRStorage.storage().reference(forURL: photoURL)
            storageRef.data(withMaxSize: INT64_MAX){ (data, error) in
                if let error = error {
                    print("Error downloading image data: \(error)")
                    return
                }
                cell.backgroundView = nil
                
                if let photoImage = UIImage.init(data: data!) {
                    let imageView = UIImageView(image: photoImage)
                    cell.backgroundView = imageView
                    print("index \(row) \(photoURL) \(self.imageArray.count)")
                    self.imageArray[row] = photoImage
                }
            }
        }


        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
//        let availableWidth = view.frame.width - paddingSpace
//        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: 330, height: 320)
    }
    
    func didPressRightBarButtonItem(button: UIBarButtonItem)  {
        print("TOP RIGHT")
        

    }

    
}
