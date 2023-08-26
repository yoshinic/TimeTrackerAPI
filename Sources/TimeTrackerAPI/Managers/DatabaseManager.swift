import Foundation
import Fluent
import FluentSQLiteDriver
import NIO

final class DatabaseManager {
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
