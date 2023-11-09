import FluentKit

enum DefaultMusclePartMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(DefaultMusclePartModel.schema)
                .id()
                .field(DefaultMusclePartModel.FieldKeys.v1.name, .string, .required)
                .field(DefaultMusclePartModel.FieldKeys.v1.order, .int, .required)

                .unique(on: DefaultMusclePartModel.FieldKeys.v1.name)

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(DefaultMusclePartModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {}

        func revert(on db: Database) async throws {}
    }
}
