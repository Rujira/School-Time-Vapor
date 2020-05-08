//
//  Grade.swift
//  App
//
//  Created by Rujira Petrung on 15/4/20.
//

import Vapor
import FluentPostgreSQL

final class Grade: Codable {
    
    typealias Database = PostgreSQLDatabase
    
    var id: UUID?
    var name: String
    var schoolID: School.ID
    var gradeType: GradeType
    
    init(name: String, schoolID: School.ID, gradeType: GradeType) {
        self.name = name
        self.gradeType = gradeType
        self.schoolID = schoolID
    }
}

extension Grade: PostgreSQLUUIDModel {}
extension Grade: Content {}
extension Grade: Migration {
    
    //Foreign key constraints
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.schoolID, to: \School.id)
        }
    }
}
extension Grade: Parameter {}

extension Grade {
    var school: Parent<Grade, School> {
        return parent(\.schoolID)
    }
    
    var rooms: Children<Grade, Room> {
        return children(\.gradeID)
    }
}



