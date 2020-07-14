//
//  Lessons.swift
//  App
//
//  Created by Rujira Petrung on 1/7/20.
//

import Vapor
import FluentPostgreSQL

final class Lesson: Codable {
    
    typealias Database = PostgreSQLDatabase
    
    var id: UUID?
    var lessonNumber: Int
    var lessonName: String
    var lessonDescription: String
    var createBy: String
    var updateBy: String
    var createAt: Date?
    var updateAt: Date?
    var schoolID: School.ID
    var subjectID: Subject.ID
    
    init(lessonNummber: Int, lessonName: String, lessonDescription: String, createBy: String, updateBy: String, schoolID: School.ID, subjectID: Subject.ID) {
        
        self.lessonNumber = lessonNummber
        self.lessonName = lessonName
        self.lessonDescription = lessonDescription
        self.createBy = createBy
        self.updateBy = updateBy
        self.schoolID = schoolID
        self.subjectID = subjectID
    }
    
}

extension Lesson: PostgreSQLUUIDModel {
    
    static let createdAtKey: TimestampKey? = \.createAt
    static let updatedAtKey: TimestampKey? = \.updateAt
    
}

extension Lesson: Content {}
extension Lesson: Migration {

    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
           
            try addProperties(to: builder)
            builder.reference(from: \.subjectID, to: \Subject.id)
        }
    }
}

extension Lesson: Parameter {}

extension Lesson {
    
    var subject: Parent<Lesson, Subject> {
        return parent(\.subjectID)
    }
}
