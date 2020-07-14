//
//  ClassroomTeacherPivot.swift
//  App
//
//  Created by Rujira Petrung on 10/7/20.
//

import Foundation
import FluentPostgreSQL

final class ClassroomTeacherPivot: PostgreSQLUUIDPivot {
    
    typealias Database = PostgreSQLDatabase
    
    var id: UUID?
    var classroomID: Classroom.ID
    var teacherID: Teacher.ID
    
    typealias Left = Classroom
    typealias Right = Teacher
    
    static let leftIDKey: LeftIDKey = \.classroomID
    static let rightIDKey: RightIDKey = \.teacherID

    init(_ classroom: Classroom, _ teacher: Teacher) throws {
        self.classroomID = try classroom.requireID()
        self.teacherID = try teacher.requireID()
    }
}

extension ClassroomTeacherPivot: Migration {
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.classroomID, to: \Classroom.id, onDelete: .cascade)
            builder.reference(from: \.teacherID, to: \Teacher.id, onDelete: .cascade)
        }
    }
}
extension ClassroomTeacherPivot: ModifiablePivot {}

