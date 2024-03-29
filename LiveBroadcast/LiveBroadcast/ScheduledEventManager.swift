//
//  Event.swift
//  LiveBroadcast
//
//  Created by Alok Jha on 06/02/19.
//  Copyright © 2019 Alok Jha. All rights reserved.
//

import UIKit

struct ScheduledEvent: Codable {
    let date: String
    
    init(date: String) {
        self.date = date
    }
}


struct ScheduledEventManager {
    static var shared = ScheduledEventManager()
    private(set) var allEvents: [ScheduledEvent]
    private let key = "allScheduledEvents"
    
    private  init() {
        if let data = UserDefaults.standard.data(forKey: key), let events = try? JSONDecoder().decode([ScheduledEvent].self, from: data) {
            allEvents = events
        }
        else {
            allEvents = []
        }
    }
    
    mutating func addEvent(_ event: ScheduledEvent) {
        allEvents.append(event)
        allEvents = allEvents.sorted(by: { $0.date < $1.date })
        save()
    }
    
    mutating func removeAllEvents() {
        allEvents = []
        save()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(allEvents) {
            UserDefaults.standard.set(data, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
}


class EventCell: UITableViewCell {
    @IBOutlet var dateLabel: UILabel!
}
