//
//  File.swift
//  App
//
//  Created by Rujira Petrung on 1/7/20.
//

import Foundation
import FluentPostgreSQL

enum SubjectLevel: String, PostgreSQLEnum, PostgreSQLMigration {
    case beginer
    case intermediate
    case advanced
}
