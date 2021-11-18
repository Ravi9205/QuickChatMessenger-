//
//  ConversessionVC.swift
//  ChitChat
//
//  Created by Ravi dwivedi on 03/03/21.
//  Copyright © 2021 Ravi dwivedi. All rights reserved.
//

import UIKit
import FirebaseAut

class ConversessionVC: UIViewController {
    
    @IBOutlet weak var tableView:UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Chats"
        
        
    }
    
    @IBAction func didTapComposeButton(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier:"NewConversessionVC") as? NewConversessionVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
   
    
}

extension ConversessionVC :UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell  = self.tableView.dequeueReusableCell(withIdentifier:"ConverssessionCell", for: indexPath) as? ConverssessionCell else {
            fatalError()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier:"ChatViewController") as? ChatViewController else {return}
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
}




