//
//  SettingsVC.swift
//  14-FirebaseInstaClone
//
//  Created by Berke Ersiz on 26.08.2023.
//

import UIKit
import FirebaseAuth

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func logoutClicked(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "toViewController", sender: nil)
        }catch{
            print("Error!")
        }
        
        
    }
    
}
