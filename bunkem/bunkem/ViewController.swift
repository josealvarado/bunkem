//
//  ViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 11/18/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit
import ZLSwipeableViewSwift
import UIColor_FlatColors
import Cartography
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class ViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cityAndStateLabel: UILabel!
    
    
    var swipeableView: ZLSwipeableView!
    
    var colors = ["Turquoise", "Green Sea", "Emerald", "Nephritis", "Peter River", "Belize Hole", "Amethyst", "Wisteria", "Wet Asphalt", "Midnight Blue", "Sun Flower", "Orange", "Carrot", "Pumpkin", "Alizarin", "Pomegranate", "Clouds", "Silver", "Concrete", "Asbestos"]
    var colorIndex = 0
    var loadCardsFromXib = false
    
    var ref: FIRDatabaseReference!
    
    var userList = [User]()
    var pastUserList = [User]()
    var userIndex = 0
    var usersLoaded = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.clipsToBounds = true
        swipeableView = ZLSwipeableView()
        view.addSubview(swipeableView)
        swipeableView.didStart = {view, location in
            print("Did start swiping view at location: \(location)")
        }
        swipeableView.swiping = {view, location, translation in
            print("Swiping at view location: \(location) translation: \(translation)")
        }
        swipeableView.didEnd = {view, location in
            print("Did end swiping view at location: \(location)")
        }
        swipeableView.didSwipe = {view, direction, vector in
            print("Did swipe view in direction: \(direction), vector: \(vector)")
            self.userIndex += 1
            self.updateView()
        }
        swipeableView.didCancel = {view in
            print("Did cancel swiping view")
        }
        swipeableView.didTap = {view, location in
            print("Did tap at location \(location)")
            
            guard self.userIndex < self.userList.count else {
                return
            }
            
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "BKMProfileDetailViewController") as? BKMProfileDetailViewController {
                vc.activeUser = self.userList[self.userIndex]
                self.navigationController?.pushViewController(vc, animated: true)
            }

        }
        swipeableView.didDisappear = { view in
            print("Did disappear swiping view")
        }
        
        constrain(swipeableView, view) { view1, view2 in
            view1.left == view2.left+50
            view1.right == view2.right-50
            view1.top == view2.top + 120
            view1.bottom == view2.bottom - 100
        }
        
        ref = FIRDatabase.database().reference()
        
        userList = [User]()
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.loadCardsFromXib = true
            self.userIndex = 0
            self.usersLoaded = 0
            self.swipeableView.reloadInputViews()
            self.swipeableView.discardViews()
//            self.viewDidLayoutSubviews()
//            self.swipeableView.nextView = {
//                return self.nextCardView()
//            }
            
            // Get user value
            guard let allUsers = snapshot.value as? NSDictionary else {
                print("NO USERS FOUND")
                return
            }
            
            print("value \(allUsers)")
            let allKeys = allUsers.allKeys
            for userId in allKeys {
                if let otherUser = allUsers[userId] as? [String: AnyObject] {
                    print("email \(otherUser["email"])")
                    
                    let tempUser = User(userJSON: otherUser)
                    tempUser.identifier = userId as! String
                    
                    if tempUser.identifier != CurrentUser.user.identifier {
                        self.userList.append(tempUser)

                    }
                }
            }
            
            self.updateView()
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubviews")
        swipeableView.nextView = {
            return self.nextCardView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        if CurrentUser.user.email == "" {
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
            if let tabViewController = storyboard.instantiateViewController(withIdentifier: "Login") as? UINavigationController {
                
                DispatchQueue.main.async(execute: {
                    self.present(tabViewController, animated: false, completion: nil)
                })
            }
        } else {
            self.viewDidLayoutSubviews()
        }
    }
    
    // MARK: - Other
    
    func updateView() {
        guard userIndex < userList.count else {
            nameLabel.text = "M"
            cityAndStateLabel.text = ""
            return
        }
        
        let activeUser = userList[userIndex]
        
        nameLabel.text = activeUser.username
        
        cityAndStateLabel.text = "\(activeUser.cityAndState)"
    }

    // MARK: - Actions
    
    func reloadButtonAction() {
        let alertController = UIAlertController(title: nil, message: "Load Cards:", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let ProgrammaticallyAction = UIAlertAction(title: "Programmatically", style: .default) { (action) in
            self.loadCardsFromXib = false
            self.colorIndex = 0
            self.swipeableView.discardViews()
            self.swipeableView.loadViews()
        }
        alertController.addAction(ProgrammaticallyAction)
        
        let XibAction = UIAlertAction(title: "From Xib", style: .default) { (action) in
            self.loadCardsFromXib = true
            self.colorIndex = 0
            self.swipeableView.discardViews()
            self.swipeableView.loadViews()
        }
        alertController.addAction(XibAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: ()
    func nextCardView() -> UIView? {
        print("nextCardView \(self.userIndex) \(loadCardsFromXib)")
        if colorIndex >= colors.count {
            colorIndex = 0
        }
        
        let cardView = CardView(frame: swipeableView.bounds)
//        cardView.backgroundColor = colorForName(colors[colorIndex])
        colorIndex += 1
        
        if loadCardsFromXib {
            let contentView = Bundle.main.loadNibNamed("CardContentView", owner: self, options: nil)?.first! as! UIView
            contentView.translatesAutoresizingMaskIntoConstraints = false
//            contentView.backgroundColor = cardView.backgroundColor
            
            if let label = contentView.viewWithTag(100) as? UILabel {
                label.text = colors[colorIndex]
                label.textColor = UIColor.green
                
                print("USER INDEX \(self.usersLoaded) userList.count \(userList.count)")
                
                if self.usersLoaded < userList.count {
                    if let textView = contentView.viewWithTag(50) as? UITextView {
                        textView.text = ""
                    }
                    
                    let loadedUser = userList[self.usersLoaded]
                    
                    label.text = loadedUser.lastName
                    
                    // Get a reference to the storage service, using the default Firebase App
                    let storage = FIRStorage.storage()
                    
                    // This is equivalent to creating the full reference
                    let storageRef = storage.reference(forURL: "gs://bunkem-4799f.appspot.com")
                    
                    let downloadFilePath = "\(loadedUser.identifier)-pimg-\(0)"
                    let filePath = "images/profile/\(downloadFilePath)"
                    let spaceRef = storageRef.child(filePath)
                    // d4jEUAaToFNmRvFnTXjXf4fDK612/
                    // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                    
                    if let imageFilePath = SFDImageUploadDownloadService.initiateDownloadImage(fileName: filePath, downloadedFilePath: downloadFilePath) {
                        let downloadedImage = UIImage(contentsOfFile: imageFilePath.path)

                        if let imageView = contentView.viewWithTag(200) as? UIImageView {
                            imageView.image = downloadedImage
                        }
                    } else {
                        spaceRef.data(withMaxSize: 1024 * 1024 * 1024) { (data, error) -> Void in
                            if (error != nil) {
                                // Uh-oh, an error occurred!
                                
                                print("error \(error)")
                                
                                if let loadingLabel = contentView.viewWithTag(60) as? UILabel {
                                    loadingLabel.text = "No image found"
                                }
                            } else {
                                
                                
                                
                                print("Successful download \(filePath)")
                                // Data for "images/island.jpg" is returned
                                
                                if let data = data, let downloadedImage = UIImage(data: data) {
                                    
                                    let _ = SFDImageUploadDownloadService.saveImageLocally(image: downloadedImage, fileName: filePath)

                                    if let imageView = contentView.viewWithTag(200) as? UIImageView {
                                        imageView.image = downloadedImage
                                    }
                                }
                            }
                        }
                    }
                    
                    
                } else {
                    if let loadingLabel = contentView.viewWithTag(60) as? UILabel {
                        loadingLabel.text = ""
                    }
                }
                
                contentView.addSubview(label)

            }

            cardView.addSubview(contentView)

            // This is important:
            // https://github.com/zhxnlai/ZLSwipeableView/issues/9
            /*// Alternative:
             let metrics = ["width":cardView.bounds.width, "height": cardView.bounds.height]
             let views = ["contentView": contentView, "cardView": cardView]
             cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView(width)]", options: .AlignAllLeft, metrics: metrics, views: views))
             cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView(height)]", options: .AlignAllLeft, metrics: metrics, views: views))
             */
            constrain(contentView, cardView) { view1, view2 in
                view1.left == view2.left
                view1.top == view2.top
                view1.width == cardView.bounds.width
                view1.height == cardView.bounds.height
            }
        }
        
        usersLoaded += 1
        
        return cardView
    }
    
    func colorForName(_ name: String) -> UIColor {
        let sanitizedName = name.replacingOccurrences(of: " ", with: "")
        let selector = "flat\(sanitizedName)Color"
        return UIColor.perform(Selector(selector)).takeUnretainedValue() as! UIColor
    }
    
    @IBAction func filterButtonPressed(_ sender: UIBarButtonItem) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "BKMFilterTableViewController") as? BKMFilterTableViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func notInterestedButtonPressed(_ sender: UIButton) {
        swipeableView.swipeTopView(inDirection: .Left)
    }
    
    @IBAction func messageButtonPressed(_ sender: UIButton) {
        guard self.userIndex < self.userList.count else {
            return
        }
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "BKMMessageViewController") as? BKMMessageViewController {
            vc.activeUser = self.userList[self.userIndex]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func interestedButtonPressed(_ sender: UIButton) {
        swipeableView.swipeTopView(inDirection: .Right)
    }
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        
        if segue.identifier == "detailProfile" {
            if let vc = segue.destination as? BKMProfileDetailViewController {
                vc.activeUser = userList[userIndex]
            }
        }
     }
 
}

