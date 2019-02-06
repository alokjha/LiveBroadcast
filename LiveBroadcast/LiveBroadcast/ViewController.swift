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
    
    var hasMicrophonePermission = false
    var hasCameraPermission = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermissions()
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
       startLiveBroadcast()
    }
    
    func startLiveBroadcast() {
        guard hasMicrophonePermission else {
            requestMicrophonePermission { [unowned self] in
                self.startLiveBroadcast()
            }
            return
        }
        
        guard hasCameraPermission else {
            requestCameraPermission { [unowned self] in
                self.startLiveBroadcast()
            }
            return
        }
        
        let liveBroadCastVC = self.storyboard?.instantiateViewController(withIdentifier: "liveBroadcastVC") as! LiveBroadcastViewController
        self.present(liveBroadCastVC, animated: true, completion: nil)
    }

}

extension ViewController {
    
    func checkPermissions() {
        let microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        switch microphoneStatus {
        case .authorized:
            hasMicrophonePermission = true
        default:
            hasMicrophonePermission = false
        }
        
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraStatus {
        case .authorized:
            hasCameraPermission = true
        default:
            hasCameraPermission = false
        }
    }
    
    func requestMicrophonePermission(_ completion: @escaping () -> Void) {
        AVCaptureDevice.requestAccess(for: .audio) { [unowned self](success) in
            self.hasMicrophonePermission = success
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func requestCameraPermission(_ completion: @escaping () -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { [unowned self](success) in
            self.hasCameraPermission = success
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
}
