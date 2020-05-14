//
//  Teacher.swift
//  App
//
//  Created by Rujira Petrung on 1/5/20.
//

import Vapor
import FluentPostgreSQL

final class Teacher: Codable {
    
    typealias Database = PostgreSQLData
    
    var id: Int?
    var firstName: String
    var lastName: String
    var roomID: Room.ID?
    
    init(firstName: String, lastName: String, roomID: Room.ID) {
        self.firstName = firstName
        self.lastName = lastName
        self.roomID = roomID
    }
}


