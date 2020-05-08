//
//  SchoolPeopleContext.swift
//  App
//
//  Created by Rujira Petrung on 1/5/20.
//

import Foundation

//People

struct SchoolPeopleOverviewContext: Encodable {
    //Overview
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
}

struct SchoolPeopleTeachersContext: Encodable {
    //Teacher
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
}

struct SchoolPeopleStudentsContext: Encodable {
    //Student
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
}

struct SchollPeopleParentsContext: Encodable {
    //Parent
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
}

//End People
