//
//  SchoolClassroomsAndSubjectsWebsiteController.swift
//  App
//
//  Created by Rujira Petrung on 30/6/20.
//

import Vapor
import Leaf
import Authentication

struct SchoolClassesWebsiteController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
        let protectedRoutes = authSessionRoutes.grouped(RedirectMiddleware<User>(path: "/login"))
        
        //School Classes - Overview
        protectedRoutes.get("school-classes-overview", School.parameter, use: schoolClassesOverviewHandler)
        
        //School Classes - Classrooms
        protectedRoutes.get("school-classes-classrooms", School.parameter, use: schoolClassesClassroomsHandler)
        
        
        //School Classes - Subjects
        protectedRoutes.get("school-classes-subjects", School.parameter, use: schoolClassesSubjectsHandler)
        protectedRoutes.get("school-classes-subjects", School.parameter, Subject.parameter, "view" , use: viewSubjectHandler)
        protectedRoutes.get("school-classes-subjects", School.parameter, "create", use: createSubjectHandler)
        protectedRoutes.post(Subject.self, at: "school-classes-subjects", School.parameter, "create", use: createSubjectPostHandler)
        protectedRoutes.get("school-classes-subjects", School.parameter, Subject.parameter, "edit", use: editSubjectHandler)
        protectedRoutes.post("school-classes-subjects", School.parameter, Subject.parameter, "edit", use: editSubjectPostHandler)
        protectedRoutes.post("school-classes-subjects", School.parameter, Subject.parameter, "delete", use: deleteSubjectHandler)
        
        //School Classes - Lessons
        protectedRoutes.get("school-classes-lessons", School.parameter, Subject.parameter, "create", use: createLessonHandler)
        protectedRoutes.post(Lesson.self, at: "school-classes-lessons", School.parameter, Subject.parameter, "create", use: createLessonPostHandler)
        protectedRoutes.get("school-classes-lessons", School.parameter, Subject.parameter, Lesson.parameter, "edit", use: editLessonHandler)
        protectedRoutes.post("school-classes-lessons", School.parameter, Subject.parameter, Lesson.parameter, "edit", use: editLessonPostHandler)
        
        protectedRoutes.post("school-classes-lessons", School.parameter, Subject.parameter, Lesson.parameter,"delete", use: deleteLessonHandler)
        
    
        
    }
    
    //MARK: - Overview
    //Overview
    
    func schoolClassesOverviewHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self).flatMap(to: View.self) { school in
            
            let userLoggedIn = try req.isAuthenticated(User.self)
            let context = SchoolClassesOverviewContext(
                pretitle: "School",
                title: "School Classes",
                viewTag: 231,
                userLoggedIn: userLoggedIn,
                selectedSchool: school)
            
            return try req.view().render("school-classes-overview", context)
        }
    }
    
    //MARK: - Classrooms
    //Classrooms
    
    func schoolClassesClassroomsHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                let context = SchoolClassesClassroomsContext(
                    pretitle: "School",
                    title: "School Classes",
                    viewTag: 232,
                    userLoggedIn: userLoggedIn,
                    selectedSchool: school)
            
                return try req.view().render("school-classes-classrooms", context)
        }
    }
    
    //MARK: - Subjects
    //Subjects
    
    func schoolClassesSubjectsHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let subjects = Subject.query(on: req)
                    .filter(\.schoolID == school.id!)
                    .sort(\.category, .ascending).all()
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                let context = SchoolClassesSubjectsContext(
                    pretitle: "School",
                    title: "School Classes",
                    viewTag: 233,
                    userLoggedIn: userLoggedIn,
                    selectedSchool: school,
                    subjects: subjects)
                
                return try req.view().render("school-classes-subjects", context)
        }
    }
    
    func viewSubjectHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                
                return try req.parameters.next(Subject.self)
                    .flatMap(to: View.self) { subject in
                        
                        let lessons = Lesson.query(on: req)
                            .filter(\.subjectID == subject.id!)
                            .sort(\.lessonNumber, .ascending).all()
                        
                        let context = SchoolClassesSubjectDetailContext(
                            pretitle: "Subject Detail",
                            title: subject.name,
                            viewTag: 233,
                            userLoggedIn: userLoggedIn,
                            selectedSchool: school,
                            subject: subject,
                            lessons: lessons)
                        
                        return try req.view().render("school-classes-subjects-detail", context)
                        
                }
        }
    }
    
    func createSubjectHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                let user = try req.requireAuthenticated(User.self)
                
                let context = CreateSubjectContext(
                    pretitle: "New Subject",
                    title: "Add New Subject",
                    viewTag: 233,
                    userLoggedIn: userLoggedIn,
                    selectedSchool: school,
                    createBy: user.name,
                    updateBy: user.name,
                    categories: DepartmentType.allCases,
                    subjectLevels: SubjectLevel.allCases)
                
                return try req.view().render("school-classes-subjects-create", context)
                
        }
    }
    
    func createSubjectPostHandler(_ req: Request, subject: Subject) throws -> Future<Response> {
        
        return try req.parameters.next(School.self).flatMap(to: Response.self) { school in
            
            return subject.save(on: req).map(to: Response.self) { subject in
                guard subject.id != nil else {
                    throw Abort(.internalServerError)
                }
                return req.redirect(to: "/school-classes-subjects/\(school.id!)")
            }
        }
    }
    
    func editSubjectHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                let user = try req.requireAuthenticated(User.self)
                
                return try req.parameters.next(Subject.self)
                    .flatMap(to: View.self) { subject in
                        let context = EditSubjectContext(
                            pretitle: "Edit Subject",
                            title: "Edit Existing Subject",
                            viewTag: 233,
                            userLoggedIn: userLoggedIn,
                            selectedSchool: school,
                            createBy: subject.createBy,
                            updateBy: user.name,
                            categories: DepartmentType.allCases,
                            subjectLevels: SubjectLevel.allCases,
                            subject: subject)
                        
                        return try req.view().render("school-classes-subjects-create", context)
                }
                
        }
    }
    
    func editSubjectPostHandler(_ req: Request) throws -> Future<Response> {
        
        return try flatMap(to: Response.self,
                           req.parameters.next(School.self),
                           req.parameters.next(Subject.self),
                           req.content.decode(Subject.self)
        ) { school, subject, data in
            subject.name = data.name
            subject.subjectID = data.subjectID
            subject.description = data.description
            subject.category = data.category
            subject.subjectLevel = data.subjectLevel
            subject.createBy = data.createBy
            subject.updateBy = data.updateBy
            
            guard subject.id != nil else {
                throw Abort(.internalServerError)
            }
            let redirect = req.redirect(to: "/school-classes-subjects/\(school.id!)")
            return subject.save(on: req).transform(to: redirect)
        }
    }
    
    func deleteSubjectHandler(_ req: Request) throws -> Future<Response> {
        
        return try req.parameters.next(School.self).flatMap(to: Response.self) { school in
            
            return try req.parameters.next(Subject.self).delete(on: req)
            .transform(to: req.redirect(to: "/school-classes-subjects/\(school.id!)"))
        }
    }
    
    //MARK: - Lessons
    //Lessons
    
    func createLessonHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                return try req.parameters.next(Subject.self)
                    .flatMap(to: View.self) { subject in
                        
                        let userLoggedIn = try req.isAuthenticated(User.self)
                        let user = try req.requireAuthenticated(User.self)
                        
                        let context = CreateLessonContext(
                                          pretitle: "Create Lesson",
                                          title: "Create New Lessons",
                                          viewTag: 233,
                                          userLoggedIn: userLoggedIn,
                                          selectedSchool: school,
                                          selectedSubject: subject,
                                          createBy: user.name,
                                          updateBy: user.name)
                                      
                                      return try req.view().render("school-classes-lessons-create", context)
                        
                }
                
        }
    }
    
    //Create Lessons
    func createLessonPostHandler(_ req: Request, lesson: Lesson) throws -> Future<Response> {
        
        return try req.parameters.next(School.self).flatMap(to: Response.self) { school in
            
            return try req.parameters.next(Subject.self).flatMap(to: Response.self) { subject in
                
                return lesson.save(on: req).map(to: Response.self) { lesson in

                    guard lesson.id != nil else {
                        throw Abort(.internalServerError)
                    }
                    return req.redirect(to: "/school-classes-subjects/\(school.id!)/\(subject.id!)/view")
                }
            }
            
        }
    }
    
    //Edit Lessons
    func editLessonHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
            
            return try req.parameters.next(Subject.self)
                .flatMap(to: View.self) { subject in
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                let user = try req.requireAuthenticated(User.self)
                
                return try req.parameters.next(Lesson.self)
                    .flatMap(to: View.self) { lesson in
                        
                        let context = EditLessonContext(
                            pretitle: "Edit Lesson",
                            title: "Edit Existing Lesson",
                            viewTag: 233,
                            userLoggedIn: userLoggedIn,
                            selectedSchool: school,
                            selectedSubject: subject,
                            createBy: lesson.createBy,
                            updateBy: user.name,
                            lesson: lesson)
                        
                        return try req.view().render("school-classes-lessons-create", context)
                }
            }
        }
    }
    
    func editLessonPostHandler(_ req: Request) throws -> Future<Response> {
        
        return try flatMap(to: Response.self,
                           req.parameters.next(School.self),
                           req.parameters.next(Subject.self),
                           req.parameters.next(Lesson.self),
                           req.content.decode(Lesson.self)
        ) { school, subject, lesson, data in
            
            lesson.lessonName = data.lessonName
            lesson.lessonNumber = data.lessonNumber
            lesson.lessonDescription = data.lessonDescription
            lesson.createBy = data.createBy
            lesson.updateBy = data.updateBy
            
            guard lesson.id != nil else {
                throw Abort(.internalServerError)
            }
            
            let redirect = req.redirect(to: "/school-classes-subjects/\(school.id!)/\(subject.id!)/view")
            return lesson.save(on: req).transform(to: redirect)
                           
        }
    }
    
    //Delete Lessons
    func deleteLessonHandler(_ req: Request) throws -> Future<Response> {
        
        return try req.parameters.next(School.self).flatMap(to: Response.self) { school in
        
            return try req.parameters.next(Subject.self).flatMap(to: Response.self) { subject in
                
                return try req.parameters.next(Lesson.self).delete(on: req)
                    .transform(to: req.redirect(to: "/school-classes-subjects/\(school.id!)/\(subject.id!)/view"))
            }
        }
    }
    
    
}
