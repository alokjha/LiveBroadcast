//
//  ViewController.swift
//  LiveBroadcast
//
//  Created by Alok Jha on 05/02/19.
//  Copyright © 2019 Alok Jha. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var liveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    

    @IBAction func liveButtonPressed(_ sender: UIButton) {
       let liveBroadCastVC = self.storyboard?.instantiateViewController(withIdentifier: "liveBroadcastVC") as! LiveBroadcastViewController
        self.present(liveBroadCastVC, animated: true) {
            //liveBroadCastVC.startLiveBroadcast()
        }
    }

}
