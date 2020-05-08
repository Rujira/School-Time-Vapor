//
//  Room.swift
//  App
//
//  Created by Rujira Petrung on 15/4/20.
//

import Vapor
import FluentPostgreSQL

final class Room: Codable {
    
    typealias Database = PostgreSQLDatabase
    
    var id: UUID?
    var name: String
    var gradeID: Grade.ID
    
    init(name: String, gradeID: Grade.ID) {
        self.name = name
        self.gradeID = gradeID
    }
}

extension Room: PostgreSQLUUIDModel {}
extension Room: Content {}
extension Room: Migration {
    
    //Foreign key constraints
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.gradeID, to: \Grade.id)
        }
    }
}
extension Room: Parameter {}

extension Room {
    var grade: Parent<Room, Grade> {
        return parent(\.gradeID)
    }
    
    var students: Children<Room, Student> {
        return children(\.roomID)
    }
}

