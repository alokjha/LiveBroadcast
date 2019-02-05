//
//  MXCADisplayLinkProxy.swift
//  MXPlayer
//
//  Created by Bhargav Gurlanka on 18/01/19.
//  Copyright © 2019 MX Player. All rights reserved.
//

import Foundation
import QuartzCore

/// A proxy object to break retain cycle when using CADisplayLink.
///
/// Since CADisplayLink holds it's target strongly,
/// we create a proxy object to break this.
///
/// Normal case:
///
///                  strong
///    (foo object)--------->(CADisplayLink object)
///          ^                         |
///          | strong                  |
///          `-------------------------´
///
///    So, even if there are no visible strong references to `foo` object,
///    it won't get deallocated, because `CADisplayLink` is holding it strongly.
///    This causes memory leak
///
/// Using this proxy:
///
///                  strong
///    (foo object)--------->(CADisplayLink object)
///          ^                         |
///          |      weak               |
///          | (invokes callback       | strong
///          |  for each tick)         |
///          |                         |
///          `------------(MXCADisplayLinkProxy object)
///
///    We break this strong reference by creating a proxy object, which will hold
///    `foo` weakly.
///    In `foo`'s dealloc method, we can invalidate `CADisplayLink` object, which will
///    ultimately release our proxy object too.
final class MXCADisplayLinkProxy {
    private let callback: () -> Void
    
    private init(_ callback: @escaping () -> Void) {
        self.callback = callback
    }
    
    static func configuredDisplayLink(frameRate: Int = 10, callback: @escaping () -> Void) -> CADisplayLink {
        let proxy = MXCADisplayLinkProxy(callback)
        let displayLink = CADisplayLink(target: proxy, selector: #selector(tick))
        
        /// Update controlsView every 100 milliseconds
        displayLink.preferredFramesPerSecond = frameRate
        
        displayLink.add(to: .main, forMode: .default)
        return displayLink
    }
    
    @objc
    func tick() {
        callback()
    }
}
