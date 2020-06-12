//
//  DepartmentType.swift
//  App
//
//  Created by Rujira Petrung on 28/5/20.
//

import Foundation
import FluentPostgreSQL

enum DepartmentType: String, PostgreSQLEnum, PostgreSQLMigration {
    
    case other = "Studies Support"
    case thai_language = "Thai Language"
    case mathematics = "Mathematics"
    case science = "Science"
    case social_studies = "Social Studies, Religion and Culture"
    case health_and_physical_educations = "Health and Physical Education"
    case art = "Art"
    case occupations_and_techology = "Occupations and Technology"
    case foreign_languages = "Foreign Languages"
    
}


