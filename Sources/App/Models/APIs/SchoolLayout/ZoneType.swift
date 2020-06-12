//
//  ZoneType.swift
//  App
//
//  Created by Rujira Petrung on 27/5/20.
//

import Foundation
import FluentPostgreSQL

enum ZoneType: String, PostgreSQLEnum, PostgreSQLMigration {
    case indoor
    case outdoor
}
