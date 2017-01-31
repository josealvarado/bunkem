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
import FirebaseMessaging
import GoogleMobileAds


class ViewController: UIViewController, GADInterstitialDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cityAndStateLabel: UILabel!
    
    var interstitial: GADInterstitial!

    var swipeableView: ZLSwipeableView!
    
//    var colors = ["Turquoise", "Green Sea", "Emerald", "Nephritis", "Peter River", "Belize Hole", "Amethyst", "Wisteria", "Wet Asphalt", "Midnight Blue", "Sun Flower", "Orange", "Carrot", "Pumpkin", "Alizarin", "Pomegranate", "Clouds", "Silver", "Concrete", "Asbestos"]
//    var colorIndex = 0
    var loadCardsFromXib = false
    
    var ref: FIRDatabaseReference!
    
    var userList = [User]()
    var pastUserList = [User]()
    var userIndex = 0
    var usersLoaded = 0
    
    override func viewDidLoad() {
        interstitial = createAndLoadInterstitial()
        
        let defaults = UserDefaults.standard
        let today = NSDate()
        if let matchesTodayDate = defaults.value(forKey: "matchesTodayDate") as? NSDate {
            print("matchesTodayDate \(matchesTodayDate)")
            
            let calendar = NSCalendar.current
            let matchesDay = calendar.component(Calendar.Component.day, from: matchesTodayDate as Date)
            let todaysDay = calendar.component(Calendar.Component.day, from: today as Date)

            if let matchesToday = defaults.value(forKey: "matchesToday") as? Int {
                if matchesToday >= Matching.maximumMatchesPerDay && matchesDay == todaysDay {
                    self.swipeableView.isUserInteractionEnabled = false
                } else {
                    if self.swipeableView != nil {
                        self.swipeableView.isUserInteractionEnabled = true
                    }
                    defaults.setValue(0, forKey: "matchesToday")
                    defaults.setValue(NSDate(), forKey: "matchesTodayDate")
                }
            }
            
        } else {
            if self.swipeableView != nil {
                self.swipeableView.isUserInteractionEnabled = true
            }
            defaults.setValue(0, forKey: "matchesToday")
            defaults.setValue(NSDate(), forKey: "matchesTodayDate")
        }
        
        print("viewDidLoadviewDidLoadviewDidLoadviewDidLoad")
        
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
            
            
            if let matchesToday = defaults.value(forKey: "matchesToday") as? Int {
                defaults.setValue(matchesToday + 1, forKey: "matchesToday")

                if matchesToday + 1 == Matching.maximumMatchesPerDay {
                    self.swipeableView.isUserInteractionEnabled = false
                    self.displayFailedUpdateAlert(title: "You've reached the maximum number of matches for the day. Please come again tomorrow")
                } else {
                    
                    if matchesToday > 2 && matchesToday + 1 % Matching.addsAfterMatches == 0 {
                        if self.interstitial.isReady {
                            self.interstitial.present(fromRootViewController: self)
                        } else {
                            print("Ad wasn't ready")
                        }
                    }
                }
            }
            else {
                defaults.setValue(1, forKey: "matchesToday")
                defaults.setValue(NSDate(), forKey: "matchesTodayDate")
            }
            
            guard self.userIndex < self.userList.count else { return }
            
            let activeUser = self.userList[self.userIndex]

            self.userIndex += 1
            self.updateView()

            if direction == .Right {
                print("RIGHT")

                BKMMatchingService.firstTimeRight(success: { (firstTimeRight) in
                    if firstTimeRight {
                        print("firstTimeRight")
                        self.firstTimeRight()
                    } else {
                        
                        BKMMatchingService.interested(activeUser, success: { (activeUser) in
                            print("POP matched")
                            
                            self.profileMatched(matchedProfile: activeUser)
                        }, failure: { (failureString) in
                        })
                        
                    }
                })
            } else if direction == .Left {
                print("LEFT")

                BKMMatchingService.firstTimeLeft(success: { (firstTimeLeft) in
                    if firstTimeLeft {
                        print("firstTimeLeft")
                        self.firstTimeLeft()
                    }
                    BKMMatchingService.notInterested(activeUser)
                })
            }
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
        
        
        CurrentUser.user.reLoaduser {
            CurrentUser.user.loadPotentialMatches {
                print("CurrentUser \(CurrentUser.user)")
                self.ref = FIRDatabase.database().reference()
                self.userList = [User]()
                self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                    
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
                        guard !CurrentUser.user.potentialMatches.contains(userId as! String) else { continue }
                        if let otherUser = allUsers[userId] as? [String: AnyObject] {
                            print("email \(otherUser["email"])")
                            
                            let tempUser = User(userJSON: otherUser)
                            tempUser.identifier = userId as! String
                            
                            guard tempUser.identifier != CurrentUser.user.identifier else { continue }
                            
                            print("tempUser \(tempUser)")
                            
                            // CITY/STATE FILTER
                            print("CU \(CurrentUser.user.cityAndState) TU \(tempUser.cityAndState)")
                            if tempUser.state == CurrentUser.user.state || tempUser.city == CurrentUser.user.state {
                                self.userList.append(tempUser)
                            }
                        }
                    }
                    
                    print("NUMBER OF USERS \(self.userList.count)")
                    
                    self.updateView()
                    // ...
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }
        
        
    }
    
//    fileprivate func createAndLoadInterstitial() {
//        interstitial = GADInterstitial(adUnitID: "ca-app-pub-1894426762965055/7602399921")
//        let request = GADRequest()
//        // Request test ads on devices you specify. Your test device ID is printed to the console when
//        // an ad request is made.
//        request.testDevices = [ kGADSimulatorID, "2077ef9a63d2b398840261c8221a0c9b" ]
//        interstitial.load(request)
//    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-1894426762965055/7602399921")
        interstitial.delegate = self
        let request = GADRequest()
        //TODO: Remove this before submitting to apple
        request.testDevices = [ kGADSimulatorID, "2077ef9a63d2b398840261c8221a0c9b" ]
        interstitial.load(request)
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
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
            nameLabel.text = ""
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
//            self.colorIndex = 0
            self.swipeableView.discardViews()
            self.swipeableView.loadViews()
        }
        alertController.addAction(ProgrammaticallyAction)
        
        let XibAction = UIAlertAction(title: "From Xib", style: .default) { (action) in
            self.loadCardsFromXib = true
//            self.colorIndex = 0
            self.swipeableView.discardViews()
            self.swipeableView.loadViews()
        }
        alertController.addAction(XibAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: ()
    func nextCardView() -> UIView? {
        print("nextCardView \(self.userIndex) \(loadCardsFromXib)")
//        if colorIndex + 1 > colors.count {
//            colorIndex = 0
//        }
        
        let cardView = CardView(frame: swipeableView.bounds)
//        cardView.backgroundColor = colorForName(colors[colorIndex])
//        colorIndex += 1
        
        if loadCardsFromXib {
            let contentView = Bundle.main.loadNibNamed("CardContentView", owner: self, options: nil)?.first! as! UIView
            contentView.translatesAutoresizingMaskIntoConstraints = false
//            contentView.backgroundColor = cardView.backgroundColor
            
            if let label = contentView.viewWithTag(100) as? UILabel {
                label.text = ""
                label.textColor = UIColor.green
                
                print("USER INDEX \(self.usersLoaded) userList.count \(userList.count)")
                
                if self.usersLoaded < userList.count {
                    if let textView = contentView.viewWithTag(50) as? UITextView {
                        textView.text = ""
                    }
                    
                    let loadedUser = userList[self.usersLoaded]
                    
                    label.text = loadedUser.lastName
                    
                    if loadedUser.photoURL != "" {
                        let storageRef = FIRStorage.storage().reference(forURL: loadedUser.photoURL)
                        storageRef.data(withMaxSize: INT64_MAX){ (data, error) in
                            if let error = error {
                                print("Error downloading image data: \(error)")
                                return
                            }
                            
                            if let photoImage = UIImage.init(data: data!) {
                                if let imageView = contentView.viewWithTag(200) as? UIImageView {
                                    imageView.image = photoImage
                                }
                            }
                        }
                    }
                } else {
                    if let loadingLabel = contentView.viewWithTag(60) as? UILabel {
                        loadingLabel.text = "You've run out ot people to match with today. Please come back tomorrow!!"
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
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "BKMMessageViewController") as? BKMMessageViewController {
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
    
    //MARK: - Matching functions
 
    func profileMatched(matchedProfile: User) -> Void {
        
        let vc = BKMProfileMatchedViewController()
        
        vc.continueAction = { ()
            print("continueAction")
            vc.dismiss(animated: true, completion: nil)
        }
        
        vc.messageAction = {
            print("messageAction")
            vc.dismiss(animated: true, completion: nil)

            print("userIndex \(self.userIndex)")
            
            guard self.userIndex - 1 < self.userList.count && self.userIndex - 1 >= 0 else {
                return
            }
            
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "BKMMessageViewController") as? BKMMessageViewController {
//                vc.activeUser = self.userList[self.userIndex - 1]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false) { 
            print("ere")
        }
    }
    
    func firstTimeRight() -> Void {
        let alertController = UIAlertController(title: "Interested", message: "Dragging a picture to the right indicates you want \"name\" to be saved to \"people of interest\"", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
            self.registerForPushNotifications()
        }))

//        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (alertAction) in
//            print("undo swipe right")
//        }))
//        alertController.addAction(UIAlertAction(title: "Interested", style: UIAlertActionStyle.default, handler: { (alertAction) in
//            print("swip right")
//        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func firstTimeLeft() -> Void {
        let alertController = UIAlertController(title: "Not Interested", message: "Dragging a picture to the left indicates you're not interested", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
            self.registerForPushNotifications()
        }))

        
//        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (alertAction) in
//            print("undo swipe left")
//        }))
//        alertController.addAction(UIAlertAction(title: "Not Interested", style: UIAlertActionStyle.default, handler: { (alertAction) in
//            print("swip left")
//        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Push Notifications
    
    func registerForPushNotifications() -> Void {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.registerForPushNotifications(application: UIApplication.shared)
    }
    
    func displayFailedUpdateAlert(title: String, message: String? = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

