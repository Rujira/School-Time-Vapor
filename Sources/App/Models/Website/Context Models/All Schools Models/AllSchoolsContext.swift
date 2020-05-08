//
//  AllSchoolsContext.swift
//  App
//
//  Created by Rujira Petrung on 5/5/20.
//

import Foundation
import Vapor

//Index Page Context
struct IndexContext: Encodable {
    
    //Index
    let pretitle: String
    let title: String
    let userLoggedIn: Bool
    let showCookieMessage: Bool
    let schools: Future<[School]>
    
}

