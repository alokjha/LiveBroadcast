//
//  LiveEventManager.swift
//  LiveBroadcast
//
//  Created by Alok Jha on 06/02/19.
//  Copyright © 2019 Alok Jha. All rights reserved.
//

import Foundation

struct LiveEvent: Codable {
    
    let date: Date
    let hlsURL : String
    
    init(date: Date, hlsURL: String) {
        self.date = date
        self.hlsURL = hlsURL
    }
}

struct LiveEventManager {
    static var shared = LiveEventManager()
    private(set) var allEvents: [LiveEvent]
    private let key = "allLiveEvents"
    
    private  init() {
        if let data = UserDefaults.standard.data(forKey: key), let events = try? JSONDecoder().decode([LiveEvent].self, from: data) {
            let sorted = events.sorted(by: { $0.date < $1.date })
            allEvents = sorted
        }
        else {
            allEvents = []
        }
    }
    
    mutating func addEvent(_ event: LiveEvent) {
        allEvents.append(event)
        allEvents = allEvents.sorted(by: { $0.date < $1.date })
        save()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(allEvents) {
            UserDefaults.standard.set(data, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
}
