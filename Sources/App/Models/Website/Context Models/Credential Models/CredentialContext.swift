//
//  Credentials Models.swift
//  App
//
//  Created by Rujira Petrung on 4/5/20.
//

import Foundation
import Vapor

struct LoginContext: Encodable {
    let title = "School Time"
    let loginError: Bool
    
    init(loginError: Bool = false) {
        self.loginError = loginError
    }
}

struct LoginPostData: Content {
    let username: String
    let password: String
}

