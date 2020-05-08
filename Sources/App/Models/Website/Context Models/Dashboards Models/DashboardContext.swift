//
//  DashboardContexts.swift
//  App
//
//  Created by Rujira Petrung on 24/4/20.
//

import Foundation
import Vapor

struct DashboardOverviewContext: Encodable {
    //Dashboard/Overview
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    let selectedSchool: School
}

struct TimeAttendanceContext: Encodable {
    //Dashboard/TimeAttendance
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
}

struct ParentPickupContext: Encodable {
    //Dashboard/ParentPickup
    let pretitle: String
    let title: String
    let viewTag: Int
    let userLoggedIn: Bool
    
}
