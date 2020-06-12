//
//  UsersController.swift
//  App
//
//  Created by Rujira Petrung on 15/4/20.
//

import Vapor
import Fluent
import Crypto

struct UsersController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let usersRoute = router.grouped("api", "users")
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        
        basicAuthGroup.post("login", use: loginHandler)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        tokenAuthGroup.get(use: getAllHandler)
        tokenAuthGroup.get(User.parameter, use: getHandler)
        
        tokenAuthGroup.get(User.parameter, "schools",  use: getSchoolsHandler)
        tokenAuthGroup.post(User.self, use: createHandler)
    }
    
    //Create User (POST)
    func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req).convertToPublic()
    }
    
    //Get All Users (GET)
    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(data: User.Public.self).all()
    }
    
    //Get Single User (GET)
    func getHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).convertToPublic()
    }
    // Parent-Child (GET)
    func getSchoolsHandler(_ req: Request) throws -> Future<[School]> {
        
        return try req
            .parameters.next(User.self)
            .flatMap(to: [School].self) {user in
                try user.schools.query(on: req).all()
        }
    }
    
    //Login
    func loginHandler(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
}
