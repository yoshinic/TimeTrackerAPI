import Foundation
import Fluent
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
    private let threadPool: NIOThreadPool
    private let eventLoopGroup: EventLoopGroup
    private let dbs: Databases
    private let db: Database

    private let envStorage = ProcessInfo.processInfo.environment["DATABASE_STORAGE"]
    private let envFilePath = ProcessInfo.processInfo.environment["DATABASE_FILEPATH"]
    private let fileDisposal = Bool(ProcessInfo.processInfo.environment["DATABASE_FILEDISPOSAL"] ?? "false")

    init() {
        // EventLoopGroupの作成
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

        // ThreadPoolの作成
        self.threadPool = NIOThreadPool(numberOfThreads: System.coreCount)
        self.threadPool.start()

        self.dbs = Databases(threadPool: threadPool, on: eventLoopGroup)
        dbs.default(to: .sqlite)
        self.db = self.dbs.database(
            logger: .init(label: "app.log"),
            on: self.dbs.eventLoopGroup.any()
        )!
    }

    func setDatabase(filePath: String? = nil) async throws {
        setDatabaseEnvironment(filePath: filePath)
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
}
