
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
        protectedRoutes.get("school-layout-rooms", School.parameter, Room.parameter, "view", use: viewRoomHandler)
        protectedRoutes.get("school-layout-rooms", School.parameter, "create", use: createRoomHandler)
        protectedRoutes.post(Room.self, at: "school-layout-rooms", School.parameter, "create", use: createRoomPostHandler)
        protectedRoutes.get("school-layout-rooms", School.parameter, Room.parameter, "edit", use: editRoomHandler)
        protectedRoutes.post("school-layout-rooms", School.parameter, Room.parameter, "edit", use: editRoomPostHandler)
        protectedRoutes.post("school-layout-rooms", School.parameter, Room.parameter, "delete", use: deleteRoomHandler)
        protectedRoutes.post("school-layout-rooms", School.parameter, Room.parameter, "teachers", Teacher.parameter, use: addHomeroomTeachersHandler)
        protectedRoutes.post("school-layout-rooms", School.parameter, Room.parameter, "teachers", Teacher.parameter, "remove", use: removeHomeroomTeachersHandler)
        
        //School Layout - Zones
        protectedRoutes.get("school-layout-zones", School.parameter, use: schoolLayoutZonesHandler)
        protectedRoutes.get("school-layout-zones", School.parameter, Zone.parameter, "view", use: viewZoneHandler)
        protectedRoutes.get("school-layout-zones", School.parameter, "create", use: createZoneHandler)
        protectedRoutes.post(Zone.self, at: "school-layout-zones", School.parameter, "create", use: createZonePostHandler)
        protectedRoutes.get("school-layout-zones", School.parameter, Zone.parameter, "edit", use: editZoneHandler)
        protectedRoutes.post("school-layout-zones", School.parameter, Zone.parameter, "edit", use: editZonePostHandler)
        protectedRoutes.get("school-layout-zones", School.parameter, Zone.parameter, "addZoneCoverImage", use: addZoneCoverImageHandler)
        protectedRoutes.post("school-layout-zones", School.parameter, Zone.parameter, "addZoneCoverImage", use: addZoneCoverImagePostHandler)
        authSessionRoutes.get("zones", Zone.parameter, "coverImage", use: getZonesCoverImageHandler)
        protectedRoutes.post("school-layout-zones", School.parameter, Zone.parameter, "delete", use: deleteZoneHandler)
        
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
                
                let roomsWithStudents = Room.query(on: req).filter(\.schoolID == school.id!).sort(\.name, .ascending).all()
                    .flatMap(to: [RoomWithStudents].self) { rooms in
                        try rooms.map { room in
                            try room.students.query(on: req)
                                
                                .all()
                                .map{ students in
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
                
                
                let students =  Student.query(on: req)
                    .filter(\.schoolID == school.id!)
                    .sort(\.studentID, .ascending).all()
                
                let zones = Zone.query(on: req)
                    .filter(\.schoolID == school.id!)
                    .sort(\.id, .ascending).all()
                
                let context = SchoolLayoutOverviewContext(
                    pretitle: school.name,
                    title: "School Layout",
                    viewTag: 211,
                    userLoggedIn: userLoggedIn,
                    selectedSchool: school,
                    grades: gradesWithRooms,
                    rooms: roomsWithStudents,
                    students: students,
                    zones: zones)
                
                
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
                        
                        let students = Student.query(on: req)
                            .filter(\.roomID == room.id!)
                            .sort(\.studentNumber, .ascending).all()
                        
                        let teachers = Teacher.query(on: req)
                            .filter(\.schoolID == school.id!)
                            .sort(\.fullName, .ascending).all()
                        
                        let homeroomTeachers = try room.teachers.query(on: req).all()
                        
                        let context = SchoolLayoutRoomDetailContext(
                            pretitle: "Room Detail",
                            title: room.name,
                            viewTag: 213,
                            userLoggedIn: userLoggedIn,
                            selectedSchool: school,
                            room: room,
                            students: students,
                            teachers: teachers,
                            homeroomTeachers: homeroomTeachers)
                        
                        
                        return try req.view().render("school-layout-rooms-detail", context)
                }
                
        }
    }
    
    //Sibling Relationship Room-Teacher Pivot
    func addHomeroomTeachersHandler(_ req: Request) throws -> Future<Response> {
        
        return try flatMap(to: Response.self,
                           req.parameters.next(School.self),
                           req.parameters.next(Room.self),
                           req.parameters.next(Teacher.self)) { school, room, teacher in
                            
                            let redirect = req.redirect(to: "/school-layout-rooms/\(school.id!)/\(room.id!)/view")
                            
                            return try Teacher.addTeacher(teacher, to: room, on: req).transform(to: redirect)
        }
    }
    
    func removeHomeroomTeachersHandler(_ req: Request) throws -> Future<Response> {
        
        return try flatMap(to: Response.self,
                           req.parameters.next(School.self),
                           req.parameters.next(Room.self),
                           req.parameters.next(Teacher.self)) { school, room, teacher in
                            
                            let redirect = req.redirect(to: "/school-layout-rooms/\(school.id!)/\(room.id!)/view")
                            
                            return try Teacher.removeTeacher(teacher, from: room, on: req).transform(to: redirect)
                            
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
            room.numberOfSeats = data.numberOfSeats
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
    
    //MARK: - Zones
    //Zones
    
    func schoolLayoutZonesHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let zones = Zone.query(on: req)
                    .filter(\.schoolID == school.id!)
                    .sort(\.name, .ascending).all()
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                
                let context = SchoolLayoutZonesContext(
                    pretitle: school.name,
                    title: "School Layout",
                    viewTag: 214,
                    userLoggedIn: userLoggedIn,
                    selectedSchool: school,
                    zones: zones)
                
                return try req.view().render("school-layout-zones", context)
        }
    }
    
    func viewZoneHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                
                return try req.parameters.next(Zone.self)
                    .flatMap(to: View.self) { zone in
                        
                        let context = SchoolLayoutZoneDetailContext(
                            pretitle: "Zone Detail",
                            title: zone.name,
                            viewTag: 214,
                            userLoggedIn: userLoggedIn,
                            selectedSchool: school,
                            zone: zone)
                        
                        return try req.view().render("school-layout-zones-detail", context)
                        
                }
                
                
        }
    }
    
    func createZoneHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                let user = try req.requireAuthenticated(User.self)
                
                let context = CreateZoneContext(
                    pretitle: "New Zone",
                    title: "Create New Zone",
                    viewTag: 214,
                    userLoggedIn: userLoggedIn,
                    selectedSchool: school,
                    createBy: user.name,
                    updateBy: user.name,
                    zoneTypes: ZoneType.allCases)
                
                return try req.view().render("school-layout-zones-create", context)
                
        }
    }
    
    func createZonePostHandler(_ req: Request, zone: Zone) throws -> Future<Response> {
        
        return try req.parameters.next(School.self).flatMap(to: Response.self) { school in
            
            return zone.save(on: req)
                .map(to: Response.self) { zone in
                    guard zone.id != nil else {
                        throw Abort(.internalServerError)
                    }
                    return req.redirect(to: "/school-layout-zones/\(school.id!)")
            }
        }
    }
    
    func editZoneHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                
                let userLoggedIn = try req.isAuthenticated(User.self)
                let user = try req.requireAuthenticated(User.self)
                
                return try req.parameters.next(Zone.self)
                    .flatMap(to: View.self) { zone in
                        
                        let context = EditZoneContext(
                            pretitle: "Edit Zone",
                            title: "Edit Existing Zone",
                            viewTag: 214,
                            userLoggedIn: userLoggedIn,
                            selectedSchool: school,
                            createBy: zone.createBy,
                            updateBy: user.name,
                            zoneTypes: ZoneType.allCases,
                            zone: zone)
                        
                        return try req.view().render("school-layout-zones-create", context)
                }
        }
    }
    
    func editZonePostHandler(_ req: Request) throws -> Future<Response> {
        
        return try flatMap(to: Response.self,
                           req.parameters.next(School.self),
                           req.parameters.next(Zone.self),
                           req.content.decode(Zone.self)) { school, zone, data in
                            
                            zone.name = data.name
                            zone.zoneType = data.zoneType
                            zone.createBy = data.createBy
                            zone.updateBy = data.updateBy
                            
                            guard zone.id != nil else {
                                throw Abort(.internalServerError)
                            }
                            let redirect = req.redirect(to: "/school-layout-zones/\(school.id!)")
                            
                            return zone.save(on: req).transform(to: redirect)
        }
    }
    
    func addZoneCoverImageHandler(_ req: Request) throws -> Future<View> {
        
        return try req.parameters.next(School.self).flatMap(to: View.self) { school in
            
            let userLoggedIn = try req.isAuthenticated(User.self)
            
            return try req.parameters.next(Zone.self)
                .flatMap { zone in
                    
                    let context = AddZoneCoverImageContext(
                        pretitle: "Cover Image",
                        title: "Add Cover Image",
                        viewTag: 214,
                        userLoggedIn: userLoggedIn,
                        selectedSchool: school,
                        zone: zone)
                    
                    return try req.view().render("school-layout-zones-add-cover-image", context)
            }
        }
    }
    
    let zoneImageFolder = "ProfilePictures/Zones/"
    
    func addZoneCoverImagePostHandler(_ req: Request) throws -> Future<Response> {
        
        return try req.parameters.next(School.self).flatMap(to: Response.self) { school in
            
            return try flatMap(to: Response.self,
                               req.parameters.next(Zone.self),
                               req.content.decode(ImageUploadData.self)) { zone, imageData in
                                
                                
                                let workPath = try req.make(DirectoryConfig.self).workDir
                                let name = try "\(zone.requireID())-\(UUID().uuidString).jpg"
                                let path = workPath + self.zoneImageFolder + name
                                FileManager().createFile(
                                    atPath: path,
                                    contents: imageData.picture,
                                    attributes: nil)
                                if imageData.picture.isEmpty {
                                    zone.coverImage = ""
                                } else {
                                    zone.coverImage = name
                                }
                                
                                
                                let redirect = try req.redirect(to: "/school-layout-zones/\(school.requireID())/\(zone.requireID())/edit")
                                
                                return zone.save(on: req).transform(to: redirect)
                                
            }
        }
    }
    
    func getZonesCoverImageHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Zone.self)
            .flatMap(to: Response.self) { zone in
                guard let filename = zone.coverImage else {
                    throw Abort(.notFound)
                }
                let path = try req.make(DirectoryConfig.self).workDir + self.zoneImageFolder + filename
                
                return try req.streamFile(at: path)
        }
    }
    
    func deleteZoneHandler(_ req: Request) throws -> Future<Response> {
        
        return try req.parameters.next(School.self).flatMap(to: Response.self) { school in
            
            return try req.parameters.next(Zone.self).delete(on: req)
                .transform(to: req.redirect(to: "/school-layout-zones/\(school.id!)"))
        }
    }
}


