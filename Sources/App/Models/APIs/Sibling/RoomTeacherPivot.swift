//
//  TeacherRoomPivot.swift
//  App
//
//  Created by Rujira Petrung on 28/5/20.
//

import Foundation
import FluentPostgreSQL

final class RoomTeacherPivot: PostgreSQLUUIDPivot {
    
    typealias Database = PostgreSQLDatabase
    
    var id: UUID?
    var roomID: Room.ID
    var teacherID: Teacher.ID
    
    typealias Left = Room
    typealias Right = Teacher
    
    static let leftIDKey: LeftIDKey = \.roomID
    static let rightIDKey: RightIDKey = \.teacherID
    
    init(_ room: Room, _ teacher: Teacher) throws {
        self.roomID = try room.requireID()
        self.teacherID = try teacher.requireID()
    }
}

extension RoomTeacherPivot: Migration {
    //Foreign key constraints
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.roomID, to: \Room.id, onDelete: .cascade)
            builder.reference(from: \.teacherID, to: \Teacher.id, onDelete: .cascade)
        }
    }
}
extension RoomTeacherPivot: ModifiablePivot {}

