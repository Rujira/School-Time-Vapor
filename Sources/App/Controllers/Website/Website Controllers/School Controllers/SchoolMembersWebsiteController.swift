//
//  SchoolPeopleController.swift
//  App
//
//  Created by Rujira Petrung on 1/5/20.
//

import Vapor
import Leaf
import Authentication

struct SchoolMembersWebsiteController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
        let protectedRoutes = authSessionRoutes.grouped(RedirectMiddleware<User>(path: "/login"))
        
        //School
        //School Members - Overview
        protectedRoutes.get("school-members-overview", School.parameter, use: schoolMemberOverviewHandler)
        
        //School Members - Students
        protectedRoutes.get("school-members-students", School.parameter, use: schoolMembersStudentsHandler)
        protectedRoutes.get("school-members-students", School.parameter, Student.parameter, "view" , use: viewStudentHandler)
        protectedRoutes.get("school-members-students", School.parameter, "create", use: createStudentHandler)
        protectedRoutes.post(Student.self, at: "school-members-students", School.parameter, "create", use: createStudentPostHandler)
        protectedRoutes.get("school-members-students", School.parameter, Student.parameter, "edit", use: editStudentHandler)
        protectedRoutes.post("school-members-students", School.parameter, Student.parameter, "edit", use: editStudentPostHandler)
        protectedRoutes.get("school-members-students", School.parameter, Student.parameter, "addStudentProfilePicture", use: addStudentProfilePictureHandler)
        protectedRoutes.post("school-members-students", School.parameter, Student.parameter, "addStudentProfilePicture", use: addStudentProfilePicturePostHandler)
        authSessionRoutes.get("students", Student.parameter, "profilePicture", use: getStudentsProfilePictureHandler)
        protectedRoutes.post("school-members-students", School.parameter, Student.parameter, "delete", use: deleteStudentHandler)
        
        //School Members - Teachers
        protectedRoutes.get("school-members-teachers", School.parameter, use: schoolMembersTeachersHandler)
        protectedRoutes.get("school-members-teachers", School.parameter, Teacher.parameter, "view", use: viewTeacherHandler)
        protectedRoutes.get("school-members-teachers", School.parameter, "create", use: createTeacherHandler)
        protectedRoutes.post(Teacher.self, at: "school-members-teachers", School.parameter, "create", use: createTeacherPostHandler)
        protectedRoutes.get("school-members-teachers", School.parameter, Teacher.parameter, "edit", use: editTeacherHandler)
        protectedRoutes.post("school-members-teachers", School.parameter, Teacher.parameter, "edit", use: editTeacherPostHandler)
        protectedRoutes.get("school-members-teachers", School.parameter, Teacher.parameter, "addTeacherProfilePicture", use: addTeacherProfilePictureHandler)
        protectedRoutes.post("school-members-teachers", School.parameter, Teacher.parameter, "addTeacherProfilePicture", use: addTeacherProfilePicturePostHandler)
        authSessionRoutes.get("teachers", Teacher.parameter, "profilePicture", use: getTeachersProfilePictureHandler)
        protectedRoutes.post("school-members-teachers", School.parameter, Teacher.parameter, "delete", use: deleteTeacherHandler)
        
        protectedRoutes.get("school-members-parents", School.parameter, use: schoolMembersParentsHandler)
        
    }
    
    func schoolMemberOverviewHandler(_ req: Request) throws ->
        Future<View> {
            return try req.parameters.next(School.self)
                .flatMap(to: View.self) { school in
                    let userLoggedIn = try req.isAuthenticated(User.self)
                    let context = SchoolMembersParentsContext(
                        pretitle: "School",
                        title: "School Members",
                        viewTag: 221,
                        userLoggedIn: userLoggedIn,
                        selectedSchool: school)
                    
                    return try req.view().render("school-members-overview", context)
            }
    }
    
    //MARK: - Students
    //Students
    func schoolMembersStudentsHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let students = Student.query(on: req)
                    .filter(\.schoolID == school.id!)
                    .join(\Room.id, to: \Student.roomID)
                    .sort(\.studentID, .descending)
                    .alsoDecode(Room.self)
                    .all()
                    .map(to: [StudentsWithRoom].self) {
                        studentRoomPairs in
                        
                        studentRoomPairs.map { student, room -> StudentsWithRoom in
                            StudentsWithRoom(id: student.id,
                                             studentID: student.studentID,
                                             firstName: student.firstName,
                                             lastName: student.lastName,
                                             profilePicture : student.profilePicture ?? "",
                                             genderType: student.genderType,
                                             birthDate: student.birthDate,
                                             age: student.getAgeFromDOF(date: student.birthDate ?? ""),
                                             createBy: student.createBy,
                                             createAt: student.createAt,
                                             room: room.name)
                        }
                }
                
                
                let rooms = Room.query(on: req)
                    .filter(\.schoolID == school.id!)
                    .sort(\.name, .ascending).all()
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                
                let context = SchoolMembersStudentsContext(
                    pretitle: school.name,
                    title: "School Members",
                    viewTag: 222,
                    userLoggedIn: userLoggedIn,
                    selectedSchool: school,
                    students: students,
                    rooms: rooms)
                
                return try req.view().render("school-members-students", context)
        }
    }
    
    
    func viewStudentHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                
                return try req.parameters.next(Student.self)
                    .flatMap(to: View.self) { student in
                        
                        let room = Room.query(on: req)
                            .filter(\.id == student.roomID)
                            .first()
                            .unwrap(or: Abort(.notFound))
                        
                        let context = SchoolMembersStudentDetailContext(
                            pretitle: "Student Detail",
                            title: "\(student.firstName) \(student.lastName)" ,
                            viewTag: 222,
                            userLoggedIn: userLoggedIn,
                            selectedSchool: school,
                            student: student,
                            room: room)
                        
                        return try req.view().render("school-members-students-detail", context)
                }
        }
    }
    
    // Create Student
    func createStudentHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let rooms = Room.query(on: req)
                    .filter(\.schoolID == school.id!)
                    .sort(\.name, .ascending).all()
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                let user = try req.requireAuthenticated(User.self)
                
                let context = CreateStudentContext(
                    pretitle: "New Student",
                    title: "Add New Student",
                    viewTag: 222,
                    userLoggedIn: userLoggedIn,
                    selectedSchool: school,
                    createBy: user.name,
                    updateBy: user.name,
                    genderTypes: GenderType.allCases,
                    rooms: rooms)
                
                return try req.view().render("school-members-students-create", context)
                
        }
    }
    
    func createStudentPostHandler(_ req: Request, student: Student) throws -> Future<Response> {
        
        return try req.parameters.next(School.self).flatMap(to: Response.self) { school in
            
            return student.save(on: req)
                .map(to: Response.self) { student in
                    guard student.id != nil else {
                        throw Abort(.internalServerError)
                    }
                    return req.redirect(to: "/school-members-students/\(school.id!)")
            }
        }
    }
    
    
    func editStudentHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let rooms = Room.query(on: req)
                    .filter(\.schoolID == school.id!)
                    .sort(\.name, .ascending).all()
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                let user = try req.requireAuthenticated(User.self)
                
                return try req.parameters.next(Student.self)
                    .flatMap(to: View.self) { student in
                        let context = EditStudentContext(
                            pretitle: "Edit Student",
                            title: "Edit Existing Student",
                            viewTag: 222,
                            userLoggedIn: userLoggedIn,
                            selectedSchool: school,
                            createBy: student.createBy,
                            updateBy: user.name,
                            genderTypes: GenderType.allCases,
                            rooms: rooms,
                            student: student
                        )
                        
                        return try req.view().render("school-members-students-create", context)
                }
        }
    }
    
    func editStudentPostHandler(_ req: Request) throws -> Future<Response> {
        
        return try flatMap(to: Response.self,
                           req.parameters.next(School.self),
                           req.parameters.next(Student.self),
                           req.content.decode(Student.self)
        ) { school, student, data in
            student.studentID = data.studentID
            student.studentNumber = data.studentNumber
            student.firstName = data.firstName
            student.lastName = data.lastName
            student.nickName = data.nickName
            student.genderType = data.genderType
            student.birthDate = data.birthDate
            student.address = data.address
            student.contactNumber = data.contactNumber
            student.email = data.email
            student.createBy = data.createBy
            student.updateBy = data.updateBy
            student.roomID = data.roomID
            
            guard student.id != nil else {
                throw Abort(.internalServerError)
            }
            
            let redirect = req.redirect(to: "/school-members-students/\(school.id!)")
            return student.save(on: req).transform(to: redirect)
            
        }
    }
    
    func addStudentProfilePictureHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(School.self).flatMap(to: View.self) { school in
            
            let userLoggedIn = try req.isAuthenticated(User.self)
            
            return try req.parameters.next(Student.self)
                .flatMap { student in
                    
                    let context = AddStudentProfilePictureContext(
                        pretitle: "Profile Picture",
                        title: "Add Profile Picture",
                        viewTag: 222,
                        userLoggedIn: userLoggedIn,
                        selectedSchool: school,
                        student: student)
                    
                    return try req.view().render("school-members-students-add-profile-picture", context)
            }
        }
    }
    
    let studentImageFolder = "ProfilePictures/Students/"
    
    func addStudentProfilePicturePostHandler(_ req: Request) throws -> Future<Response> {
        
        return try req.parameters.next(School.self).flatMap(to: Response.self) { school in
            
            return try flatMap(to: Response.self,
                               req.parameters.next(Student.self),
                               req.content.decode(ImageUploadData.self)) { student, imageData in
                                
                                
                                let workPath = try req.make(DirectoryConfig.self).workDir
                                let name = try "\(student.requireID())-\(UUID().uuidString).jpg"
                                let path = workPath + self.studentImageFolder + name
                                FileManager().createFile(
                                    atPath: path,
                                    contents: imageData.picture,
                                    attributes: nil)
                                if imageData.picture.isEmpty {
                                    student.profilePicture = ""
                                } else {
                                    student.profilePicture = name
                                }
                                
                                
                                let redirect = try req.redirect(to: "/school-members-students/\(school.requireID())/\(student.requireID())/edit")
                                
                                return student.save(on: req).transform(to: redirect)
            }
        }
    }
    
    func getStudentsProfilePictureHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Student.self)
            .flatMap(to: Response.self) { student in
                guard let filename = student.profilePicture else {
                    throw Abort(.notFound)
                }
                let path = try req.make(DirectoryConfig.self).workDir + self.studentImageFolder + filename
                
                return try req.streamFile(at: path)
        }
    }
    
    
    //Delete Student
    func deleteStudentHandler(_ req: Request) throws -> Future<Response> {
        
        return try req.parameters.next(School.self).flatMap(to: Response.self) { school in
            return try req.parameters.next(Student.self).delete(on: req)
                .transform(to: req.redirect(to: "/school-members-students/\(school.id!)"))
            
        }
    }
    
    //MARK: - Teachers
    //Teachers
    func schoolMembersTeachersHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let teachers = Teacher.query(on: req)
                    .filter(\.schoolID == school.id!)
                    .sort(\.teacherID, .descending)
                    .all()
                
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                let context = SchoolMembersTeachersContext(
                    pretitle: school.name,
                    title: "School Members",
                    viewTag: 223,
                    userLoggedIn: userLoggedIn,
                    selectedSchool: school,
                    teachers: teachers)
                
                return try req.view().render("school-members-teachers", context)
        }
    }
    
    func createTeacherHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                let user = try req.requireAuthenticated(User.self)
                
                let context = CreateTeacherContext(
                    pretitle: "New Teacher",
                    title: "Add New Teacher",
                    viewTag: 223,
                    userLoggedIn: userLoggedIn,
                    selectedSchool: school,
                    createBy: user.name,
                    updateBy: user.name,
                    genderTypes: GenderType.allCases,
                    departmentTypes: DepartmentType.allCases)
                
                return try req.view().render("school-members-teachers-create", context)
                
        }
    }
    
    func viewTeacherHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                
                return try req.parameters.next(Teacher.self)
                    .flatMap(to: View.self) { teacher in
                        
                        let context = SchoolMembersTeacherDetailContext(
                            pretitle: "Teacher Detail",
                            title: "\(teacher.firstName) \(teacher.lastName)",
                            viewTag: 223,
                            userLoggedIn: userLoggedIn,
                            selectedSchool: school,
                            teacher: teacher)
                        
                        return try req.view().render("school-members-teachers-detail", context)
                        
                }
                
        }
        
    }
    
    func createTeacherPostHandler(_ req: Request, teacher: Teacher) throws -> Future<Response> {
        
        return try req.parameters.next(School.self).flatMap(to: Response.self) { school in
            
            return teacher.save(on: req)
                .map(to: Response.self) { teacher in
                    guard teacher.id != nil else {
                        throw Abort(.internalServerError)
                    }
                    return req.redirect(to: "/school-members-teachers/\(school.id!)")
            }
        }
    }
    
    func editTeacherHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                let user = try req.requireAuthenticated(User.self)
                
                return try req.parameters.next(Teacher.self)
                    .flatMap(to: View.self) { teacher in
                        
                        let context = EditTeachertContext(
                            pretitle: "Edit Teacher",
                            title: "Edit Existing Teacher",
                            viewTag: 223,
                            userLoggedIn: userLoggedIn,
                            selectedSchool: school,
                            teacher: teacher,
                            createBy: teacher.createBy,
                            updateBy: user.name,
                            genderTypes: GenderType.allCases,
                            departmentTypes:DepartmentType.allCases)
                        
                        return try req.view().render("school-members-teachers-create", context)
                }
                
        }
    }
    
    func editTeacherPostHandler(_ req: Request) throws -> Future<Response> {
        
        return try flatMap(to: Response.self,
                           req.parameters.next(School.self),
                           req.parameters.next(Teacher.self),
                           req.content.decode(Teacher.self)
        ) { school, teacher, data in
            teacher.teacherID = data.teacherID
            teacher.firstName = data.firstName
            teacher.lastName = data.lastName
            teacher.nickName = data.nickName
            teacher.genderType = data.genderType
            teacher.birthDate = data.birthDate
            teacher.address = data.address
            teacher.contactNumber = data.contactNumber
            teacher.email = data.email
            teacher.createBy = data.createBy
            teacher.updateBy = data.updateBy
            teacher.departmentType = data.departmentType
            
            guard teacher.id != nil else {
                throw Abort(.internalServerError)
            }
            
            let redirect = req.redirect(to: "/school-members-teachers/\(school.id!)")
            return teacher.save(on: req).transform(to: redirect)
        }
    }
    
    func addTeacherProfilePictureHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self).flatMap(to: View.self) { school in
            
            let userLoggedIn = try req.isAuthenticated(User.self)
            
            return try req.parameters.next(Teacher.self)
                .flatMap { teacher in
                    
                    let context = AddTeacherProfilePictureContext(
                        pretitle: "Profile Picture",
                        title: "Add Profile Picture",
                        viewTag: 223,
                        userLoggedIn: userLoggedIn,
                        selectedSchool: school,
                        teacher: teacher)
                    
                    return try req.view().render("school-members-teachers-add-profile-picture", context)
            }
        }
    }
    
    let teacherImageFolder = "ProfilePictures/Teachers/"
    
    func addTeacherProfilePicturePostHandler(_ req: Request) throws -> Future<Response> {
        
        return try req.parameters.next(School.self).flatMap(to: Response.self) { school in
            
            return try flatMap(to: Response.self,
                               req.parameters.next(Teacher.self),
                               req.content.decode(ImageUploadData.self)) { teacher, imageData in
                                
                                
                                let workPath = try req.make(DirectoryConfig.self).workDir
                                let name = try "\(teacher.requireID())-\(UUID().uuidString).jpg"
                                let path = workPath + self.teacherImageFolder + name
                                FileManager().createFile(
                                    atPath: path,
                                    contents: imageData.picture,
                                    attributes: nil)
                                if imageData.picture.isEmpty {
                                    teacher.profilePicture = ""
                                } else {
                                    teacher.profilePicture = name
                                }
                                
                                
                                let redirect = try req.redirect(to: "/school-members-teachers/\(school.requireID())/\(teacher.requireID())/edit")
                                
                                return teacher.save(on: req).transform(to: redirect)
            }
        }
    }
    
    func getTeachersProfilePictureHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Teacher.self)
            .flatMap(to: Response.self) { teacher in
                guard let filename = teacher.profilePicture else {
                    throw Abort(.notFound)
                }
                let path = try req.make(DirectoryConfig.self).workDir + self.teacherImageFolder + filename
                
                return try req.streamFile(at: path)
        }
    }
    
    func deleteTeacherHandler(_ req: Request) throws -> Future<Response> {
        
        return try req.parameters.next(School.self).flatMap(to: Response.self) { school in
            return try req.parameters.next(Teacher.self).delete(on: req).transform(to: req.redirect(to: "/school-members-teachers/\(school.id!)"))
        }
    }
    
    //MARK: - School People Overview
    //Parent
    func schoolMembersParentsHandler(_ req: Request) throws ->
        Future<View> {
            
            return try req.parameters.next(School.self) 
                .flatMap(to: View.self) { school in
                    
                    let userLoggedIn = try req.isAuthenticated(User.self)
                    
                    let context = SchoolMembersParentsContext(
                        pretitle: "School",
                        title: "School Members",
                        viewTag: 224,
                        userLoggedIn: userLoggedIn,
                        selectedSchool: school)
                    
                    return try req.view().render("school-members-parents", context)
            }
    }
}
