import Fluent

enum WorkMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(WorkModel.schema)
                .id()
                .field(WorkModel.FieldKeys.v1.name, .string, .required)
                .field(WorkModel.FieldKeys.v1.color, .string, .required)
                .unique(on: WorkModel.FieldKeys.v1.name)
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(WorkModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on _: Database) async throws {}

        func revert(on _: Database) async throws {}
    }
}
