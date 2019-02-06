//
//  Constants.swift
//  LiveBroadcast
//
//  Created by Alok Jha on 06/02/19.
//  Copyright © 2019 Alok Jha. All rights reserved.
//

import Foundation

let artistTopic = "artist"
let artistName = "Phony Nigam"
let subscriberName = "Another Nigam Fan"

let rtmpHost = "rtmp://13.127.163.52:1935/app"
let hlsBaseURL = "http://13.127.163.52/live/"

let firebasOauthToken = "ya29.GlyoBhb17ii5Fc84y2BNgUK9PcDaejNq-RBhgiPxvzHsrYG59ha3_uB1ZNYzLQ8q97Cpxz9mB8k2PQ0F7zwtlLZ9wLDu7ZPSdZpJK2gGhnHl8uadf5Q3ppJChfPzzA"


let goLiveNotification = Notification.Name("goLiveNotification")
let scheduleLiveNotification = Notification.Name("scheduleLiveNotification")

func liveStreamHLSURL(with streamName: String) -> String {
     return hlsBaseURL.appending("\(streamName)/index.m3u8")
}

func createLiveNotificationPayload(withName streamName:String, topic: String) -> [String: Any] {
    var jsonDict : [String: Any] = [:]
    jsonDict["topic"] = topic
    jsonDict["notification"] = ["body" : "Catch \(artistName) live now", "title": "\(artistName) is live now"]
    let date = Date()
    jsonDict["data"] = ["stream" : liveStreamHLSURL(with: streamName), "date" : DateFormatter.appDateFormatter().string(from: date)]
    
    let body = ["message" : jsonDict]
    
    return body
}

func createScheduleEventNotificationPayload(withEvent event:ScheduledEvent, topic: String) -> [String: Any] {
    var jsonDict : [String: Any] = [:]
    jsonDict["topic"] = topic
    jsonDict["notification"] = ["body" : "A Live Streaming event has been scheduled", "title": "\(artistName) coming live soon"]
    jsonDict["data"] = ["date":event.date]
    
    let body = ["message" : jsonDict]
    
    return body
}

extension DateFormatter {
    
    static func appDateFormatter() -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy, hh:mm a"
        return df
    }
}
