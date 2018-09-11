import Vapor
import FluentPostgreSQL

final class Message: Codable {
    var id: Int?
    var text: String

    init(text: String) {
        self.text = text
    }
}

extension Message: PostgreSQLModel {}
extension Message: Migration {}
