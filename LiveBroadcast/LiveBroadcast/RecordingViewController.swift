//
//  RecordingViewController.swift
//  LiveBroadcast
//
//  Created by Alok Jha on 05/02/19.
//  Copyright © 2019 Alok Jha. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController {
    
    @IBOutlet var videoView: MXAVPlayerView!
    @IBOutlet var timeLabel: UILabel!
    
    private let keysToAutoLoad = [ "tracks",
                                   "duration",
                                   "commonMetadata",
                                   "availableMediaCharacteristicsWithMediaSelectionOptions" ]
    
    var liveEvent: LiveEvent?
    
    private let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    let avPlayer = AVPlayer()
    private var observationInfos: [NSKeyValueObservation] = []
    private var timeObserver: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
    }
    
    func setupPlayer() {
        
        guard let event = liveEvent else {
            return
        }
        
        avPlayer.rate = 1.0
        
        let hlsURL = event.hlsURL
        let asset = AVURLAsset(url: URL(string: event.hlsURL)!)
        asset.resourceLoader.preloadsEligibleContentKeys = true
        asset.loadValuesAsynchronously(forKeys: keysToAutoLoad, completionHandler: nil)
        let playerItem = AVPlayerItem(asset: asset)
        avPlayer.replaceCurrentItem(with: playerItem)
    
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePlaybackEnd(notification:)),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)
        let statusChange = avPlayer.observe(
            \AVPlayer.status,
            changeHandler: { [weak self] (player, _) in
                self?.handleStateChange(avPlayer: player)
            }
        )
        observationInfos.append(statusChange)
        
        let interval = CMTime(seconds: 1.0,
                             preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let timeChange = avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] (time) in
            guard let `self` = self else {
                return
            }
            
            let timeInSeconds = CMTimeGetSeconds(time)
            let defaultValue = "0:00:00"
            self.timeLabel.text = self.timeFormatter.string(from: timeInSeconds) ?? defaultValue
            
        }
        
        timeObserver = timeChange
        
        videoView.setPlayer(avPlayer, contentMode: .aspectFill)
        
        print("Viewing live stream at \(hlsURL)")
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.removeObserver(self)
        avPlayer.pause()
        avPlayer.replaceCurrentItem(with: nil)
        if let observer = timeObserver {
            avPlayer.removeTimeObserver(observer)
        }
        self.dismiss(animated: true, completion: nil)
    }

    @objc
    private func handlePlaybackEnd(notification: Notification) {
        closeButtonPressed(UIButton())
    }
    
    
    private func handleStateChange(avPlayer: AVPlayer) {
        
        switch avPlayer.status {
        case .failed:
            break
            //updateState(to: .ended(.error(.unknown)))
        case .readyToPlay:
            //updateState(to: .readyToPlay)
            break
        case .unknown:
            break
            //updateState(to: .uninitialized)
        }
    }
}
