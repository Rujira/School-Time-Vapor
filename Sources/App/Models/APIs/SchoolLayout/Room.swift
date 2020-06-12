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
    var schoolID: School.ID
    var gradeID: Grade.ID
    var numberOfSeats: Int
    var createAt: Date?
    var updateAt: Date?
    var createBy: String
    var updateBy: String
    
    init(name: String, schoolID: School.ID, gradeID: Grade.ID, numberOfSeats: Int, createBy: String, updateBy: String) {
        self.name = name
        self.schoolID = schoolID
        self.gradeID = gradeID
        self.numberOfSeats = numberOfSeats
        self.createBy = createBy
        self.updateBy = updateBy
    }
}

extension Room: PostgreSQLUUIDModel {
    static let createdAtKey: TimestampKey? = \.createAt
    static let updatedAtKey: TimestampKey? = \.updateAt
}
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
    
    var teachers: Siblings<Room, Teacher, RoomTeacherPivot> {
        return siblings()
    }
}

