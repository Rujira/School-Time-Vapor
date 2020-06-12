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
    var createAt: Date?
    var updateAt: Date?
    var createBy: String
    var updateBy: String
    
    init(name: String, schoolID: School.ID, gradeType: GradeType, createBy: String, updateBy: String) {
        self.name = name
        self.schoolID = schoolID
        self.gradeType = gradeType
        self.createBy = createBy
        self.updateBy = updateBy
    }
}

extension Grade: PostgreSQLUUIDModel {
    static let createdAtKey: TimestampKey? = \.createAt
    static let updatedAtKey: TimestampKey? = \.updateAt
}
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



