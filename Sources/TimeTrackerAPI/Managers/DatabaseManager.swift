import Foundation
import FluentSQLiteDriver
import NIO

// 本番用, シングルトン
final class DatabaseManager: _DatabaseManager {
    static let shared = DatabaseManager()
    override private init() {
        super.init()
    }
}

// 本番時とテスト時で分けるための（擬似）抽象クラス
class _DatabaseManager {
    private var threadPool: NIOThreadPool!
    private var eventLoopGroup: EventLoopGroup!

    private let envStorage = ProcessInfo.processInfo.environment["DATABASE_STORAGE"]
    private let envFilePath = ProcessInfo.processInfo.environment["DATABASE_FILEPATH"]

    var dbs: Databases!
    var db: Database!

    init() {
        // EventLoopGroupの作成
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

        // ThreadPoolの作成
        self.threadPool = NIOThreadPool(numberOfThreads: System.coreCount)
        self.threadPool.start()

        self.dbs = Databases(threadPool: threadPool, on: eventLoopGroup)
        dbs.default(to: .sqlite)
    }

    func setDatabase(filePath: String? = nil) async throws {
        setDatabaseEnvironment(filePath: filePath)

        db = dbs.database(
            .sqlite,
            logger: .init(label: "app.log"),
            on: dbs.eventLoopGroup.any()
        )!

        try await runMigrations()
    }

    private func setDatabaseEnvironment(filePath: String? = nil) {
        #if DEBUG
        // 環境変数からSQLiteの保存先を取得
        if let envStorage = envStorage, envStorage == "file", let envFilePath = envFilePath {
            dbs.use(.sqlite(.file(envFilePath)), as: .sqlite)
        } else {
            dbs.use(.sqlite(.memory), as: .sqlite)
        }
        #else
        if let filePath = filePath {
            dbs.use(.sqlite(.file(filePath)), as: .sqlite)
        } else {
            dbs.use(.sqlite(.memory), as: .sqlite)
        }
        #endif
    }

    private func runMigrations() async throws {
        try await AllMigrations.v1().prepare(on: db)
        try await AllMigrations.seed().prepare(on: db)
    }

    func shutdown() async throws {
        dbs.shutdown()
        try await threadPool.shutdownGracefully()
        try await eventLoopGroup.shutdownGracefully()
    }

    deinit {
        self.dbs.shutdown()
        self.dbs = nil
        try? self.threadPool.syncShutdownGracefully()
        self.threadPool = nil
        try? self.eventLoopGroup.syncShutdownGracefully()
        self.eventLoopGroup = nil
    }
}
