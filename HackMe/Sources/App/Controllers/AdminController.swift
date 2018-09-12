import Vapor
import Authentication

struct AdminController: RouteCollection {
    func boot(router: Router) throws {
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
        let adminRoutes = authSessionRoutes.grouped("admin")

        adminRoutes.get("login", use: loginHandler)
        adminRoutes.post(UserLoginData.self, at: "login", use: loginPostHandler)

        let protectedRoutes = adminRoutes.grouped(RedirectMiddleware<User>(path: "/admin/login"))
        protectedRoutes.get(use: adminIndex)
        protectedRoutes.get("logout", use: logoutHandler)
        protectedRoutes.post("cookie", use: cookieAdminRoute)
        protectedRoutes.get("query", use: queryAdminRotue)
    }

    func loginHandler(_ req: Request) throws -> Future<View> {
        return try req.view().render("login", ["title": "Login"])
    }

    func loginPostHandler(_ req: Request, userLoginData: UserLoginData) throws -> Future<Response> {
        return User.authenticate(username: userLoginData.username, password: userLoginData.password, using: BCryptDigest(), on: req).map(to: Response.self) { user in
            guard let user = user else {
                return req.redirect(to: "/admin/login")
            }
            try req.authenticateSession(user)
            return req.redirect(to: "/admin")
        }
    }

    func logoutHandler(_ req: Request) throws -> Response {
        try req.unauthenticateSession(User.self)
        return req.redirect(to: "/admin/login")
    }

    func adminIndex(_ req: Request) throws -> Future<Response> {
        let user = try req.requireAuthenticated(User.self)
        
        let context = AdminContext(isAdmin: user.admin)
        return try req.view().render("admin", context).flatMap(to: Response.self) { view in
            try view.encode(for: req)
        }.map { response in
            response.http.cookies["isAdmin"] = HTTPCookieValue(string: user.admin ? "true" : "false")
            return response
        }
    }

    func cookieAdminRoute(_ req: Request) throws -> Future<View> {
        guard req.http.cookies["isAdmin"]?.string == "true" else {
            let context = AdminActionContext(message: "You must be an admin to do this!")
            return try req.view().render("adminAction", context)
        }
        let context = AdminActionContext(message: "Admin action successfully performed")
        return try req.view().render("adminAction", context)
    }

    func queryAdminRotue(_ req: Request) throws -> Future<View> {
        guard let isAdmin = req.query[Bool.self, at: "admin"], isAdmin else {
            let context = AdminActionContext(message: "You must be an admin to do this!")
            return try req.view().render("adminAction", context)
        }
        let context = AdminActionContext(message: "Admin action successfully performed")
        return try req.view().render("adminAction", context)
    }
}

struct AdminContext: Encodable {
    let title = "Admin"
    let isAdmin: Bool
}

struct AdminActionContext: Encodable {
    let message: String
}
