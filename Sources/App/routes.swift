import Vapor
import Fluent

public func routes(_ router: Router) throws {
    
    let studentsController = StudentsController()
    try router.register(collection: studentsController)
    
    let usersController = UsersController()
    try router.register(collection: usersController)

    let schoolController = SchoolsController()
    try router.register(collection: schoolController)
    
    let gradeController = GradesController()
    try router.register(collection: gradeController)
    
    let roomController = RoomsController()
    try router.register(collection: roomController)
    
    
    //Website routes
    let allSchoolsWebsiteController = AllSchoolsWebsiteController()
    try router.register(collection: allSchoolsWebsiteController)
    
    let dashboardWebsiteController = DashboardWebsiteController()
    try router.register(collection: dashboardWebsiteController)
    
    let schoolLayoutWebsiteController = SchoolLayoutWebsiteController()
    try router.register(collection: schoolLayoutWebsiteController)
    
    let schoolPeopleWebsiteController = SchoolPeopleWebsiteController()
    try router.register(collection: schoolPeopleWebsiteController)
}

