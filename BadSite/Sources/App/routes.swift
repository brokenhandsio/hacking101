import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get("csrfAttack") { req -> Future<View> in
        return try req.view().render("csrfAttack", CSRFAttackContext())
    }
}

struct CSRFAttackContext: Encodable {
    let title = "Homepage"
}
