import Vapor

struct SearchController: RouteCollection {
    func boot(router: Router) throws {
        router.get("search", use: searchController)
    }

    func searchController(_ req: Request) throws -> Future<View> {
        guard let nameToSearchFor = req.query[String.self, at: "search"] else {
            let context = SearchContext(results: nil)
            return try req.view().render("search", context)
        }

        return req.withPooledConnection(to: .psql) { conn in
            var rows: [String] = []
            return conn.simpleQuery("SELECT * FROM \"User\" WHERE name = '\(nameToSearchFor)'") { row in
                rows.append(row.description)
            }.flatMap {
                let context = SearchContext(results: rows.joined(separator: " "))
                return try req.view().render("search", context)
            }
        }
    }
}

struct SearchContext: Encodable {
    let title = "SQL Injection"
    let results: String?
}
