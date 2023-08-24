import Fluent

enum DataMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await RecordMigrations.v1().prepare(on: db)
        }

        func revert(on db: Database) async throws  {
            try await RecordMigrations.v1().revert(on: db)
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await RecordMigrations.seed().prepare(on: db)
        }

        func revert(on db: Database) async throws {
            try await RecordMigrations.seed().revert(on: db)
        }
    }
}
