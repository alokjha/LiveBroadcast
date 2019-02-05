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
    
    @IBOutlet var videoView: UIView!
    @IBOutlet var liveButton: UIButton!
    
    private enum RecordingState {
        case start
        case stop
    }
    
    let captureSession: AVCaptureSession = AVCaptureSession()
    private let videoQueue = DispatchQueue(label: "VideoCapture")
    private var recordState = RecordingState.start

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setup()
    }
    
    func setup() {
        
        guard let cameraDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        guard let inputDevice = try? AVCaptureDeviceInput.init(device: cameraDevice) else {
            return
        }
        
        let outputDevice = AVCaptureVideoDataOutput.init()
        outputDevice.setSampleBufferDelegate(self, queue: videoQueue)
        
        captureSession.addInput(inputDevice)
        captureSession.addOutput(outputDevice)
        
        captureSession.sessionPreset = .hd1280x720
        
    }
    
    func updateButtonText() {
        switch recordState {
        case .start:
            liveButton.setTitle("Start Live", for: .normal)
        case .stop:
            liveButton.setTitle("Stop Live", for: .normal)
        }
    }

    @IBAction func liveButtonPressed(_ sender: UIButton) {
        switch recordState {
        case .start:
            recordState = .stop
            startLiveStreaming()
        case .stop:
            recordState  = .start
            stopLiveStreaming()
        }
        
        updateButtonText()
    }
    
    func startLiveStreaming() {
        
        videoView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = videoView.bounds
        
        videoView.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func stopLiveStreaming() {
        captureSession.stopRunning()
    }

}

extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let imageSize = CVImageBufferGetEncodedSize(imageBuffer)
        print("imageSize \(imageSize)")
    }
}

