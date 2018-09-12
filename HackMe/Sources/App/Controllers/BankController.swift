import Vapor
import Crypto
import Authentication

struct BankController: RouteCollection {
    func boot(router: Router) throws {
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
        let routeCollection = authSessionRoutes.grouped("bank")

        routeCollection.get("login", use: loginHandler)
        routeCollection.post(UserLoginData.self, at: "login", use: loginPostHandler)

        let protectedRoutes = routeCollection.grouped(RedirectMiddleware<User>(path: "/bank/login"))
        protectedRoutes.get("logout", use: logoutHandler)
        protectedRoutes.get("transfer", use: transferHandler)
        protectedRoutes.post(TransferData.self, at: "transfer", use: transferPostHandler)
    }

    func loginHandler(_ req: Request) throws -> Future<View> {
        return try req.view().render("login", ["title": "admin"])
    }

    func loginPostHandler(_ req: Request, userLoginData: UserLoginData) throws -> Future<Response> {
        return User.authenticate(username: userLoginData.username, password: userLoginData.password, using: BCryptDigest(), on: req).map(to: Response.self) { user in
            guard let user = user else {
                return req.redirect(to: "/bank/login")
            }
            try req.authenticateSession(user)
            return req.redirect(to: "/bank/transfer")
        }
    }

    func logoutHandler(_ req: Request) throws -> Response {
        try req.unauthenticateSession(User.self)
        return req.redirect(to: "/")
    }

    func transferHandler(_ req: Request) throws -> Future<View> {
        let user = try req.requireAuthenticated(User.self)
        let context = TransferContext(currentBalance: user.bankBalance)
        return try req.view().render("transfer", context)
    }

    func transferPostHandler(_ req: Request, data: TransferData) throws -> Future<View> {
        let user = try req.requireAuthenticated(User.self)
        user.bankBalance = user.bankBalance - data.amount
        return user.save(on: req).map { user in
            return TransferCompleteContext(amount: data.amount, toAccount: data.toAccount, newBalance: user.bankBalance)
        }.flatMap { context in
            return try req.view().render("transferComplete", context)
        }
    }
}

struct TransferContext: Encodable {
    let title = "Transfer Money"
    let currentBalance: Int
}

struct TransferData: Content {
    let toAccount: String
    let amount: Int
}

struct TransferCompleteContext: Encodable {
    let title = "Transfer Complete"
    let amount: Int
    let toAccount: String
    let newBalance: Int
}
