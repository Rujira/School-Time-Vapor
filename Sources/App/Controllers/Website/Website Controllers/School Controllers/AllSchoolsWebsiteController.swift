//
//  AllSchoolsWebsiteController.swift
//  App
//
//  Created by Rujira Petrung on 5/5/20.
//

import Foundation
import Vapor
import Leaf
import Authentication

struct AllSchoolsWebsiteController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
        
        let protectedRoutes = authSessionRoutes.grouped(RedirectMiddleware<User>(path: "/login"))
        
        authSessionRoutes.get("login", use: loginHandler)
        authSessionRoutes.post(LoginPostData.self, at: "login", use: loginPostHandler)
        authSessionRoutes.post("logout", use: logoutHandler)
        protectedRoutes.get(use: indexHandler)
        protectedRoutes.post(SchoolCreateData.self, use: createSchoolPostHandler)
 
    }
    
    //Index Page Handler Overview
    func indexHandler(_ req: Request) throws -> Future<View> {
       
        //let user = try req.requireAuthenticated(User.self)
        
        let schools = School.query(on: req).all()
        
        let userLoggedIn = try req.isAuthenticated(User.self)
        
        let showCookieMessage = req.http.cookies["cookies-accepted"] == nil
        
        let context = IndexContext(
            pretitle: "School",
            title: "All Schools",
            userLoggedIn: userLoggedIn,
            showCookieMessage: showCookieMessage,
            schools: schools)
        
        return try req.view().render("index", context)
    }
    
    func loginHandler(_ req: Request) throws -> Future<View> {
        
        let context: LoginContext
        if req.query[Bool.self, at: "error"] != nil {
            context = LoginContext(loginError: true)
        } else {
            context = LoginContext()
        }
        
        return try req.view().render("login", context)
    }
    
    func loginPostHandler(_ req: Request, userData: LoginPostData) throws -> Future<Response> {
        
        return User.authenticate(
            username: userData.username,
            password: userData.password,
            using: BCryptDigest(),
            on: req).map(to: Response.self) { user in
                guard let user = user else {
                    return req.redirect(to: "/login?error")
                }
                try req.authenticateSession(user)
                return req.redirect(to: "/")
        }
    }
    
    func logoutHandler(_ req: Request) throws -> Response {
        try req.unauthenticateSession(User.self)
        return req.redirect(to: "/")
    }
    
    func createSchoolPostHandler(_ req: Request, data: SchoolCreateData) throws -> Future<Response> {
        
        let user = try req.requireAuthenticated(User.self)
        
        let school = try School(name: data.name, userID: user.requireID())
        
        return school.save(on: req).map(to: Response.self) { school in
            guard school.id != nil else {
                throw Abort(.internalServerError)
            }
            return req.redirect(to: "/")
        }
    }
}
