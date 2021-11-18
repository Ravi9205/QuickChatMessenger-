//
//  AlertVC.swift
//  ChitChat
//
//  Created by Ravi dwivedi on 02/03/21.
//  Copyright © 2021 Ravi dwivedi. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController{
    
    func showAlert(title:String,message:String)->(){
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"OK", style: .default, handler: { (_) in
            print("You've Pressed default")

        }))
        self.present(alert, animated: true, completion: nil)
    }
}

