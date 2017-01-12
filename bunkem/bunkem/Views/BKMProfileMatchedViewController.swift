//
//  BKMProfileMatchedViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 1/10/17.
//  Copyright © 2017 BunkEm. All rights reserved.
//

import UIKit

class BKMProfileMatchedViewController: UIViewController {

    @IBOutlet weak var matchContainer: UIView!
    @IBOutlet weak var continueContainerView: UIView!
    @IBOutlet weak var messageContainerView: UIView!
    
    var continueAction: (() -> Void)? = nil
    var messageAction: (() -> Void)? = nil
    
    
//    fileprivate var responseCompletion: (( Bool) -> Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        matchContainer.layer.borderWidth = 1.0
        matchContainer.layer.borderColor = UIColor.black.cgColor

        continueContainerView.layer.borderWidth = 1.0
        continueContainerView.layer.borderColor = UIColor.black.cgColor

        messageContainerView.layer.borderWidth = 1.0
        messageContainerView.layer.borderColor = UIColor.black.cgColor
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
    
    // MARK: - User Actions
    
    
    @IBAction func continueSearchingButtonPressed(_ sender: UIButton) {
        continueAction!()
    }

    @IBAction func messageButtonPressed(_ sender: UIButton) {
        messageAction!()
    }
}
