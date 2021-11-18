//
//  LoginVC.swift
//  ChitChat
//
//  Created by Ravi dwivedi on 02/03/21.
//  Copyright © 2021 Ravi dwivedi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD
class LoginVC: UIViewController , GIDSignInUIDelegate{
    
    @IBOutlet weak var userTxt:UITextField!
    @IBOutlet weak var password:UITextField!
    @IBOutlet weak var resetPasswordBtn:UIButton!
    
    @IBOutlet weak var facebookLoginBtn:FBSDKLoginButton!
    @IBOutlet weak var googleSignBtn:GIDSignInButton!
    
    private let spinner = JGProgressHUD(style: .dark)

    
    
    
    var isLoggedIn = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.topItem?.title = "Login"
      
        facebookLoginBtn.delegate = self
        facebookLoginBtn.readPermissions = ["email","public_profile"]
        GIDSignIn.sharedInstance()?.uiDelegate = self



    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: false)

    }
    
    @IBAction func loginFacebook(_ sender: Any) {
        
        
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier:"ResetPasswordVC") as? ResetPasswordVC else { return }
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func registerUser(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier:"RegisterVC") as? RegisterVC else { return }
        navigationController?.pushViewController(vc, animated: true)

    }
    
    
    @IBAction func login(_ sender: Any) {
        
        guard let email = userTxt.text , let password = password.text, !email.isEmpty, !password.isEmpty, password.count>=6 else {
            self.showAlert(title:"Alert", message:"Please enter all the fields")
            return
        }
        
        spinner.show(in: view)
        Auth.auth().signIn(withEmail: email, password: password) {[weak self] (userData, error) in
            guard let strongSelf = self else {return}
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            if let error = error {
                debugPrint(error.localizedDescription)
                strongSelf.showAlert(title:"Error", message:error.localizedDescription)
                return
            }
            
            
            if let userEmail = userData {
                print("Useremail\(String(describing:userEmail.user.email))")
                DispatchQueue.main.async {
                    strongSelf.navigate()
                }
                
            }
        }
    }
    
    private func navigate(){
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ConversessionVC") as! ConversessionVC
        let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        let tabBar = UITabBarController()
        chatVC.tabBarItem = UITabBarItem(title:"Chats", image: UIImage.init(named:"Chats"), tag: 0)
        profileVC.tabBarItem = UITabBarItem(title:"Profile", image:UIImage.init(named:"Profile"), tag: 1)
        tabBar.setViewControllers([chatVC, profileVC], animated: false)
        
        let nav = UINavigationController(rootViewController: tabBar)
        nav.navigationBar.prefersLargeTitles = true
        self.navigationController?.present(nav, animated: true, completion: nil)
    }

}

extension LoginVC: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        guard let token = result?.token?.tokenString else {
            showAlert(title:"Error", message:error.localizedDescription)
            return
        }
        
        let facebookRequest =  FBSDKGraphRequest.init(graphPath:"me", parameters:["fields":"email,name"], tokenString: token, version: nil, httpMethod:"GET")
        facebookRequest?.start(completionHandler: { _, result, error in
            guard let result = result as? [String: Any],
                error == nil else {
                    print("Failed to make facebook graph request")
                    return
            }
            
            print(result)
            
            guard let firstName = result["first_name"] as? String,
                let lastName = result["last_name"] as? String,
                let email = result["email"] as? String,
                let picture = result["picture"] as? [String: Any],
                let data = picture["data"] as? [String: Any],
                let pictureUrl = data["url"] as? String else {
                    print("Faield to get email and name from fb result")
                    return
            }
            
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
            
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists {
                    let chatUser = ChatAppUser(firstName: firstName,
                                               lastName: lastName,
                                               emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                        if success {
                            
                            guard let url = URL(string: pictureUrl) else {
                                return
                            }
                            
                            print("Downloading data from facebook image")
                            
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _,_ in
                                guard let data = data else {
                                    print("Failed to get data from facebook")
                                    return
                                }
                                
                                print("got data from FB, uploading...")
                                
                                // upload iamge
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
                            }).resume()
                        }
                    })
                }
            })
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
        
            
            Auth.auth().signInAndRetrieveData(with: credential, completion: { [weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                }
                
                guard authResult != nil, error == nil else {
                    if let error = error {
                        print("Facebook credential login failed, MFA may be needed - \(error)")
                    }
                    return
                }
                
                print("Successfully logged user in")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
        
        
        let credentails = FacebookAuthProvider.credential(withAccessToken: token)
        Auth.auth().signInAndRetrieveData(with: credentails) {[weak self] (result, error) in
            guard let strongSelf = self else {return}
            
            if let err = error{
                strongSelf.showAlert(title:"Error", message:err.localizedDescription)
                return
            }
            
            if let userData = result{
                print("Success and email ID is ....\(String(describing: userData.user.email))")
                strongSelf.navigate()
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        //Do Nothing for now
    }
    
    
}
