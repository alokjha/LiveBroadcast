//
//  Constants.swift
//  LiveBroadcast
//
//  Created by Alok Jha on 06/02/19.
//  Copyright © 2019 Alok Jha. All rights reserved.
//

import Foundation

let artistTopic = "artist"

let rtmpHost = "rtmp://13.127.163.52:1935/app"
let hlsBaseURL = "http://13.127.163.52/live/"

let firebasOauthToken = "ya29.GlyoBj0YmQkohT06cWjOYXv6j1S3dYRVxZIhadySyZOet_jfDME4c5i0kNPOaSBQdnRmsIHUFc1y_i1Y0LBjPwJk76ZYNpxNSrzb55InKWc0Lk2rXey1zLl3WLlguQ"


let goLiveNotification = Notification.Name("goLiveNotification")
let scheduleLiveNotification = Notification.Name("scheduleLiveNotification")

func liveStreamHLSURL(with streamName: String) -> String {
     return hlsBaseURL.appending("\(streamName)/index.m3u8")
}

func createLiveNotificationPayload(withName streamName:String, topic: String) -> [String: Any] {
    var jsonDict : [String: Any] = [:]
    jsonDict["topic"] = topic
    jsonDict["notification"] = ["body" : "Live Streaming started", "title": "Live"]
    jsonDict["data"] = ["stream" : liveStreamHLSURL(with: streamName), "date" : Date()]
    
    let body = ["message" : jsonDict]
    
    return body
}

func createScheduleEventNotificationPayload(withEvent event:ScheduledEvent, topic: String) -> [String: Any] {
    var jsonDict : [String: Any] = [:]
    jsonDict["topic"] = topic
    jsonDict["notification"] = ["body" : "An Live Streaming event has been schedule", "title": "Live"]
    jsonDict["data"] = ["date" : event.date]
    
    let body = ["message" : jsonDict]
    
    return body
}
