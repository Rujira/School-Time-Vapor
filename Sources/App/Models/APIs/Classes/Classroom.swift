//
//  Classroom.swift
//  App
//
//  Created by Rujira Petrung on 10/7/20.
//

import Vapor
import FluentPostgreSQL

final class Classroom: Codable {
    
    typealias Database = PostgreSQLDatabase
    
    var id: UUID?
    var name: String
    var section: String
    var schoolID: School.ID
    var subjectID: Subject.ID?
    var createAt: Date?
    var updateAt: Date?
    var createBy: String
    var updateBy: String
    
    init(name: String, section: String, schoolID: School.ID, createBy: String, updateBy: String) {
        
        self.name = name
        self.section = section
        self.schoolID = schoolID
        self.createBy = createBy
        self.updateBy = updateBy
    }
}

extension Classroom: PostgreSQLUUIDModel {
    static let createdAtKey: TimestampKey? = \.createAt
    static let updatedAtKey: TimestampKey? = \.updateAt
}

extension Classroom: Content {}
extension Classroom: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.schoolID, to: \School.id)
        }
    }
}

extension Classroom: Parameter {}
extension Classroom {
    
    var school: Parent<Classroom, School> {
        return parent(\.schoolID)
    }
    
}
