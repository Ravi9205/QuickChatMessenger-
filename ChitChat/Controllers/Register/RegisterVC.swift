//
//  RegisterVC.swift
//  ChitChat
//
//  Created by Ravi dwivedi on 02/03/21.
//  Copyright © 2021 Ravi dwivedi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase



class RegisterVC: UIViewController {
    
    @IBOutlet weak var userNameTxt:UITextField!
    @IBOutlet weak var emailTxt:UITextField!
    @IBOutlet weak var passwordTxt:UITextField!
    @IBOutlet weak var confirmPossword:UITextField!
    @IBOutlet weak var imgView:UIImageView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //self.navigationController?.navigationBar.topItem?.title = ""
        
        self.title = "Registration"

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func registerNewUser()->(){
        
        guard let userName = userNameTxt.text , !userName.isEmpty else {
            self.showAlert(title:"Register", message:"Please enter user name first")
            return
        }
        
        guard let email = emailTxt.text , !email.isEmpty else {
            self.showAlert(title:"Register", message:"Please enter  email id ")
            return
        }
        
        guard let password = passwordTxt.text , !password.isEmpty else {
            self.showAlert(title:"Register", message:" Please enter user password ")
            return
        }
        
        guard let confirmPass = confirmPossword.text , !confirmPass.isEmpty else {
            self.showAlert(title:"Register", message:" Please enter confirm password ")
            return
        }
        
        if (password != confirmPass) {
            self.showAlert(title:"Register", message:"Entered Password and confirm password didn't matched ")
            return
        }
        
        
        
        
        DatabaseManager.shared.userExists(with: email) { [weak self] exits in
            guard let strongSelf = self else {return}
            
            guard !exits else {
                strongSelf.showAlert(title:"Error", message:"Email id alreay exits")
                return
            }
            
            let registerAuth = Auth.auth()
            registerAuth.createUser(withEmail:email, password:password) { (userData, error) in
                if let err = error {
                    debugPrint("Error while creating new user....\(err.localizedDescription)")
                    strongSelf.showAlert(title:"Error", message:err.localizedDescription)
                    
                }
                
                let chatUser = ChatAppUser(firstName:userName, lastName:"", emailAddress:email)
                
                DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                    if success {
                        // upload image
                        guard let image = strongSelf.imgView.image,
                            let data = image.pngData() else {
                                return
                        }
                        let filename = chatUser.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                            switch result {
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case .failure(let error):
                                print("Storage maanger error: \(error)")
                            }
                        })
                    }
                })
                strongSelf.navigationController?.popViewController(animated: false)
                
                
                // if let userEmailId = userData?.user.email {
                //debugPrint("userCreated Successfully and user id is \(String(describing: userEmailId))")
                //
                //}
                
                
            }
        }
        
        
        
        
        
        
        
    }
    
    
    @IBAction func registerNewUserAccount(_ sender: Any) {
        
        registerNewUser()
    }
    
    
    private func resetPassword()->(){
        
        
    }
    
    
    
}
