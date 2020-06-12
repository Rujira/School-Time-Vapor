//
//  SchoolContexts.swift
//  App
//
//  Created by Rujira Petrung on 24/4/20.
//

import Foundation
import Vapor

//Layout
struct SchoolLayoutOverviewContext: Encodable {
    //Overview
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let grades: Future<[GradeWithRooms]>
    let rooms: Future<[RoomWithStudents]>
    let students: Future<[Student]>
    let zones: Future<[Zone]>
    
}

struct DahuaInfo: Content {
    let data: String
}

struct SchoolLayoutGradesContext: Encodable {
    //Grades
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let grades: Future<[GradeWithRooms]>
   
}

struct SchoolLayoutGradeDetailContext: Encodable {
    //Grade Detail
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let grade: Grade
    let rooms: Future<[Room]>
}

struct GradeWithRooms: Content {
    //Grade List Content
    let id: UUID?
    let name: String
    let schoolID: School.ID
    let gradeType: GradeType
    let updateBy: String
    let updateAt: Date?
    let rooms: [Room]
}

struct RoomsWithGrade: Content {
    
    let id: UUID?
    let name: String
    let grade: Grade
}

struct CreateGradeContext: Encodable {
    //Grades Create
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let createBy: String
    let updateBy: String
    let gradeTypes: [GradeType]
}

struct EditGradeContext: Encodable {
    //Grades Edit
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let createBy: String
    let updateBy: String
    let gradeTypes: [GradeType]
    let grade: Grade
    let editing = true
}

struct SchoolLayoutRoomsContext: Encodable {
    //Rooms
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let grades: Future<[GradeWithRooms]>
    let rooms: Future<[RoomWithStudents]>
}

struct SchoolLayoutRoomDetailContext: Encodable {
    
    //Rooms Detail
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let room: Room
    let students: Future<[Student]>
    let teachers: Future<[Teacher]>
    let homeroomTeachers: Future<[Teacher]>
 
}

struct RoomWithStudents: Content {
    
    //Room List Content
    let id: UUID?
    let name: String
    let gradeID: Grade.ID
    let numberOfSeats: Int
    let createBy: String
    let updateBy: String
    let createAt: Date?
    let updateAt: Date?
    let students: [Student]
    let studentsSeatsPercentage: Int
}

struct CreateRoomContext: Encodable {
    
    //Rooms Create
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let createBy: String
    let updateBy: String
    let grades: Future<[Grade]>
    let teachers: Future<[Teacher]>
    
}

struct EditRoomContext: Encodable {
    
    //Rooms Edit
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let createBy: String
    let updateBy: String
    let grades: Future<[Grade]>
    let room: Room
    let editing = true
}

struct CreateRoomData: Content {
    
    var name: String
    var schoolID: School.ID
    var gradeID: Grade.ID
    var numberOfSeats: Int
    var createBy: String
    var updateBy: String
    let teachers: [Teacher]?
}

struct SchoolLayoutZonesContext: Encodable {
    
    //Zones Context
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
}


//End Layout


