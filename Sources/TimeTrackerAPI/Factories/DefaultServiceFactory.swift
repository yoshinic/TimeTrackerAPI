import Fluent

public class DefaultServiceFactory {
    public static let shared = DefaultServiceFactory()

    private let database: Database

    public lazy var activity: ActivityService = .init(db: database)
    public lazy var record: RecordService = .init(db: database)

    private init() {
        self.database = DatabaseManager.shared.database
    }
}
