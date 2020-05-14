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
    let selectedSchool: School
}

struct SchoolPeopleTeachersContext: Encodable {
    //Teacher
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
}

struct SchoolPeopleParentsContext: Encodable {
    //Parent
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
}

//End People
