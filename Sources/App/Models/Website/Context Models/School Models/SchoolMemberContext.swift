//
//  SchoolPeopleContext.swift
//  App
//
//  Created by Rujira Petrung on 1/5/20.
//

import Foundation
import Vapor

//People

struct SchoolMembersStudentsContext: Encodable {
    
    //Student
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let students: Future<[StudentsWithRoom]>
    let rooms: Future<[Room]>
}

struct SchoolMembersStudentDetailContext: Encodable {
    
    //Student Detail
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let student: Student
    let room: Future<Room>
}

struct StudentsWithRoom: Content {
    
    //Student with room
    let id: UUID?
    let studentID: String
    let firstName: String
    let lastName: String
    let profilePicture : String
    let genderType: GenderType
    let birthDate: String?
    let age: String?
    let createBy: String
    let createAt: Date?
    let room: String
}

struct CreateStudentContext: Encodable {
    
    //Create Student
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let createBy: String
    let updateBy: String
    let genderTypes: [GenderType]
    let rooms: Future<[Room]>
    
}

struct ImageUploadData: Content {
    var picture: Data
}

struct EditStudentContext: Encodable {
    
    //Edit Student
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let createBy: String
    let updateBy: String
    let genderTypes: [GenderType]
    let rooms: Future<[Room]>
    let student: Student
    let editing = true
}

struct AddStudentProfilePictureContext: Encodable {
    
    //Add Student Profile
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let student : Student
    
}


struct SchoolMembersOverviewContext: Encodable {
    
    //Overview
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
}

struct SchoolMembersTeachersContext: Encodable {
    
    //Teacher
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let teachers: Future<[Teacher]>
}

struct SchoolMembersTeacherDetailContext: Encodable {
    
    //Student Detail
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let teacher: Teacher

}

struct CreateTeacherContext: Encodable {
    
    //Create Teacher
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let createBy: String
    let updateBy: String
    let genderTypes: [GenderType]
    let departmentTypes: [DepartmentType]
    
}

struct EditTeachertContext: Encodable {
    
    //Edit Student
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let teacher: Teacher
    let createBy: String
    let updateBy: String
    let genderTypes: [GenderType]
    let departmentTypes: [DepartmentType]
    let editing = true
}

struct AddTeacherProfilePictureContext: Encodable {
    
    //Add Student Profile
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let teacher: Teacher
    
}

struct SchoolMembersParentsContext: Encodable {
    
    //Parent
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
}

//End People
