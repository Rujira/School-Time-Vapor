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
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = studentsRoutes.grouped(
        tokenAuthMiddleware,guardAuthMiddleware)
        
        //Generic APIs
        tokenAuthGroup.get(use: getAllHandler)
        tokenAuthGroup.post(Student.self, use: createHandler)
        tokenAuthGroup.get(Student.parameter, use: getHandler)
        tokenAuthGroup.put(Student.parameter, use: updateHandler)
        tokenAuthGroup.delete(Student.parameter, use: deleteHandler)
        tokenAuthGroup.get("search", use: searchHandler)
        tokenAuthGroup.get("first", use: getFirstHandler)
        tokenAuthGroup.get("sorted", use: sortedHandler)
        
        //Parent-Child Relationships APIs
        tokenAuthGroup.get(Student.parameter, "room", use: getRoomHandler)
        
        tokenAuthGroup.get("rooms", use: getStudentsWithRoom)
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

    func getStudentsWithRoom(_ req: Request) throws -> Future<[StudentsWithRoom]> {
        
        return Student.query(on: req)
            .join(\Room.id, to: \Student.roomID)
            .alsoDecode(Room.self).all()
            .map(to: [StudentsWithRoom].self) {
                studentRoomPairs in
                 
                studentRoomPairs.map { student, room -> StudentsWithRoom in
                
                    
                    return StudentsWithRoom(id: student.id,
                                     studentID: student.studentID,
                                     firstName: student.firstName,
                                     lastName: student.lastName,
                                     genderType: student.genderType,
                                     birthDate: student.birthDate,
                                     age: student.getAgeFromDOF(date: student.birthDate ?? "") ,
                                     createBy: student.createBy,
                                     createAt: student.createAt, room: room.name)
                }
        }
    }
    
    
}

 
