//
//  LoginViewController.swift
//  LiveBroadcast
//
//  Created by Alok Jha on 06/02/19.
//  Copyright © 2019 Alok Jha. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func artistLogin(_ sender: UIButton) {
        User.shared.loginWithType(.arist)
        showProfileVC()
        Delegate.unsubscribe(from: artistTopic)
    }
    
    @IBAction func subscriberLogin(_ sender: UIButton) {
        User.shared.loginWithType(.subscriber)
        showProfileVC()
        Delegate.subscribe(to: artistTopic)
    }

    func showProfileVC() {
        let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController")
        Delegate.window?.rootViewController = profileVC
    }

}
