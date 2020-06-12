//
//  UserType.swift
//  App
//
//  Created by Rujira Petrung on 13/5/20.
//

import FluentPostgreSQL

enum UserType: String, PostgreSQLEnum, PostgreSQLMigration {
    case admin
    case standard
    case teacher
    case staff
    case student
    case parent
    case developer
}
