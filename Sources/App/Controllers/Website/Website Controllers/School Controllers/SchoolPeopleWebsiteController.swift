//
//  SchoolPeopleController.swift
//  App
//
//  Created by Rujira Petrung on 1/5/20.
//

import Vapor
import Leaf
import Authentication

struct SchoolPeopleWebsiteController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
        let protectedRoutes = authSessionRoutes.grouped(RedirectMiddleware<User>(path: "/login"))
        
        //School
        //School People
        
        
        
        
        
        protectedRoutes.get("school-layout-parents", School.parameter, use: schoolPeopleParentsHandler)
        
    }
    
    //MARK: - School People Overview
    
    

    
    
    
    //Parent
    func schoolPeopleParentsHandler(_ req: Request) throws ->
        Future<View> {
            return try req.parameters.next(School.self)
                .flatMap(to: View.self) { school in
                    let userLoggedIn = try req.isAuthenticated(User.self)
                    let context = SchoolPeopleParentsContext(
                        pretitle: "School",
                        title: "School's Layout",
                        viewTag: 216,
                        userLoggedIn: userLoggedIn,
                        selectedSchool: school)
                    
                    return try req.view().render("school-layout-parents", context)
            }
    }
    
}


