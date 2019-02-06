//
//  Constants.swift
//  LiveBroadcast
//
//  Created by Alok Jha on 06/02/19.
//  Copyright © 2019 Alok Jha. All rights reserved.
//

import Foundation

let artistTopic = "artist"
let subscriberTopic = "subscriber"

let firebasOauthToken = "ya29.GlyoBj0YmQkohT06cWjOYXv6j1S3dYRVxZIhadySyZOet_jfDME4c5i0kNPOaSBQdnRmsIHUFc1y_i1Y0LBjPwJk76ZYNpxNSrzb55InKWc0Lk2rXey1zLl3WLlguQ"


let goLiveNotification = Notification.Name("goLiveNotification")
let scheduleLiveNotification = Notification.Name("scheduleLiveNotification")

private func randomString(length: Int) -> String {
    guard length > 2 else {
        return ""
    }
    let letters = "abcdefghijklmnopqrstuvwxyz123456789"
    return String((0...length-1).map{ _ in letters.randomElement()! })
}

struct StreamNameGenerator {
    
    static var shared = StreamNameGenerator()
    private(set) var streamName = ""
    
    private init() {
        if let name = UserDefaults.standard.value(forKey: "") as? String {
            streamName = name
        }
        else {
            streamName = randomString(length: 3)
        }
    }
    
    mutating func generateStreamName() -> String {
        streamName = randomString(length: 8)
        save()
        return streamName
    }
    
    private func save() {
        UserDefaults.standard.set(streamName, forKey: "streamName")
        UserDefaults.standard.synchronize()
    }
}
