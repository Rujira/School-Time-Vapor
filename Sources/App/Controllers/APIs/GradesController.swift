//
//  GradesController.swift
//  App
//
//  Created by Rujira Petrung on 15/4/20.
//

import Vapor
import Fluent

struct GradesController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let gradesRoutes = router.grouped("api", "grades")
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = gradesRoutes.grouped(
        tokenAuthMiddleware,guardAuthMiddleware)
        tokenAuthGroup.post(Grade.self, use: createHandler)
        
        tokenAuthGroup.get(use: getAllHandler)
        tokenAuthGroup.post(Grade.self, use: createHandler)
        tokenAuthGroup.get(Grade.parameter, use: getHandler)
        tokenAuthGroup.put(Grade.parameter, use: updateHandler)
        tokenAuthGroup.delete(Grade.parameter, use: deleteHandler)
        
        //Parent-Child Relationships APIs
        // Grade-Room
        tokenAuthGroup.get(Grade.parameter, "rooms", use: getRoomsHandler)
        
        // School-Grade
        tokenAuthGroup.get(Grade.parameter, "school", use: getSchoolHandler)
        
        // School-Grade Nested
        tokenAuthGroup.get("rooms", use: getAllGradesWithRooms)
        
        tokenAuthGroup.delete(Grade.parameter, "force", use: forceDeleteHandler)
    }
    
    //Create (POST)
    func createHandler(_ req: Request, grade: Grade) throws -> Future<Grade> {
        
        return grade.save(on: req)
    }
    
    //Retrieve All (GET)
    func getAllHandler(_ req: Request) throws -> Future<[Grade]> {
        return Grade.query(on: req).all()
    }
    
    //Get Single (POST)
    func getHandler(_ req: Request) throws -> Future<Grade> {
        return try req.parameters.next(Grade.self)
    }
    
    //Update Single (PUT)
    func updateHandler(_ req: Request) throws -> Future<Grade> {
        return try flatMap(
            to: Grade.self,
            req.parameters.next(Grade.self),
            req.content.decode(Grade.self)
        ) { grade, updatedGrade in
            grade.name = updatedGrade.name
            grade.gradeType = updatedGrade.gradeType
            grade.schoolID = updatedGrade.schoolID
            grade.createBy = updatedGrade.createBy
            grade.updateBy = updatedGrade.updateBy
            return grade.save(on: req)
        }
    }
    
    //Delete Single (DELETE)
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req
            .parameters
            .next(Grade.self)
            .delete(on: req)
            .transform(to: .noContent)
    }
    
    //Search (GET)
    func searchHandler(_ req: Request) throws -> Future<[Grade]> {
        guard let searchTerm = req
            .query[String.self, at: "term"] else {
                throw Abort(.badRequest)
        }
        return Grade.query(on: req).group(.or) { or in
            or.filter(\.name == searchTerm)
        }.all()
    }
    
    //Get First (GET)
    func getFirstHandler(_ req: Request) throws -> Future<Grade> {
        return Grade.query(on: req)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    
    //Sort ascd (GET)
    func sortedHandler(_ req: Request) throws -> Future<[Grade]> {
        return Grade.query(on: req).sort(\.name, .ascending).all()
    }
    
    //Child-Parent Relationships Grade-Room
    func getRoomsHandler(_ req: Request) throws -> Future<[Room]> {
        return try req
            .parameters.next(Grade.self)
            .flatMap(to: [Room].self) { grade in
                try grade.rooms.query(on: req).all()
        }
    }
    
    //Parent-Child Relationships School-Grade
    func getSchoolHandler(_ req: Request) throws -> Future<School> {
        return try req
            .parameters.next(Grade.self)
            .flatMap(to: School.self) { grade in
                grade.school.get(on: req)
        }
    }
    
    //Nested Grade-Room
    func getAllGradesWithRooms(_ req: Request) throws -> Future<[GradeWithRooms]> {
        return Grade.query(on: req)
            .all()
            .flatMap(to: [GradeWithRooms].self) { grades in
                try grades.map { grade in
                    try grade.rooms.query(on: req)
                        .all()
                        .map { rooms in
                            
                            GradeWithRooms(id: grade.id,
                                           name: grade.name,
                                           schoolID: grade.schoolID,
                                           gradeType: grade.gradeType,
                                           updateBy: grade.createBy,
                                           updateAt: grade.createAt,
                                           rooms: rooms)
                    }
                    
                }.flatten(on: req)
        }
    }
    
    func forceDeleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters
            .next(Grade.self)
            .flatMap(to: HTTPStatus.self) { grade in
                grade.delete(force: true, on: req)
                    .transform(to: .noContent)
        }
    }
    
}




