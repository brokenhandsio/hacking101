import FluentSQLite
import Vapor
import Leaf
import VaporSecurityHeaders
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentSQLiteProvider())
    try services.register(LeafProvider())
    try services.register(AuthenticationProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    var leafTagConfig = LeafTagConfig.default()
    leafTagConfig.use(Raw(), as: "raw")
    services.register(leafTagConfig)

    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)

    /// Security headers
    let cspValue = "default-src * 'unsafe-inline'"
    let cspConfig = ContentSecurityPolicyConfiguration(value: cspValue)
    let securityHeadersMiddlewareFactory = SecurityHeadersFactory().with(contentSecurityPolicy: cspConfig)
    services.register(securityHeadersMiddlewareFactory.build())

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    middlewares.use(SecurityHeaders.self)
    services.register(middlewares)

    // Configure a SQLite database
    let sqlite = try SQLiteDatabase(storage: .memory)

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Message.self, database: .sqlite)
    migrations.add(model: User.self, database: .sqlite)
    migrations.add(migration: DefaultUser.self, database: .sqlite)
    services.register(migrations)

}
