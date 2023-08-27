import Fluent

enum ActivityMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(ActivityModel.schema)
                .id()
                .field(ActivityModel.FieldKeys.v1.name, .string, .required)
                .field(ActivityModel.FieldKeys.v1.color, .string, .required)
                .field(ActivityModel.FieldKeys.v1.order, .int, .required)
                .unique(on: ActivityModel.FieldKeys.v1.name)
                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(ActivityModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on _: Database) async throws {}

        func revert(on _: Database) async throws {}
    }
}
