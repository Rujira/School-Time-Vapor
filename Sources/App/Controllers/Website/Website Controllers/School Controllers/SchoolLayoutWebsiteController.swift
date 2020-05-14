
import Vapor
import Leaf
import Authentication

struct SchoolLayoutWebsiteController: RouteCollection {
    
    func boot(router: Router) throws {
        //Load Index page
        
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
        let protectedRoutes = authSessionRoutes.grouped(RedirectMiddleware<User>(path: "/login"))
        
        //School
        //School Layout - Overview
        protectedRoutes.get("school-layout-overview", School.parameter, use: schoolLayoutOverviewHandler)
        
        //School Layout - Grades
        protectedRoutes.get("school-layout-grades", School.parameter, use: schoolLayoutGradesHandler)
        protectedRoutes.get("school-layout-grades", School.parameter, Grade.parameter, "view" , use: viewGradeHandler)
        protectedRoutes.get("school-layout-grades", School.parameter, "create", use: createGradeHandler)
        protectedRoutes.post(Grade.self, at: "school-layout-grades", School.parameter, "create", use: createGradePostHandler)
        protectedRoutes.get("school-layout-grades", School.parameter, Grade.parameter, "edit", use: editGradeHandler)
        protectedRoutes.post("school-layout-grades", School.parameter, Grade.parameter, "edit", use: editGradePostHandler)
        protectedRoutes.post("school-layout-grades", School.parameter, Grade.parameter, "delete", use: deleteGradeHandler)
        
        //School Layout - Rooms
        protectedRoutes.get("school-layout-rooms", School.parameter, use: schoolLayoutRoomsHandler)
        protectedRoutes.get("school-layout-rooms", School.parameter, Room.parameter, "view" , use: viewRoomHandler)
        protectedRoutes.get("school-layout-rooms", School.parameter, "create", use: createRoomHandler)
        protectedRoutes.post(Room.self, at: "school-layout-rooms", School.parameter, "create", use: createRoomPostHandler)
        protectedRoutes.get("school-layout-rooms", School.parameter, Room.parameter, "edit", use: editRoomHandler)
        protectedRoutes.post("school-layout-rooms", School.parameter, Room.parameter, "edit", use: editRoomPostHandler)
        protectedRoutes.post("school-layout-rooms", School.parameter, Room.parameter, "delete", use: deleteRoomHandler)
        
        //School Layout - Students
        protectedRoutes.get("school-layout-students", School.parameter, use: schoolLayoutStudentsHandler)
        protectedRoutes.get("school-layout-students", School.parameter, "create", use: createStudentHandler)
        
        //School Layout - Teachers
        protectedRoutes.get("school-layout-teachers", School.parameter, use: schoolLayoutTeachersHandler)
        
    }
    
    //MARK: - Overview
    //Overview
    func schoolLayoutOverviewHandler(_ req: Request) throws -> Future<View> {
        
        let userLoggedIn = try req.isAuthenticated(User.self)
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let gradesWithRooms = Grade.query(on: req)
                    .filter(\.schoolID == school.id!)
                    .sort(\.name, .descending).all()
                    .flatMap(to: [GradeWithRooms].self) { grades in
                        try grades.map { grade in
                            try grade.rooms.query(on: req).sort(\.name, .ascending)
                                .all()
                                .map{ rooms in
                                    
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
                
                
                let roomsWithGrade = Room.query(on: req)
                    .join(\Grade.id, to: \Room.gradeID)
                    .alsoDecode(Grade.self).filter(\Grade.schoolID == school.id!).all()
                    .map(to: [RoomsWithGrade].self) { roomGradePairs in
                        roomGradePairs.map { room, grade -> RoomsWithGrade in
                            RoomsWithGrade(id: room.id, name: room.name, grade: grade)
                            
                        }
                }
                
                let context = SchoolLayoutOverviewContext(
                    pretitle: school.name,
                    title: "School Layout",
                    viewTag: 211,
                    userLoggedIn: userLoggedIn,
                    selectedSchool: school,
                    grades: gradesWithRooms,
                    rooms: roomsWithGrade)
                
                
                return try req.view().render("school-layout-overview", context)
        }
    }
    
    //MARK: - Grades
    //Grades
    func schoolLayoutGradesHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let gradesWithRooms = Grade.query(on: req)
                    .filter(\.schoolID == school.id!)
                    .sort(\.name, .descending).all()
                    .flatMap(to: [GradeWithRooms].self) { grades in
                        try grades.map { grade in
                            try grade.rooms.query(on: req).sort(\.name, .ascending)
                                .all()
                                .map{ rooms in
                                    
                                    GradeWithRooms(id: grade.id,
                                                   name: grade.name,
                                                   schoolID: grade.schoolID,
                                                   gradeType: grade.gradeType,
                                                   updateBy: grade.updateBy,
                                                   updateAt: grade.updateAt,
                                                   rooms: rooms)
                            }
                        }.flatten(on: req)
                }
                
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                let context = SchoolLayoutGradesContext(
                    pretitle: school.name,
                    title: "School Layout",
                    viewTag: 212,
                    userLoggedIn: userLoggedIn,
                    selectedSchool: school,
                    grades: gradesWithRooms)
                return try req.view().render("school-layout-grades", context)
                
        }
    }
    
    func viewGradeHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                
                return try req.parameters.next(Grade.self)
                    .flatMap(to: View.self) { grade in
                        
                        let rooms = Room.query(on: req)
                            .filter(\.gradeID == grade.id!)
                            .sort(\.name, .ascending).all()
                        
                        let context = SchoolLayoutGradeDetailContext(
                            pretitle: "Grade Detail",
                            title: grade.name,
                            viewTag: 212,
                            userLoggedIn: userLoggedIn,
                            selectedSchool: school,
                            grade: grade,
                            rooms: rooms)
                        
                        return try req.view().render("school-layout-grades-detail", context)
                }
        }
        
    }
    
    // Create Grade
    func createGradeHandler(_ req: Request) throws -> Future<View>  {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                let user = try req.requireAuthenticated(User.self)
                
                let context = CreateGradeContext(
                    pretitle: "New Grade",
                    title: "Create New Grade",
                    viewTag: 212,
                    userLoggedIn: userLoggedIn,
                    selectedSchool: school,
                    createBy: user.name,
                    updateBy: user.name,
                    gradeTypes: [GradeType.kindergarden, GradeType.elementary, GradeType.secondary])
                
                return try req.view().render("school-layout-grades-create", context)
        }
    }
    
    func createGradePostHandler(_ req: Request, grade: Grade) throws -> Future<Response> {
        return grade.save(on: req)
            .map(to: Response.self) { grade in
                guard grade.id != nil else {
                    throw Abort(.internalServerError)
                }
                return req.redirect(to:"/school-layout-grades/\(grade.schoolID)")
        }
    }
    
    // Edit Grade
    func editGradeHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                let user = try req.requireAuthenticated(User.self)
                
                return try req.parameters.next(Grade.self)
                    .flatMap(to: View.self) { grade in
                        let context = EditGradeContext(
                            pretitle: "Edit Grade",
                            title: "Edit Existing Grade",
                            viewTag: 212,
                            userLoggedIn: userLoggedIn,
                            selectedSchool: school,
                            createBy: grade.createBy,
                            updateBy: user.name,
                            gradeTypes: [GradeType.kindergarden, GradeType.elementary, GradeType.secondary],
                            grade: grade)
                        
                        return try req.view().render("school-layout-grades-create", context)
                }
        }
    }
    
    func editGradePostHandler(_ req: Request) throws -> Future<Response> {
        
        
        return try flatMap(to: Response.self,
                           req.parameters.next(School.self),
                           req.parameters.next(Grade.self),
                           req.content.decode(Grade.self)
        ) { school, grade, data in
            grade.name = data.name
            grade.gradeType = data.gradeType
            grade.schoolID = data.schoolID
            grade.createBy = data.createBy
            grade.updateBy = data.updateBy
            
            guard grade.id != nil else {
                throw Abort(.internalServerError)
            }
            
            let redirect = req.redirect(to:"/school-layout-grades/\(grade.schoolID)")
            return grade.save(on: req).transform(to: redirect)
        }
    }
    
    func deleteGradeHandler(_ req: Request) throws -> Future<Response> {
        
        return try req.parameters.next(School.self).flatMap(to: Response.self) { school in
            return try req.parameters.next(Grade.self).delete(on: req)
                .transform(to: req.redirect(to: "/school-layout-grades/\(school.id!)"))
        }
        
    }
    
    //MARK: - Rooms
    //Rooms
    func schoolLayoutRoomsHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let gradesWithRooms = Grade.query(on: req)
                    .filter(\.schoolID == school.id!)
                    .sort(\.name, .descending).all()
                    .flatMap(to: [GradeWithRooms].self) { grades in
                        try grades.map { grade in
                            try grade.rooms.query(on: req).sort(\.name, .descending)
                                .all()
                                .map{ rooms in
                                    
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
                
                let roomsWithStudents = Room.query(on: req).sort(\.name, .ascending).all()
                    .flatMap(to: [RoomWithStudents].self) { rooms in
                        try rooms.map { room in
                            try room.students.query(on: req)
                                .all()
                                .map{ students in
                                    RoomWithStudents(id: room.id,
                                                     name: room.name,
                                                     gradeID: room.gradeID,
                                                     createBy: room.createBy,
                                                     updateBy: room.updateBy,
                                                     createAt: room.createAt,
                                                     updateAt: room.updateAt,
                                                     students: students)
                            }
                        }.flatten(on: req)
                }
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                let context = SchoolLayoutRoomsContext(
                    pretitle: school.name,
                    title: "School Layout",
                    viewTag: 213,
                    userLoggedIn: userLoggedIn,
                    selectedSchool: school,
                    grades: gradesWithRooms,
                    rooms: roomsWithStudents)
                return try req.view().render("school-layout-rooms", context)
        }
    }
    
    func viewRoomHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                
                return try req.parameters.next(Room.self)
                    .flatMap(to: View.self) { room in
                        
                        let context = SchoolLayoutRoomDetailContext(
                            pretitle: "Room Detail",
                            title: room.name,
                            viewTag: 213,
                            userLoggedIn: userLoggedIn,
                            selectedSchool: school,
                            room: room)
                        
                        return try req.view().render("school-layout-rooms-detail", context)
                }
                
        }
    }
    
    // Create Room
    func createRoomHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let grades = Grade.query(on: req)
                    .filter(\.schoolID == school.id!)
                    .sort(\.name, .ascending).all()
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                let user = try req.requireAuthenticated(User.self)
                
                let context = CreateRoomContext(
                    pretitle: "New Room",
                    title: "Create New Room",
                    viewTag: 213,
                    userLoggedIn: userLoggedIn,
                    selectedSchool: school,
                    createBy: user.name,
                    updateBy: user.name,
                    grades: grades)
                
                return try req.view().render("school-layout-rooms-create", context)
        }
        
    }
    
    func createRoomPostHandler(_ req: Request, room: Room) throws -> Future<Response> {
        
        return try req.parameters.next(School.self).flatMap(to: Response.self) { school in
            return room.save(on: req)
                .map(to: Response.self) { room in
                    guard room.id != nil else {
                        throw Abort(.internalServerError)
                    }
                    return req.redirect(to: "/school-layout-rooms/\(school.id!)")
            }
        }
        
    }
    
    func editRoomHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let grades = Grade.query(on: req)
                    .sort(\.name, .descending).all()
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                let user = try req.requireAuthenticated(User.self)
                
                return try req.parameters.next(Room.self)
                    .flatMap(to: View.self) { room in
                        let context = EditRoomContext(
                            pretitle: "Edit Room",
                            title: "Edit Existing Room",
                            viewTag: 213,
                            userLoggedIn: userLoggedIn,
                            selectedSchool: school,
                            createBy: room.createBy,
                            updateBy: user.name,
                            grades: grades,
                            room: room)
                        
                        return try req.view().render("school-layout-rooms-create", context)
                }
        }
        
    }
    
    func editRoomPostHandler(_ req: Request) throws -> Future<Response> {
        
        return try flatMap(to: Response.self,
                           req.parameters.next(School.self),
                           req.parameters.next(Room.self),
                           req.content.decode(Room.self)
        ) { school, room, data in
            room.name = data.name
            room.gradeID = data.gradeID
            room.createBy = data.createBy
            room.updateBy = data.updateBy
            
            guard room.id != nil else {
                throw Abort(.internalServerError)
            }
            let redirect = req.redirect(to: "/school-layout-rooms/\(school.id!)")
            return room.save(on: req).transform(to: redirect)
        }
    }
    
    func deleteRoomHandler(_ req: Request) throws -> Future<Response> {
        
        return try req.parameters.next(School.self).flatMap(to: Response.self) { school in
            return try req.parameters.next(Room.self).delete(on: req)
                .transform(to: req.redirect(to: "/school-layout-rooms/\(school.id!)"))
            
        }
    }
    
    //MARK: - Students
    //Students
    func schoolLayoutStudentsHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let students = Student.query(on: req)
                    .join(\Room.id, to: \Student.roomID)
                    .alsoDecode(Room.self).all()
                    .map(to: [StudentsWithRoom].self) {
                        studentRoomPairs in
                        
                        studentRoomPairs.map { student, room -> StudentsWithRoom in
                            StudentsWithRoom(id: student.id,
                                             studentID: student.studentID,
                                             firstName: student.firstName,
                                             lastName: student.lastName,
                                             gender: student.gender,
                                             birthDate: student.birthDate,
                                             age: student.getAgeFromDOF(date: student.birthDate ?? ""),
                                             updateBy: student.updateBy,
                                             updateAt: student.updateAt, room: room.name)
                        }
                }
                
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                
                let context = SchoolLayoutStudentsContext(
                    pretitle: school.name,
                    title: "School Layout",
                    viewTag: 214,
                    userLoggedIn: userLoggedIn,
                    selectedSchool: school,
                    students: students)
                
                return try req.view().render("school-layout-students", context)
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
                    viewTag: 214,
                    userLoggedIn: userLoggedIn,
                    selectedSchool: school,
                    createBy: user.name,
                    updateBy: user.name,
                    rooms: rooms)
                
                return try req.view().render("school-layout-students-create", context)
                
        }
    }
    
    //MARK: - Teachers
    //Teachers
    func schoolLayoutTeachersHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                let userLoggedIn = try req.isAuthenticated(User.self)
                let context = SchoolPeopleTeachersContext(
                    pretitle: school.name,
                    title: "School Layout",
                    viewTag: 215,
                    userLoggedIn: userLoggedIn,
                    selectedSchool: school)
                
                return try req.view().render("school-layout-teachers", context)
        }
    }
    
    
}


