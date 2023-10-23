import Fluent

public class DatabaseServiceManager {
    public static let shared: DatabaseServiceManager = .init()

    let dbm: DatabaseManager = .shared
    public var category: CategoryService!
    public var activity: ActivityService!
    public var record: RecordService!

    private init() {}
    
    public func setDatabase(filePath: String? = nil) async throws {
        try await dbm.setDatabase(filePath: filePath)
        category = .init(db: dbm.db)
        activity = .init(db: dbm.db)
        record = .init(db: dbm.db)
    }
}
