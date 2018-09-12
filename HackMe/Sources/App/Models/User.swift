import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class User: Codable {
    var id: Int?
    var name: String
    var username: String
    var password: String
    var bankBalance: Int
    var admin: Bool

    init(name: String, username: String, password: String, bankBalance: Int, admin: Bool) {
        self.name = name
        self.username = username
        self.password = password
        self.bankBalance = bankBalance
        self.admin = admin
    }
}

extension User: PostgreSQLModel {}
extension User: Content {}
extension User: Migration {}

extension User: Parameter {}

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.username
    static let passwordKey: PasswordKey = \User.password
}

struct DefaultUser: Migration {

    typealias Database = PostgreSQLDatabase

    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        let password = try? BCrypt.hash("password")
        guard let hashedPassword = password else {
            fatalError("Failed to create admin user")
        }
        let user = User(name: "User", username: "user", password: hashedPassword, bankBalance: 10000, admin: false)
        return user.save(on: connection).transform(to: ())
    }

    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return Future.map(on: connection) {}
    }
}

struct SecondUser: Migration {

    typealias Database = PostgreSQLDatabase

    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        let password = try? BCrypt.hash("password")
        guard let hashedPassword = password else {
            fatalError("Failed to create admin user")
        }
        let user = User(name: "User2", username: "user2", password: hashedPassword, bankBalance: 10000, admin: true)
        return user.save(on: connection).transform(to: ())
    }

    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return Future.map(on: connection) {}
    }
}

extension User: PasswordAuthenticatable {}
extension User: SessionAuthenticatable {}

struct UserLoginData: Content {
    let username: String
    let password: String
}
