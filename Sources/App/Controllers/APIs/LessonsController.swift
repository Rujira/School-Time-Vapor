//
//  LessonsController.swift
//  App
//
//  Created by Rujira Petrung on 9/7/20.
//

import Vapor
import Fluent

struct LessonsController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let lessonsRoutes = router.grouped("api", "lessons")
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = lessonsRoutes.grouped(
        tokenAuthMiddleware,guardAuthMiddleware)
        
        tokenAuthGroup.get(use: getAllHandler)
        tokenAuthGroup.post(Lesson.self, use: createHandler)
        tokenAuthGroup.get(Lesson.parameter, use: getHandler)
        tokenAuthGroup.put(Lesson.parameter, use: updateHandler)
        tokenAuthGroup.delete(Lesson.parameter, use: deleteHandler)
        
         tokenAuthGroup.get(Lesson.parameter, "subject", use: getSubjectHandler)
        
        
    }
    
    //Create (POST)
    func createHandler(_ req: Request, lesson: Lesson) throws -> Future<Lesson> {
        
        return lesson.save(on: req)
    }
    
    //Retrieve All (GET)
    func getAllHandler(_ req: Request) throws -> Future<[Lesson]> {
        return Lesson.query(on: req).all()
    }
    
    //Get Single (POST)
    func getHandler(_ req: Request) throws -> Future<Lesson> {
        return try req.parameters.next(Lesson.self)
    }
    
    //Update Single (PUT)
    func updateHandler(_ req: Request) throws -> Future<Lesson> {
        return try flatMap(
            to: Lesson.self,
            req.parameters.next(Lesson.self), req.content.decode(Lesson.self)
        ) { lesson, updatedLesson in
            lesson.lessonName = updatedLesson.lessonName
            lesson.lessonNumber = updatedLesson.lessonNumber
            lesson.lessonDescription = updatedLesson.lessonDescription
            lesson.subjectID = updatedLesson.subjectID
            lesson.schoolID = updatedLesson.schoolID
            lesson.createBy = updatedLesson.createBy
            lesson.updateBy = updatedLesson.updateBy
            //Other Properties
            
            return lesson.save(on: req)
        }
    }
    
    //Delete Single (DELETE)
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req
            .parameters
            .next(Lesson.self)
            .delete(on: req)
            .transform(to: .noContent)
    }
    
    //Parent-Child Relationships Subject-Lessons
    func getSubjectHandler(_ req: Request) throws -> Future<Subject> {
        return try req
            .parameters.next(Lesson.self)
            .flatMap(to: Subject.self) { lesson in
                lesson.subject.get(on: req)
        }
    }
}
