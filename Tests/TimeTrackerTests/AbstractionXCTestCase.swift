@testable import TimeTracker
import XCTest
import FluentSQLiteDriver
import NIO

// 参考
// https://github.com/vapor/fluent-sqlite-driver/blob/main/Tests/FluentSQLiteDriverTests/FluentSQLiteDriverTests.swift

class AbstractionXCTestCase: XCTestCase {
    private var threadPool: NIOThreadPool!
    private var eventLoopGroup: EventLoopGroup!
    private var dbs: Databases!
    var db: Database!

    private let sqliteFilePath = FileManager
        .default
        .temporaryDirectory
        .appendingPathComponent("test.sqlite")
        .absoluteString

    private let sqliteFileHomePath = FileManager
        .default
        .homeDirectoryForCurrentUser
        .appendingPathComponent("test.sqlite")
        .absoluteString

    override func setUp() async throws {
        try await super.setUp()

        XCTAssert(isLoggingConfigured)

        eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        threadPool = .init(numberOfThreads: System.coreCount)
        threadPool.start()
        dbs = Databases(threadPool: threadPool, on: eventLoopGroup)
        dbs.use(.sqlite(.memory), as: .sqlite)
        dbs.use(.sqlite(.file(sqliteFileHomePath)), as: .sqlite)
        dbs.default(to: .sqlite)

        precondition(
            dbs.ids().count >= 1,
            "Databases instance must have 2 or more registered databases"
        )

        db = dbs.database(
            logger: .init(label: "app.log"),
            on: dbs.eventLoopGroup.any()
        )!
    }

    override func tearDown() async throws {
        dbs.shutdown()
        dbs = nil
        try await threadPool.shutdownGracefully()
        threadPool = nil
        try await eventLoopGroup.shutdownGracefully()
        eventLoopGroup = nil

        if let url = URL(string: sqliteFileHomePath) {
            try FileManager.default.removeItem(at: url)
        }

        try await super.tearDown()
    }

    func migration(
        with closure: (Database) async throws -> Void
    ) async throws {
        try await MasterMigrations.v1().prepare(on: db)
        try await MasterMigrations.seed().prepare(on: db)

        try await DataMigrations.v1().prepare(on: db)
        try await DataMigrations.seed().prepare(on: db)

        try await closure(db)

        try await DataMigrations.v1().revert(on: db)
    //        try await MasterMigrations.seed().revert(on: db)
        try await MasterMigrations.v1().revert(on: db)
    }
}

private func env(_ name: String) -> String? {
    return ProcessInfo.processInfo.environment[name]
}

private let isLoggingConfigured: Bool = {
    LoggingSystem.bootstrap { label in
        var handler = StreamLogHandler.standardOutput(label: label)
        handler.logLevel = env("LOG_LEVEL").flatMap { Logger.Level(rawValue: $0) } ?? .debug
        return handler
    }
    return true
}()
