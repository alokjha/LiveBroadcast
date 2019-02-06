//
//  Event.swift
//  LiveBroadcast
//
//  Created by Alok Jha on 06/02/19.
//  Copyright © 2019 Alok Jha. All rights reserved.
//

import UIKit

struct ScheduledEvent: Codable {
    let date: Date
    
    init(date: Date) {
        self.date = date
    }
}


struct EventManager {
    static var shared = EventManager()
    private(set) var allEvents: [ScheduledEvent]
    
    private  init() {
        if let data = UserDefaults.standard.data(forKey: "allEvents"), let events = try? JSONDecoder().decode([ScheduledEvent].self, from: data) {
            let sorted = events.sorted(by: { $0.date < $1.date })
            allEvents = sorted
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
    
    private func save() {
        if let data = try? JSONEncoder().encode(allEvents) {
            UserDefaults.standard.set(data, forKey: "allEvents")
            UserDefaults.standard.synchronize()
        }
    }
}

class EventCell: UITableViewCell {
    @IBOutlet var dateLabel: UILabel!
}
