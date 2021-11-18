//
//  ProfileVC.swift
//  ChitChat
//
//  Created by Ravi dwivedi on 03/03/21.
//  Copyright © 2021 Ravi dwivedi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileVC: UIViewController {
    
    @IBOutlet weak var tableView:UITableView!
    
    var data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier:"cell")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Profile"

    }
    
    
}

extension ProfileVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert  = UIAlertController(title:"Logged Out", message:"Are you sure wants to logOut?", preferredStyle:.alert)
        alert.addAction(UIAlertAction(title:"OK", style: .default, handler: {[weak self] (action) in
            self?.loggedOut()
            
        }))
        alert.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: {[weak self] (action) in
            self?.dismiss(animated: false, completion: nil)
        }))
        self.present(alert,animated:false)
        
    }
    
    
    func loggedOut(){
        do {
            try Auth.auth().signOut()
             let facebookLoginManager = FBSDKLoginManager()
             facebookLoginManager.logOut()
             GIDSignIn.sharedInstance()?.signOut()
            
            guard let vc = storyboard?.instantiateViewController(withIdentifier:"LoginVC") as? LoginVC else {return}

            self.navigationController?.pushViewController(vc, animated: true)

            
        } catch let error {
            debugPrint("Error while signed Out\(error.localizedDescription)")
        }
        
    }
    
}
