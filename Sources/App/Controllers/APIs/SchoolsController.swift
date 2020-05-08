//
//  SchoolsController.swift
//  App
//
//  Created by Rujira Petrung on 15/4/20.
//

import Vapor
import Fluent
import Authentication

struct SchoolsController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let schoolsRoutes = router.grouped("api", "schools")
        
        schoolsRoutes.get(use: getAllHandler)
        //schoolsRoutes.post(School.self, use: createHandler)
        schoolsRoutes.get(School.parameter, use: getHandler)
        
        //Parent-Child Relationships APIs
        //School-Grade
        schoolsRoutes.get(School.parameter, "grades", use: getGradesHandler)
        
        //User-School
        schoolsRoutes.get(School.parameter, "user", use: getUserHandler)
        
        //Authentication + Using Token
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        
        let tokenAuthGroup = schoolsRoutes.grouped(
        tokenAuthMiddleware,
        guardAuthMiddleware)
        tokenAuthGroup.post(SchoolCreateData.self, use: createHandler)
        tokenAuthGroup.delete(School.parameter, use: deleteHandler)
        tokenAuthGroup.put(School.parameter, use: updateHandler)
    }
    
    //Create (POST)
    func createHandler(_ req: Request, data: SchoolCreateData) throws -> Future<School> {
        
        let user = try req.requireAuthenticated(User.self)
        let school = try School(name: data.name, userID: user.requireID())
        
        return school.save(on: req)
    }
    
    //Retrieve All (GET)
    func getAllHandler(_ req: Request) throws -> Future<[School]> {
        return School.query(on: req).all()
    }
    
    //Get Single (POST)
    func getHandler(_ req: Request) throws -> Future<School> {
        return try req.parameters.next(School.self)
    }
    
    //Update Single (PUT)
    func updateHandler(_ req: Request) throws -> Future<School> {
        return try flatMap(
            to: School.self,
            req.parameters.next(School.self), req.content.decode(SchoolCreateData.self)
        ) { school, updatedSchool in
            school.name = updatedSchool.name
            
            let user = try req.requireAuthenticated(User.self)
            school.userID = try user.requireID()
            
            return school.save(on: req)
        }
    }
    
    //Delete Single (DELETE)
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req
        .parameters
        .next(School.self)
        .delete(on: req)
        .transform(to: .noContent)
    }
    
    //Child-Parent Relationships School-Grade
    
    func getGradesHandler(_ req: Request) throws -> Future<[Grade]> {
        return try req
            .parameters.next(School.self)
            .flatMap(to: [Grade].self) { school in
                try school.grades.query(on: req).all()
        }
    }
    
    func getUserHandler(_ req: Request) throws -> Future<User.Public> {
        return try req
            .parameters.next(School.self)
            .flatMap(to: User.Public.self) { school in
                school.user.get(on: req).convertToPublic()
        }
    }
}

struct SchoolCreateData: Content {
    let name: String
}

