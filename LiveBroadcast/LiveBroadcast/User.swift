//
//  User.swift
//  LiveBroadcast
//
//  Created by Alok Jha on 06/02/19.
//  Copyright © 2019 Alok Jha. All rights reserved.
//

import Foundation

enum UserType: String, Codable {
    case arist
    case subscriber
    case unknown
}


class User {
    static let shared = User()
    private(set) var userType: UserType
    
    private init() {
        if let type = UserDefaults.standard.value(forKey: "user") as? String {
            userType = UserType(rawValue: type) ?? .unknown
        }
        else {
            userType = .unknown
        }
    }
    
    func loginWithType(_ type: UserType) {
        self.userType = type
        save()
    }
    
    func logOut() {
        self.userType = .unknown
        save()
    }
    
    private func save() {
        UserDefaults.standard.set(userType.rawValue, forKey: "user")
        UserDefaults.standard.synchronize()
    }
}
