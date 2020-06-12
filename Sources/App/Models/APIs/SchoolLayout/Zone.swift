//
//  Zone.swift
//  App
//
//  Created by Rujira Petrung on 27/5/20.
//

import Vapor
import FluentPostgreSQL

final class Zone: Codable {
    
    typealias Database = PostgreSQLDatabase
    
    var id: UUID?
    var name: String
    var schoolID: School.ID
    var zoneType: ZoneType
    var coverPhoto: String?
    var createAt: Date?
    var updateAt: Date?
    var createBy: String
    var updateBy: String
    
    init(name: String, schoolID: School.ID, zoneType: ZoneType, coverPhoto: String? = nil, createBy: String, updateBy: String) {
        
        self.name = name
        self.schoolID = schoolID
        self.zoneType = zoneType
        self.coverPhoto = coverPhoto
        self.createBy = createBy
        self.updateBy = updateBy
    }
}

extension Zone: PostgreSQLUUIDModel {
    static let createdAtKey: TimestampKey? = \.createAt
    static let updatedAtKey: TimestampKey? = \.updateAt
}

extension Zone: Content {}

extension Zone: Migration {
    
    //Foreign key constraints
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.schoolID, to: \School.id)
        }
    }
}

extension Zone: Parameter {}
 
extension Zone {
    var school: Parent<Zone, School> {
        return parent(\.schoolID)
    }
}
