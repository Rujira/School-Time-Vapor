//
//  Parent.swift
//  App
//
//  Created by Rujira Petrung on 28/5/20.
//

import Vapor
import FluentPostgreSQL

final class ParentFamily: Codable {

    typealias Database = PostgreSQLDatabase

    var id: UUID?
    var parentID: String
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
    var profilePicture: String?

    init(parentID: String, fullName: String, lastName: String, genderType: GenderType, createBy: String, updateBy: String, schoolID: School.ID, profilePicture: String? = nil) {

        self.parentID = parentID
        self.fullName = fullName
        self.genderType = genderType
        self.createBy = createBy
        self.updateBy = updateBy
        self.schoolID = schoolID
        self.profilePicture = profilePicture
    }

}

extension ParentFamily: PostgreSQLUUIDModel {

    static let createdAtKey: TimestampKey? = \.createAt
    static let updatedAtKey: TimestampKey? = \.updateAt

}

extension ParentFamily: Content {}
extension ParentFamily: Migration {}
extension ParentFamily: Parameter {}

extension ParentFamily {

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



