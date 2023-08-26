import Fluent

class DefaultServiceFactory {
    static let shared = DefaultServiceFactory()

    private let database: Database

    lazy var activity: ActivityService = .init(db: database)

    lazy var record: RecordService = .init(db: database)

    private init() {
        self.database = DatabaseManager().database
    }
}
