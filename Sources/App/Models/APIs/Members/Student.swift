//
//  Student.swift
//  App
//
//  Created by Rujira Petrung on 13/4/20.
//

import Vapor
import FluentPostgreSQL

final class Student: Codable {
    
    typealias Database = PostgreSQLDatabase
    
    var id: UUID?
    var studentID: String
    var studentNumber: Int
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
    var roomID: Room.ID
    var profilePicture: String?
    
    init(studentID: String, studentNumber: Int, fullName: String, genderType: GenderType, createBy: String, updateBy: String, schoolID: School.ID, roomID: Room.ID, profilePicture: String? = nil) {
       
        self.studentID = studentID
        self.studentNumber = studentNumber
        self.fullName = fullName
        self.genderType = genderType
        self.createBy = createBy
        self.updateBy = updateBy
        self.schoolID = schoolID
        self.roomID = roomID
        self.profilePicture = profilePicture
    }
}

extension Student: PostgreSQLUUIDModel {
    
    static let createdAtKey: TimestampKey? = \.createAt
    static let updatedAtKey: TimestampKey? = \.updateAt
    
}

extension Student: Content {}
extension Student: Migration {
    
    //Foreign key constraints
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
           
            try addProperties(to: builder)
            builder.reference(from: \.roomID, to: \Room.id)
        }
    }
}

extension Student: Parameter {}

//Getting Parent
extension Student {
    
    var room: Parent<Student, Room> {
        return parent(\.roomID)
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



