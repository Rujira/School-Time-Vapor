//
//  GenderType.swift
//  App
//
//  Created by Rujira Petrung on 13/5/20.
//

import Foundation
import FluentPostgreSQL

enum GenderType: String, PostgreSQLEnum, PostgreSQLMigration {

    case male
    case female
    case other
    
}
