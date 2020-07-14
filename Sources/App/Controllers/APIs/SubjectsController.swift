//
//  SubjectsController.swift
//  App
//
//  Created by Rujira Petrung on 2/7/20.
//

import Vapor
import Fluent

struct SubjectsController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let subjectsRoutes = router.grouped("api", "subjects")
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = subjectsRoutes.grouped(
        tokenAuthMiddleware,guardAuthMiddleware)
        
        tokenAuthGroup.get(use: getAllHandler)
        tokenAuthGroup.post(Subject.self, use: createHandler)
        tokenAuthGroup.get(Subject.parameter, use: getHandler)
        tokenAuthGroup.put(Subject.parameter, use: updateHandler)
        tokenAuthGroup.delete(Subject.parameter, use: deleteHandler)
        
    }
    
    //Create (POST)
    func createHandler(_ req: Request, subject: Subject) throws -> Future<Subject> {
        
        return subject.save(on: req)
    }
    
    //Retrieve All (GET)
    func getAllHandler(_ req: Request) throws -> Future<[Subject]> {
        return Subject.query(on: req).all()
    }
    
    //Get Single (POST)
    func getHandler(_ req: Request) throws -> Future<Subject> {
        return try req.parameters.next(Subject.self)
    }
    
    //Update Single (PUT)
    func updateHandler(_ req: Request) throws -> Future<Subject> {
        return try flatMap(
            to: Subject.self,
            req.parameters.next(Subject.self), req.content.decode(Subject.self)
        ) { subject, updatedSubject in
            subject.name = updatedSubject.name
            //Other Properties
            
            return subject.save(on: req)
        }
    }
    
    //Delete Single (DELETE)
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req
            .parameters
            .next(Subject.self)
            .delete(on: req)
            .transform(to: .noContent)
    }
}
