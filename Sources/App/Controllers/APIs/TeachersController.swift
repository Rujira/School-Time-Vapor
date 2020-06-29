//
//  TeachersController.swift
//  App
//
//  Created by Rujira Petrung on 28/5/20.
//

import Vapor
import Fluent

struct TeachersController: RouteCollection {
    
    func boot(router: Router) throws{
        
        let teachersRoutes = router.grouped("api", "teachers")
        teachersRoutes.get(use: getAllHandler)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = teachersRoutes.grouped(
        tokenAuthMiddleware,guardAuthMiddleware)
        
       // tokenAuthGroup.get(use: getAllHandler)
        tokenAuthGroup.post(Teacher.self, use: createHandler)
        tokenAuthGroup.get(Teacher.parameter, use: getHandler)
        tokenAuthGroup.put(Teacher.parameter, use: updateHandler)
        tokenAuthGroup.delete(Teacher.parameter, use: deleteHandler)
        tokenAuthGroup.get("search", use: searchHandler)
        tokenAuthGroup.get("first", use: getFirstHandler)
        tokenAuthGroup.get("sorted", use: sortedHandler)
        
        tokenAuthGroup.get(Teacher.parameter, "rooms", use: getAcronymsHandler)
    }
    //Create (POST)
    func createHandler(_ req: Request, teacher: Teacher) throws -> Future<Teacher> {

        return teacher.save(on: req)
    }
    
    //Retrieve All (GET)
    func getAllHandler(_ req: Request) throws -> Future<[Teacher]> {
        return Teacher.query(on: req).all()
    }
    
    //Get Single (POST)
    func getHandler(_ req: Request) throws -> Future<Teacher> {
        return try req.parameters.next(Teacher.self)
    }
    
    //Update Single (PUT)
    func updateHandler(_ req: Request) throws -> Future<Teacher> {
        return try flatMap(
            to: Teacher.self,
            req.parameters.next(Teacher.self),
            req.content.decode(Teacher.self)
        ) { teacher, updatedTeacher in
            teacher.firstName = updatedTeacher.firstName
            teacher.lastName = updatedTeacher.lastName
            return teacher.save(on: req)
        }
    }
    
    //Delete Single (DELETE)
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req
        .parameters
        .next(Teacher.self)
        .delete(on: req)
        .transform(to: .noContent)
    }
    
    //Search (GET)
    func searchHandler(_ req: Request) throws -> Future<[Teacher]> {
        guard let searchTerm = req
        .query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Teacher.query(on: req).group(.or) { or in
            or.filter(\.firstName == searchTerm)
        }.all()
    }
    
    //Get First (GET)
    func getFirstHandler(_ req: Request) throws -> Future<Teacher> {
        return Teacher.query(on: req)
        .first()
        .unwrap(or: Abort(.notFound))
    }
    
    //Sort ascd (GET)
    func sortedHandler(_ req: Request) throws -> Future<[Teacher]> {
        return Teacher.query(on: req).sort(\.teacherID, .ascending).all()
    }
        
    //Sibling Relationship Teacher - Room
    func getAcronymsHandler(_ req: Request) throws -> Future<[Room]> {
        
        return try req.parameters.next(Teacher.self)
            .flatMap(to: [Room].self) { teacher in
                try teacher.rooms.query(on: req).all()
        }
    }
    
}
