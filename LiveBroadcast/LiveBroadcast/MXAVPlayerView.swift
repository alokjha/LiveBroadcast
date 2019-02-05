//
//  MXAVPlayerView.swift
//  MXPlayer
//
//  Created by Bhargav Gurlanka on 30/10/18.
//  Copyright © 2018 MX Player. All rights reserved.
//

import Foundation
import AVKit

enum MXMediaPlayerVideoContentMode {
    case aspectFill
    case aspectFit
    case scaleToFill
}

final class MXAVPlayerView: UIView {
    var hasFrameToDisplay: Bool {
        return (layer as? AVPlayerLayer)?.isReadyForDisplay ?? false
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    func setPlayer(_ player: AVPlayer, contentMode: MXMediaPlayerVideoContentMode) {
        guard let layer = layer as? AVPlayerLayer else { return }
        switch contentMode {
        case .aspectFill:
            layer.videoGravity = .resizeAspectFill
        case .aspectFit:
            layer.videoGravity = .resizeAspect
        case .scaleToFill:
            layer.videoGravity = .resize
        }
        
        layer.contentsScale = UIScreen.main.scale
        layer.player = player
    }
}
