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
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var profileLabel: UILabel!
    @IBOutlet var notifyButton: UIButton!
    @IBOutlet var liveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func notifyButtonPressed(_ sender: UIButton) {
        Delegate.sendNotification()
    }
    
    @IBAction func viewLiveButtonPressed(_ sender: UIButton) {
        let recordingVC = self.storyboard?.instantiateViewController(withIdentifier: "recordingVC") as! RecordingViewController
        self.present(recordingVC, animated: true, completion: nil)
    }

    @IBAction func liveButtonPressed(_ sender: UIButton) {
       let liveBroadCastVC = self.storyboard?.instantiateViewController(withIdentifier: "liveBroadcastVC") as! LiveBroadcastViewController
        self.present(liveBroadCastVC, animated: true, completion: nil)
    }

}
