import FluentKit

enum DefaultTrainingMenuMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(DefaultTrainingMenuModel.schema)
                .id()
                .field(DefaultTrainingMenuModel.FieldKeys.v1.name, .string, .required)
                .field(DefaultTrainingMenuModel.FieldKeys.v1.aerobic, .bool, .required)
                .field(DefaultTrainingMenuModel.FieldKeys.v1.order, .int, .required)

                .unique(on: DefaultTrainingMenuModel.FieldKeys.v1.name)

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(DefaultTrainingMenuModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {}

        func revert(on db: Database) async throws {}
    }
}
