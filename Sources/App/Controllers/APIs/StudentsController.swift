//
//  UsersController.swift
//  App
//
//  Created by Rujira Petrung on 13/4/20.
//

import Vapor
import Fluent

struct StudentsController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let studentsRoutes = router.grouped("api", "students")
        
        //Generic APIs
        studentsRoutes.get(use: getAllHandler)
        studentsRoutes.post(Student.self, use: createHandler)
        studentsRoutes.get(Student.parameter, use: getHandler)
        studentsRoutes.put(Student.parameter, use: updateHandler)
        studentsRoutes.delete(Student.parameter, use: deleteHandler)
        studentsRoutes.get("search", use: searchHandler)
        studentsRoutes.get("first", use: getFirstHandler)
        studentsRoutes.get("sorted", use: sortedHandler)
        
        //Parent-Child Relationships APIs
        studentsRoutes.get(Student.parameter, "room", use: getRoomHandler)
    }
    
    //Create (POST)
    func createHandler(_ req: Request, student: Student) throws -> Future<Student> {

        return student.save(on: req)
    }
    
    //Retrieve All (GET)
    func getAllHandler(_ req: Request) throws -> Future<[Student]> {
        return Student.query(on: req).all()
    }
    
    //Get Single (POST)
    func getHandler(_ req: Request) throws -> Future<Student> {
        return try req.parameters.next(Student.self)
    }
    
    //Update Single (PUT)
    func updateHandler(_ req: Request) throws -> Future<Student> {
        return try flatMap(
            to: Student.self,
            req.parameters.next(Student.self),
            req.content.decode(Student.self)
        ) { student, updatedStudent in
            student.firstName = updatedStudent.firstName
            student.lastName = updatedStudent.lastName
            student.roomID = updatedStudent.roomID
            return student.save(on: req)
        }
    }
    
    //Delete Single (DELETE)
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req
        .parameters
        .next(Student.self)
        .delete(on: req)
        .transform(to: .noContent)
    }
    
    //Search (GET)
    func searchHandler(_ req: Request) throws -> Future<[Student]> {
        guard let searchTerm = req
        .query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Student.query(on: req).group(.or) { or in
            or.filter(\.firstName == searchTerm)
            or.filter(\.lastName == searchTerm)
        }.all()
    }
    
    //Get First (GET)
    func getFirstHandler(_ req: Request) throws -> Future<Student> {
        return Student.query(on: req)
        .first()
        .unwrap(or: Abort(.notFound))
    }
    
    //Sort ascd (GET)
    func sortedHandler(_ req: Request) throws -> Future<[Student]> {
        return Student.query(on: req).sort(\.firstName, .ascending).all()
    }
    
    //Parent-Child Relationships Room-Student
    func getRoomHandler(_ req: Request) throws -> Future<Room> {
        
        return try req
            .parameters.next(Student.self)
            .flatMap(to: Room.self) { student in
                student.room.get(on: req)
        }
    }
}

 
