//
//  DashboardWebsiteController.swift
//  App
//
//  Created by Rujira Petrung on 3/5/20.
//

import Foundation
import Vapor
import Leaf
import Authentication

struct DashboardWebsiteController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
        
        let protectedRoutes = authSessionRoutes.grouped(RedirectMiddleware<User>(path: "/login"))
        
        protectedRoutes.get("dashboard-overview", School.parameter, use: dashboardOverviewHandler)
    }
    
    //MARK: - Dashboard
    //Dashboard
    
    //Index Page Handler Overview
    func dashboardOverviewHandler(_ req: Request) throws -> Future<View> {
        
        let userLoggedIn = try req.isAuthenticated(User.self)

        return try req.parameters.next(School.self)
            .flatMap(to: View.self) { school in
                let context = DashboardOverviewContext(
                pretitle: "Dashboard",
                title: "Overview",
                viewTag: 110,
                userLoggedIn: userLoggedIn,
                selectedSchool: school)
                
                
                return try req.view().render("dashboard-overview", context)
                
        }

    }
    
}


     
