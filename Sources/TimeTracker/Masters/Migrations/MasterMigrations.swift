import Fluent

enum MasterMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await WorkMigrations.v1().prepare(on: db)
        }

        func revert(on db: Database) async throws  {
            try await WorkMigrations.v1().revert(on: db)
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await WorkMigrations.seed().prepare(on: db)
        }

        func revert(on db: Database) async throws {
            try await WorkMigrations.seed().revert(on: db)
        }
    }
}
