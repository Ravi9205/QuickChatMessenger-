//
//  AppDelegate.swift
//  ChitChat
//
//  Created by Ravi dwivedi on 02/03/21.
//  Copyright © 2021 Ravi dwivedi. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance()?.clientID =  FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        currentUserStatus()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    private func currentUserStatus(){
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        
        if Auth.auth().currentUser == nil {
            let vc = mainStoryBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            // vc.title = "Login"
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.prefersLargeTitles = true
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = nav
            self.window?.makeKeyAndVisible()
            
        }
        else {
            let chatVC = mainStoryBoard.instantiateViewController(withIdentifier: "ConversessionVC") as! ConversessionVC
            let profileVC = mainStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            // vc.title = "Chats"
            let tabBar = UITabBarController()
            chatVC.tabBarItem = UITabBarItem(title:"Chats", image: UIImage.init(named:"Chats"), tag: 0)
            profileVC.tabBarItem = UITabBarItem(title:"Profile", image:UIImage.init(named:"Profile"), tag: 1)
            tabBar.setViewControllers([chatVC, profileVC], animated: false)
            
            let nav = UINavigationController(rootViewController: tabBar)
            nav.navigationBar.prefersLargeTitles = true
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = nav
            self.window?.makeKeyAndVisible()
        }
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
        ) -> Bool {
        
        //return true
        
        return GIDSignIn.sharedInstance()?.handle(url, sourceApplication:"", annotation: nil) ??  false
    }
    
    
}

// MARK: - GIDSignInDelegate

extension  AppDelegate: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            if let error = error {
                print("Failed to sign in with Google: \(error)")
            }
            return
        }
        
        guard let user = user else {
            return
        }
        
        print("Did sign in with Google: \(user)")
        
        guard let email = user.profile.email,
            let firstName = user.profile.givenName,
            let lastName = user.profile.familyName else {
                return
        }
        
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
        
        //        DatabaseManager.shared.validateNewUser(with: email, completion: { exists in
        //            if !exists {
        //                // insert to database
        //                let chatUser = ChatAppUser(userName: firstName+lastName,
        //                                           emailAddress: email)
        //
        //                DatabaseManager.shared.createNewUser(with: <#T##ChatAppUser#>)
        //
        //                DatabaseManager.shared.createNewUser(with: chatUser, completion: { success in
        //                    if success {
        //                        // upload image
        //
        //                        if user.profile.hasImage {
        //                            guard let url = user.profile.imageURL(withDimension: 200) else {
        //                                return
        //                            }
        //
        //                            URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
        //                                guard let data = data else {
        //                                    return
        //                                }
        //
        //                                let filename = chatUser.profilePictureFileName
        //                                StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
        //                                    switch result {
        //                                    case .success(let downloadUrl):
        //                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
        //                                        print(downloadUrl)
        //                                    case .failure(let error):
        //                                        print("Storage maanger error: \(error)")
        //                                    }
        //                                })
        //                            }).resume()
        //                        }
        //
        //
        //                    }
        //                })
        //            }
        //        })
        
      
        
        DatabaseManager.shared.userExists(with:email) { (exits) in
           
            if !exits{
                guard let authentication = user.authentication else {
                    print("Missing auth object off of google user")
                    return
                }
                let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                               accessToken: authentication.accessToken)
                
                Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                    guard authResult != nil, error == nil else {
                        print("failed to log in with google credential")
                        return
                    }
                    
                    print("Successfully signed in with Google cred.")
                    self.currentUserStatus()
                    //  NotificationCenter.default.post(name: .didLogInNotification, object: nil)
                }
            }else {
                print("Email Id is already exits Please logged with dirrent user Id")
            }
            
        }
        
        
        
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google user was disconnected")
    }
}
