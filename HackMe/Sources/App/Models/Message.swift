import Vapor
import FluentSQLite

final class Message: Codable {
    var id: Int?
    var text: String

    init(text: String) {
        self.text = text
    }
}

extension Message: SQLiteModel {}
extension Message: Migration {}
