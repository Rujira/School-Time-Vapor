//
//  Subject.swift
//  App
//
//  Created by Rujira Petrung on 1/7/20.
//

import Vapor
import FluentPostgreSQL

final class Subject: Codable {
    
    typealias Database = PostgreSQLDatabase
    
    var id: UUID?
    var name: String
    var subjectID: String
    var category: DepartmentType
    var subjectLevel: SubjectLevel
    var schoolID: School.ID
    var description: String
    var createAt: Date?
    var updateAt: Date?
    var createBy: String
    var updateBy: String
    
    init(name: String, subjectID: String, category: DepartmentType, subjectLevel: SubjectLevel, schoolID: School.ID, description: String, createBy: String, updateBy: String) {
        self.name = name
        self.subjectID = subjectID
        self.category = category
        self.subjectLevel = subjectLevel
        self.schoolID = schoolID
        self.description = description
        self.createBy = createBy
        self.updateBy = updateBy
    }
}

extension Subject: PostgreSQLUUIDModel {
    static let createdAtKey: TimestampKey? = \.createAt
    static let updatedAtKey: TimestampKey? = \.updateAt
}
extension Subject: Content {}
extension Subject: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.schoolID, to: \School.id)
        }
    }
    
}
extension Subject: Parameter {}
extension Subject {
    
    var school: Parent<Subject, School> {
        return parent(\.schoolID)
    }
    
    var lessons: Children<Subject, Lesson> {
        return children(\.subjectID)
    }
}

