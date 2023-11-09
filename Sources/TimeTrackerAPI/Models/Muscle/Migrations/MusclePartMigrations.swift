import FluentKit

enum MusclePartMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(MusclePartModel.schema)
                .id()
                .field(MusclePartModel.FieldKeys.v1.name, .string, .required)
                .field(MusclePartModel.FieldKeys.v1.order, .int, .required)

                .unique(on: MusclePartModel.FieldKeys.v1.name)

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(MusclePartModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {}

        func revert(on db: Database) async throws {}
    }
}
