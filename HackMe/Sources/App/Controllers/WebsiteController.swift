import Vapor

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.get("xss", use: xssHandler)
        router.post("xss", use: xssPostHandler)
    }

    func indexHandler(_ req: Request) throws -> Future<View> {
        try ensureSessionSet(on: req)
        return try req.view().render("index", IndexContext())
    }

    func xssHandler(_ req: Request) throws -> Future<View> {
        try ensureSessionSet(on: req)
        let messages = Message.query(on: req).all()
        return try req.view().render("xss", XSSContext(messages: messages))
    }

    func xssPostHandler(_ req: Request) throws -> Future<Response> {
        let message = try req.content.syncDecode(Message.self)
        return message.save(on: req).transform(to: req.redirect(to: "/xss"))
    }

    func ensureSessionSet(on req: Request) throws {
        try req.session()["session"] = "true"
    }
    
}

struct IndexContext: Encodable {
    let title = "Homepage"
}

struct XSSContext: Encodable {
    let title = "XSS"
    let messages: Future<[Message]>
}
