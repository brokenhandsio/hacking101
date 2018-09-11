import Foundation
import Vapor
import FluentSQLite
import Authentication

final class User: Codable {
    var id: Int?
    var name: String
    var username: String
    var password: String
    var bankBalance: Int

    init(name: String, username: String, password: String, bankBalance: Int) {
        self.name = name
        self.username = username
        self.password = password
        self.bankBalance = bankBalance
    }
}

extension User: SQLiteModel {}
extension User: Content {}
extension User: Migration {}

extension User: Parameter {}

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.username
    static let passwordKey: PasswordKey = \User.password
}

struct DefaultUser: Migration {

    typealias Database = SQLiteDatabase

    static func prepare(on connection: SQLiteConnection) -> Future<Void> {
        let password = try? BCrypt.hash("password")
        guard let hashedPassword = password else {
            fatalError("Failed to create admin user")
        }
        let user = User(name: "User", username: "user", password: hashedPassword, bankBalance: 10000)
        return user.save(on: connection).transform(to: ())
    }

    static func revert(on connection: SQLiteConnection) -> Future<Void> {
        return Future.map(on: connection) {}
    }
}

extension User: PasswordAuthenticatable {}
extension User: SessionAuthenticatable {}
