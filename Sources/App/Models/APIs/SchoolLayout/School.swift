//
//  School.swift
//  App
//
//  Created by Rujira Petrung on 15/4/20.
//

import Vapor
import FluentPostgreSQL

final class School: Codable {
    
    typealias Database = PostgreSQLDatabase
    
    var id: UUID?
    var name: String
    var userID: User.ID
    
    init(name: String, userID: User.ID) {
        self.name = name
        self.userID = userID
    }
}

extension School: PostgreSQLUUIDModel {}
extension School: Content {}
extension School: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}
extension School: Parameter {}

//Get Childldren
extension School {
    var grades: Children<School, Grade> {
        return children(\.schoolID)
    }
    var zones: Children<School, Zone> {
        return children(\.schoolID)
    }
}

//Get Parent
extension School {
    var user: Parent<School, User> {
        return parent(\.userID)
    }
}
