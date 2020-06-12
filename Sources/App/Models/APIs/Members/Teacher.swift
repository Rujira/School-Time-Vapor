//
//  Teacher.swift
//  App
//
//  Created by Rujira Petrung on 1/5/20.
//

import Vapor
import FluentPostgreSQL

final class Teacher: Codable {
    
    typealias Database = PostgreSQLDatabase

    var id: UUID?
    var teacherID: String
    var fullName: String
    var nickName: String?
    var genderType: GenderType
    var birthDate: String?
    var address: String?
    var contactNumber: String?
    var email: String?
    var createBy: String
    var updateBy: String
    var createAt: Date?
    var updateAt: Date?
    var schoolID: School.ID
    var departmentType: DepartmentType
    var profilePicture: String?
    
    init(teacherID: String, fullName: String, genderType: GenderType, createBy: String, updateBy: String, schoolID: School.ID, departmentType: DepartmentType, profilePicture: String? = nil) {
        
        self.teacherID = teacherID
        self.fullName = fullName
        self.genderType = genderType
        self.createBy = createBy
        self.updateBy = updateBy
        self.schoolID = schoolID
        self.departmentType = departmentType
        self.profilePicture = profilePicture
    }
}

extension Teacher: PostgreSQLUUIDModel {
    
    static let createdAtKey: TimestampKey? = \.createAt
    static let updatedAtKey: TimestampKey? = \.updateAt
}

extension Teacher: Migration {}

extension Teacher: Content {}

extension Teacher: Parameter {}

extension Teacher {
    
    //Sibling Relationship Teachers - Rooms
    
    var rooms: Siblings<Teacher, Room, RoomTeacherPivot> {
        return siblings()
    }
    
    static func addTeacher(_ teacher: Teacher, to room: Room, on req: Request) throws -> Future<Void> {
        
        return room.teachers.attach(teacher, on: req).transform(to: ())
    }

    static func removeTeacher(_ teacher: Teacher, from room: Room, on req: Request) throws -> Future<Void> {
        
        return room.teachers.detach(teacher, on: req).transform(to: ())
    }
    
    func getAgeFromDOF(date: String) -> (String) {
     
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "dd-MM-yyyy"
        let dateOfBirth = dateFormater.date(from: date)
        
        if dateOfBirth != nil {
            let calender = Calendar.current

               let dateComponent = calender.dateComponents([.year, .month, .day], from:
               dateOfBirth!, to: Date())

            return (dateComponent.year!).description
        } else {
            return "No Birthday Data"
        }
    }
}
