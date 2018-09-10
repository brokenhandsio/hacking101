import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get { req -> Future<View> in
        return try req.view().render("index", IndexContext())
    }
}

struct IndexContext: Encodable {
    let title = "Homepage"
}
