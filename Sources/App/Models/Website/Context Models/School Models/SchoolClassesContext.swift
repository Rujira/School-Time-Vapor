//
//  SchoolClassroomsAndSubjectsContext.swift
//  App
//
//  Created by Rujira Petrung on 30/6/20.
//

import Foundation
import Vapor

struct SchoolClassesOverviewContext: Encodable {
    
    //Classes Overview
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
}

struct SchoolClassesSubjectsContext: Encodable {
    
    //Subjects
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let subjects: Future<[Subject]>
}

struct SchoolClassesSubjectDetailContext: Encodable {
    
    //Subject Detail
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let subject: Subject
    let lessons: Future<[Lesson]>
}

struct CreateSubjectContext: Encodable {
    
    //Create Subject
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let createBy: String
    let updateBy: String
    let categories: [DepartmentType]
    let subjectLevels: [SubjectLevel]
    
}

struct EditSubjectContext: Encodable {
    
    //Edit Subject
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let createBy: String
    let updateBy: String
    let categories: [DepartmentType]
    let subjectLevels: [SubjectLevel]
    let subject: Subject
    let editing = true
    
}

struct CreateLessonContext: Encodable {
    
    //Create Lesson
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let selectedSubject: Subject
    let createBy: String
    let updateBy: String
}

struct EditLessonContext: Encodable {
    
    //Edit Lesson
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
    let selectedSubject: Subject
    let createBy: String
    let updateBy: String
    let lesson: Lesson
    let editing = true
}

struct SchoolClassesClassroomsContext: Encodable {
    
    //Classrooms
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
}



