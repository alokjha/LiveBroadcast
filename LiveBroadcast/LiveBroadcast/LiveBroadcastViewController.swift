//
//  LiveBroadcastViewController.swift
//  LiveBroadcast
//
//  Created by Alok Jha on 05/02/19.
//  Copyright © 2019 Alok Jha. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore
import HaishinKit

class LiveBroadcastViewController: UIViewController {
    
    @IBOutlet var videoView: HKView!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var cameraSwitchButton: UIButton!
    @IBOutlet var timeLabel: UILabel!
    
    let rtmpConnection = RTMPConnection()
    lazy var rtmpStream = RTMPStream(connection: rtmpConnection)

    var cameraPositon = AVCaptureDevice.Position.back
    private var displayLink: CADisplayLink?
    
    private let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    var sessionStartTime = Date()
    
    private let NUMBER_COUNT_DOWN   = 3
    
    var countDownLabel = UILabel()
    lazy var countDown = NUMBER_COUNT_DOWN
    var timer:Timer?
    var layoutDone = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        countDownLabel.translatesAutoresizingMaskIntoConstraints = false
        videoView.addSubview(countDownLabel)
        
        NSLayoutConstraint.activate([countDownLabel.centerXAnchor.constraint(equalTo: videoView.centerXAnchor),
                                     countDownLabel.centerYAnchor.constraint(equalTo: videoView.centerYAnchor)])
        
        countDownLabel.textColor = UIColor.white
        countDownLabel.font = UIFont.systemFont(ofSize: 40.0, weight: .bold)
        countDownLabel.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        guard !layoutDone else {
            return
        }
        
        layoutDone = true
        startCountDown()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc func appDidBecomeActive(_ notification: Notification) {
        guard layoutDone else {
            return
        }
        stopLiveBroadCast()
        startLiveBroadcast()
    }
    
    @objc func appDidEnterBackground(_ notification: Notification) {
        stopLiveBroadCast()
    }
    
    func setup() {
        rtmpStream.syncOrientation = true
        rtmpStream.captureSettings = [
            "sessionPreset": AVCaptureSession.Preset.medium.rawValue,
            "continuousAutofocus": false, // use camera autofocus mode
            "continuousExposure": false, //  use camera exposure mode
        ]
        rtmpStream.videoSettings = [
            "width": 720,
            "height": 1280,
            "maxKeyFrameIntervalDuration": 2
        ]
        rtmpStream.audioSettings = [
            "sampleRate": 44_100
        ]
        
        let audioDevice = AVCaptureDevice.default(for: .audio)
        rtmpStream.attachAudio(audioDevice, automaticallyConfiguresApplicationAudioSession: false) { (error) in
        }
        
        let cameraDevice = cameraWithPosition(cameraPositon)
        rtmpStream.attachCamera(cameraDevice) { error in
        }
    }
    
    func startCountDown() {
        countDownLabel.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateCountDown), userInfo: nil, repeats: true)
    }
    
    @objc func updateCountDown() {
        if(countDown > 0) {
            countDownLabel.text = String(countDown)
            countDown = countDown - 1
        } else {
            startLiveBroadcast()
        }
    }
    
    private func removeCountDownLable() {
        countDown = NUMBER_COUNT_DOWN
        countDownLabel.text = ""
        countDownLabel.removeFromSuperview()
        
        timer?.invalidate()
        timer = nil
    }
    
    func startLiveBroadcast() {
        removeCountDownLable()
        setup()
        videoView.videoGravity = .resizeAspectFill
        videoView.attachStream(rtmpStream)
        rtmpConnection.connect("rtmp://13.127.163.52:1935/app")
        //rtmpConnection.connect("rtmp://foo")
        rtmpStream.publish("mystream")
        
        self.displayLink?.invalidate()

        let displayLink = MXCADisplayLinkProxy.configuredDisplayLink(callback: { [weak self] in
            self?.updateUITick()
        })
        
        sessionStartTime = Date()

        self.displayLink = displayLink
        UIApplication.shared.isIdleTimerDisabled = true
        
        stopButton.tintColor = UIColor.red
    }
    
    func stopLiveBroadCast() {
        UIApplication.shared.isIdleTimerDisabled = false
        displayLink?.invalidate()
        displayLink = nil
        rtmpStream.close()
        rtmpStream.dispose()
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        stopLiveBroadCast()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchCameraPressed(_ sender: UIButton) {
        
        switch cameraPositon {
        case .front:
            cameraPositon = .back
        case .back:
            cameraPositon = .front
        case .unspecified:
            return
        }
        
        let cameraDevice = cameraWithPosition(cameraPositon)
        rtmpStream.attachCamera(cameraDevice) { error in
            print("error \(error)")
        }
        
    }
    
    func updateUITick() {
       let currentTime = Date()
       let diff = currentTime.timeIntervalSince(sessionStartTime)
       let defaultValue = "0:00:00"
       self.timeLabel.text = self.timeFormatter.string(from: diff) ?? defaultValue
    }

    func cameraWithPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        
        let deviceDescoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position)
        
        for device in deviceDescoverySession.devices {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }

}

