import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    try router.register(collection: WebsiteController())
    try router.register(collection: BankController())
    try router.register(collection: SearchController())
    try router.register(collection: AdminController())
}
