//
//  RoomsController.swift
//  App
//
//  Created by Rujira Petrung on 15/4/20.
//

import Vapor
import Fluent

struct RoomsController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let roomsRoutes = router.grouped("api", "rooms")
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = roomsRoutes.grouped(
        tokenAuthMiddleware,guardAuthMiddleware)
        
        tokenAuthGroup.get(use: getAllHandler)
        tokenAuthGroup.post(Room.self, use: createHandler)
        tokenAuthGroup.get(Room.parameter, use: getHandler)
        tokenAuthGroup.put(Room.parameter, use: updateHandler)
        tokenAuthGroup.delete(Room.parameter, use: deleteHandler)
        
        //Parent-Child Relationships APIs
        // Room-Student
        tokenAuthGroup.get(User.parameter, "students", use: getStudentsHandler)
        // Grade-Room
        tokenAuthGroup.get(Room.parameter, "grade", use: getGradeHandler)
        
        // Room-Student Nested
        tokenAuthGroup.get("students", use: getAllRoomsWithStudents)
        
        //Joins
        tokenAuthGroup.get("grades", use: getRoomsWithGrade)
        
        //Sibling
        tokenAuthGroup.post(Room.parameter, "teachers", Teacher.parameter, use: addTeachersHandler)
        tokenAuthGroup.get(Room.parameter, "teachers", use: getTeachersHandler)
        tokenAuthGroup.delete(Room.parameter, "teachers", Teacher.parameter, use: removeTeachersHandler)
    }
    
    //Create (POST)
    func createHandler(_ req: Request, room: Room) throws -> Future<Room> {
        
        return room.save(on: req)
    }
    
    //Retrieve All (GET)
    func getAllHandler(_ req: Request) throws -> Future<[Room]> {
        return Room.query(on: req).all()
    }
    
    //Get Single (POST)
    func getHandler(_ req: Request) throws -> Future<Room> {
        return try req.parameters.next(Room.self)
    }
    
    //Update Single (PUT)
    func updateHandler(_ req: Request) throws -> Future<Room> {
        return try flatMap(
            to: Room.self,
            req.parameters.next(Room.self), req.content.decode(Room.self)
        ) { room, updatedRoom in
            room.name = updatedRoom.name
            room.gradeID = updatedRoom.gradeID
            
            return room.save(on: req)
        }
    }
    
    //Delete Single (DELETE)
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req
            .parameters
            .next(Room.self)
            .delete(on: req)
            .transform(to: .noContent)
    }
    
    
    
    //Child-Parent Relationships Room-Student
    func getStudentsHandler(_ req: Request) throws -> Future<[Student]> {
        
        return try req
            .parameters.next(Room.self)
            .flatMap(to: [Student].self) { room in
                try room.students.query(on: req).all()
        }
    }
    
    //Parent-Child Relationships Grade-Room
    func getGradeHandler(_ req: Request) throws -> Future<Grade> {
        return try req
            .parameters.next(Room.self)
            .flatMap(to: Grade.self) { room in
                room.grade.get(on: req)
        }
    }
    
    //Nested Room-Student
    func getAllRoomsWithStudents(_ req: Request) throws -> Future<[RoomWithStudents]> {
        return Room.query(on: req)
            .all()
            .flatMap(to: [RoomWithStudents].self) { rooms in
                try rooms.map { room in
                    try room.students.query(on: req)
                        .all()
                        .map { students in
                            RoomWithStudents(id: room.id,
                                             name: room.name,
                                             gradeID: room.gradeID,
                                             numberOfSeats: room.numberOfSeats,
                                             createBy: room.createBy,
                                             updateBy: room.updateBy,
                                             createAt: room.createAt,
                                             updateAt: room.updateAt,
                                             students: students,
                                             studentsSeatsPercentage: (students.count * 100) / room.numberOfSeats)
                    }
                }.flatten(on: req)
        }
        
    }
    
    //Join Grade-Room
    func getRoomsWithGrade(_ req: Request)throws -> Future<[RoomsWithGrade]> {
        
        return Room.query(on: req)
            
            .join(\Grade.id, to: \Room.gradeID)
            .alsoDecode(Grade.self).all()
            .map(to: [RoomsWithGrade].self) {
                roomGradePairs in
                
                roomGradePairs.map { room, grade -> RoomsWithGrade in
                    RoomsWithGrade(id: room.id, name: room.name, grade: grade)
                }
        }
    }
    
    //Sibling Relationships Room-Teacher
    
    func addTeachersHandler(_ req: Request) throws -> Future<HTTPStatus> {
        
        return try flatMap(to: HTTPStatus.self,
                           req.parameters.next(Room.self),
                           req.parameters.next(Teacher.self)) { room, teacher in
                            
                            return room.teachers.attach(teacher, on: req)
                                .transform(to: .created)
        }
    }
    
    //Sibling Relationships Room-Teacher Query
    
    func getTeachersHandler(_ req: Request) throws -> Future<[Teacher]> {
        return try req.parameters.next(Room.self)
            .flatMap(to: [Teacher].self) { room in
                try room.teachers.query(on: req).all()
        }
    }
    
    //Removing Relationship
    
    func removeTeachersHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self,
                           req.parameters.next(Room.self),
                           req.parameters.next(Teacher.self)) { room, teacher in
                            return room.teachers.detach(teacher, on: req)
                                .transform(to: .noContent)
                            
        }
    }
    
    
}

