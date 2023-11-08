import FluentKit

enum AllMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await DefaultCategoryMigrations.v1().prepare(on: db)
            try await DefaultActivityMigrations.v1().prepare(on: db)
            
            try await CategoryMigrations.v1().prepare(on: db)
            try await ActivityMigrations.v1().prepare(on: db)

            try await RecordMigrations.v1().prepare(on: db)
        }

        func revert(on db: Database) async throws  {
            try await RecordMigrations.v1().revert(on: db)

            try await ActivityMigrations.v1().revert(on: db)
            try await CategoryMigrations.v1().revert(on: db)
            
            try await DefaultActivityMigrations.v1().revert(on: db)
            try await DefaultCategoryMigrations.v1().revert(on: db)
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await DefaultCategoryMigrations.seed().prepare(on: db)
            try await DefaultActivityMigrations.seed().prepare(on: db)
            
            try await CategoryMigrations.seed().prepare(on: db)
            try await ActivityMigrations.seed().prepare(on: db)

            try await RecordMigrations.seed().prepare(on: db)
        }

        func revert(on db: Database) async throws {
            try await RecordMigrations.seed().revert(on: db)

            try await ActivityMigrations.seed().revert(on: db)
            try await CategoryMigrations.seed().revert(on: db)
            
            try await DefaultActivityMigrations.seed().revert(on: db)
            try await DefaultCategoryMigrations.seed().revert(on: db)
        }
    }
}
