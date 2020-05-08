//
//  Student.swift
//  App
//
//  Created by Rujira Petrung on 13/4/20.
//

import Vapor
import FluentPostgreSQL

final class Student: Codable {
    
    typealias Database = PostgreSQLDatabase
    
    var id: Int?
    var firstName: String
    var lastName: String
    var roomID: Room.ID
    
    init(firstName: String, lastName: String, roomID: Room.ID) {
        self.firstName = firstName
        self.lastName = lastName
        self.roomID = roomID
    }
}

extension Student: PostgreSQLModel {}
extension Student: Migration {
    
    //Foreign key constraints
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
           
            try addProperties(to: builder)
            builder.reference(from: \.roomID, to: \Room.id)
        }
    }
}
extension Student: Content {}
extension Student: Parameter {}

//Getting Parent
extension Student {
    var room: Parent<Student, Room> {
        return parent(\.roomID)
    }
}
