import FluentPostgreSQL
import Vapor
import Leaf
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    
    //Leaf Setup
    try services.register(LeafProvider())
    
    //Authentication
    try services.register(AuthenticationProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    
    services.register(middlewares)

    // Configure a database
    var databases = DatabasesConfig()
    
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let databaseName: String
    let databasePort: Int
    if (env == .testing) {
        databaseName = "schooltime-test"
        if let testPort = Environment.get("DATABASE_PORT") {
            databasePort = Int(testPort) ?? 5433
        } else {
            databasePort = 5433
        }
    } else {
        databaseName = "schooltime"
        databasePort = 5432
    }

    // Register the configured SQLite database to the database config.
    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: hostname,
        port: databasePort,
        username: "vaporschool",
        database: databaseName,
        password: "a3eilm2s2y")
    
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    services.register(databases)
    
  
    // Configure migrations
    var migrations = MigrationConfig()
    
    migrations.add(migration: UserType.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
    
    migrations.add(model: School.self, database: .psql)
    
    migrations.add(migration: GradeType.self, database: .psql)
    migrations.add(model: Grade.self, database: .psql)

    migrations.add(model: Room.self, database: .psql)
    
    migrations.add(migration: ZoneType.self, database: .psql)
    migrations.add(model: Zone.self, database: .psql)

    migrations.add(migration: GenderType.self, database: .psql)
    migrations.add(model: Student.self, database: .psql)
    
    migrations.add(migration: DepartmentType.self, database: .psql)
    migrations.add(model: Teacher.self, database: .psql)
    
    migrations.add(model: RoomTeacherPivot.self, database: .psql)
    
    migrations.add(model: ParentFamily.self, database: .psql)
    
    migrations.add(migration: SubjectLevel.self, database: .psql)
    migrations.add(model: Subject.self, database: .psql)
    
    migrations.add(model: Lesson.self, database: .psql)
    
    migrations.add(model: Token.self, database: .psql)
    
    migrations.add(migration: AdminUser.self, database: .psql)
    
    services.register(migrations)
    
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
    
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
}
