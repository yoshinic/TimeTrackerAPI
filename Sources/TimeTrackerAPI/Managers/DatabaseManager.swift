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

    private let envStorage = ProcessInfo.processInfo.environment["DATABASE_STORAGE"]
    private let envFilePath = ProcessInfo.processInfo.environment["DATABASE_FILEPATH"]
    private let fileDisposal = Bool(ProcessInfo.processInfo.environment["DATABASE_FILEDISPOSAL"] ?? "false")

    init() {
        // EventLoopGroupの作成
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

        // ThreadPoolの作成
        self.threadPool = NIOThreadPool(numberOfThreads: System.coreCount)
        self.threadPool.start()

        dbs = Databases(threadPool: threadPool, on: eventLoopGroup)
        dbs.default(to: .sqlite)

        // 環境変数からSQLiteの保存先を取得
        if let envStorage = envStorage {
            if envStorage == "memory" {
                dbs.use(.sqlite(.memory), as: .sqlite)
            } else if envStorage == "file", let envFilePath = envFilePath {
                dbs.use(.sqlite(.file(envFilePath)), as: .sqlite)
            } else {
                fatalError("Invalid DATABASE_STORAGE or DATABASE_FILEPATH value")
            }
        } else {
            dbs.use(.sqlite(.memory), as: .sqlite)
        }

        // マイグレーションの実行
        Task {
            do {
                try await self.runMigrations()
            } catch {
                print("Error running migrations: \(error)")
            }
        }
    }

    private func runMigrations() async throws {
        // すべてのマイグレーションを実行
        try await AllMigrations.v1().prepare(on: self.database)
        try await AllMigrations.seed().prepare(on: self.database)
    }

    var database: Database {
        dbs.database(
            logger: .init(label: "app.log"),
            on: dbs.eventLoopGroup.any()
        )!
    }

    func shutdown() async throws {
        dbs.shutdown()
        try await threadPool.shutdownGracefully()
        try await eventLoopGroup.shutdownGracefully()
    }
}
