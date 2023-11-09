import FluentKit

enum TrainingMenuMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(TrainingMenuModel.schema)
                .id()
                .field(TrainingMenuModel.FieldKeys.v1.name, .string, .required)
                .field(TrainingMenuModel.FieldKeys.v1.aerobic, .bool, .required)
                .field(TrainingMenuModel.FieldKeys.v1.order, .int, .required)

                .unique(on: TrainingMenuModel.FieldKeys.v1.name)

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(TrainingMenuModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {}

        func revert(on db: Database) async throws {}
    }
}
