//
//  SchoolPeopleController.swift
//  App
//
//  Created by Rujira Petrung on 1/5/20.
//

import Vapor
import Leaf

struct SchoolPeopleWebsiteController: RouteCollection {
    
    func boot(router: Router) throws {
        
        //School
        //School People - Overview
        router.get("school-people-overview", use: schoolPeopleOverviewHandler)
        
        router.get("school-people-teachers", use: schoolPeopleTeachersHandler)
        
        router.get("school-people-students", use: schoolPeopleStudentsHandler)
        
        router.get("school-people-parents", use: schoolPeopleParentsHandler)
        
    }
    
    //MARK: - School People Overview
    
    //Overview
    func schoolPeopleOverviewHandler(_ req: Request) throws -> Future<View> {
        let userLoggedIn = try req.isAuthenticated(User.self)
        let context = SchoolPeopleOverviewContext(pretitle: "School", title: "School's People", viewTag: 221, userLoggedIn: userLoggedIn)
        
        return try req.view().render("school-people-overview", context)
    }
    
    //Teachers
    func schoolPeopleTeachersHandler(_ req: Request) throws -> Future<View> {
        let userLoggedIn = try req.isAuthenticated(User.self)
        let context = SchoolPeopleTeachersContext(pretitle: "School", title: "School's People", viewTag: 222, userLoggedIn: userLoggedIn)
        
        return try req.view().render("school-people-teachers", context)
    }
    
    //Students
    func schoolPeopleStudentsHandler(_ req: Request) throws -> Future<View> {
        let userLoggedIn = try req.isAuthenticated(User.self)
        let context = SchoolPeopleStudentsContext(pretitle: "School", title: "School's People", viewTag: 223, userLoggedIn: userLoggedIn)
        
        return try req.view().render("school-people-students", context)
    }
    
    //Parent
    func schoolPeopleParentsHandler(_ req: Request) throws ->
        Future<View> {
        let userLoggedIn = try req.isAuthenticated(User.self)
        let context = SchollPeopleParentsContext(pretitle: "School", title: "School's People", viewTag: 224, userLoggedIn: userLoggedIn)
        
        return try req.view().render("school-people-parents", context)
    }
    
}


