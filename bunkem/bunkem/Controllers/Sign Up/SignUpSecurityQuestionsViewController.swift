//
//  SignUpSecurityQuestionsViewController.swift
//  bunkem
//
//  Created by Jose Alvarado on 11/19/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit

class SignUpSecurityQuestionsViewController: UIViewController {

    var securityQuestionSelected: ((_ question: String) -> Void)!
    var securityQuestions = ["What is your favorite car?", "What was your first pets name?", "What is your dream job?", "What is your favorite color?"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    // MARK: - User Interactions
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func securityQuestionButtonPressed(_ sender: UIButton) {
        let index = sender.tag - 10
        if index >= 0 {
            self.dismiss(animated: true, completion: {
                self.securityQuestionSelected(self.securityQuestions[index])
            })
        }
    }

}
