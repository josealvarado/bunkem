//
//  ViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 11/18/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        
        if CurrentUser.user.email == "" {
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
            if let tabViewController = storyboard.instantiateViewController(withIdentifier: "Login") as? UINavigationController {
                
                DispatchQueue.main.async(execute: {
                    self.present(tabViewController, animated: false, completion: nil)
                })
            }
        }
    }

}

