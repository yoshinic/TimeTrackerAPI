import Fluent

public class DefaultServiceFactory {
    public static let shared: DefaultServiceFactory = .init()
    public static let dbm: DatabaseManager = .shared

    public lazy var category: CategoryService = .init(db: db)
    public lazy var activity: ActivityService = .init(db: db)
    public lazy var record: RecordService = .init(db: db)

    public func setDatabase(filePath: String? = nil) async throws {
        try await DatabaseManager.shared.setDatabase(filePath: filePath)
    }
}
