//
//  GradeType.swift
//  App
//
//  Created by Rujira Petrung on 25/4/20.
//

import Foundation
import FluentPostgreSQL

enum GradeType: String, PostgreSQLEnum, PostgreSQLMigration {
    case kindergarden
    case elementary
    case secondary
}
