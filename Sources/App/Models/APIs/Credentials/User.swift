//
//  User.swift
//  App
//
//  Created by Rujira Petrung on 15/4/20.
//

import Vapor
import FluentPostgreSQL
import Authentication

final class User: Codable {
    
    typealias Database = PostgreSQLDatabase
    
    var id: UUID?
    var name: String
    var username: String
    var password: String
    var userType: UserType = .standard
    
    init(name: String, username: String, password: String, userType: UserType) {
        self.name = name
        self.username = username
        self.password = password
        self.userType = userType
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String
        var username: String
        var userType: UserType = .standard
        
        init(id: UUID?, name: String, username: String, userType: UserType) {
            self.id = id
            self.name = name
            self.username = username
            self.userType = userType
        }
    }
}

extension User: PostgreSQLUUIDModel {}
extension User: Content {}
extension User: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.username)
        }
    }
}
extension User: Parameter {}
extension User.Public: Content {}

//Getting Children Relationship
extension User {
    var schools: Children<User, School> {
        return children(\.userID)
    }
}

//Public
extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: id, name: name, username: username, userType: userType)
    }
}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
}

//Authentication
extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.username
    static let passwordKey: PasswordKey = \User.password
}

//Using Token
extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

//Database Seeding
struct AdminUser: Migration {
    
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        
        let password = try? BCrypt.hash("a3eilm2s2yKNIGHT")
        guard let hashedPassword = password else {
            fatalError("Failed to create admin user")
        }
        
        let user = User(name: "School Time Admin",
                        username: "stadmin",
            password: hashedPassword,
            userType: .admin)
        return user.save(on: connection).transform(to: ())
    }
    
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return .done(on: connection)
    }
}

extension User: PasswordAuthenticatable {}

extension User: SessionAuthenticatable {}
