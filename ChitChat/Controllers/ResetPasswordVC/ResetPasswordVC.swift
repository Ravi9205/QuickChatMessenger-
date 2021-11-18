//
//  ResetPasswordVC.swift
//  ChitChat
//
//  Created by Ravi dwivedi on 04/03/21.
//  Copyright © 2021 Ravi dwivedi. All rights reserved.
//

import UIKit
import FirebaseAuth

class ResetPasswordVC: UIViewController {
    
    @IBOutlet weak var userEmailTxt: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Reset Password"
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        guard let email = userEmailTxt.text, !email.isEmpty else {
            self.showAlert(title:"Reset Password", message:"Please enter your email before reset pasword")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail:email) {[weak self] (error) in
            guard let strongSelf = self else {return}
            
            if let err = error {
                strongSelf.showAlert(title:"Error", message:err.localizedDescription)
            }else{
                let alert = UIAlertController(title:"Success!", message:"Password reset link has been sent to your email id please check", preferredStyle: .alert)
                let action = UIAlertAction(title:"OK", style: .default, handler: { (action) in
                    
                    strongSelf.navigationController?.popViewController(animated: true)
                    
                })
                alert.addAction(action)
                strongSelf.present(alert, animated: true, completion: nil)
                
            }
        }
        
        
    }
}
