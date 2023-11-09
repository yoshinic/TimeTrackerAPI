import FluentKit

enum DefaultMusclePartDetailMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(DefaultMusclePartDetailModel.schema)
                .id()
                .field(
                    DefaultMusclePartDetailModel.FieldKeys.v1.musclePartId,
                    .uuid,
                    .required
                )
                .field(
                    DefaultMusclePartDetailModel.FieldKeys.v1.name,
                    .string,
                    .required
                )
                .field(
                    DefaultMusclePartDetailModel.FieldKeys.v1.order,
                    .int,
                    .required
                )

                .unique(
                    on:
                    DefaultMusclePartDetailModel.FieldKeys.v1.musclePartId,
                    DefaultMusclePartDetailModel.FieldKeys.v1.name
                )

                .foreignKey(
                    DefaultMusclePartDetailModel.FieldKeys.v1.musclePartId,
                    references: DefaultMusclePartModel.schema,
                    .id
                )

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(DefaultMusclePartDetailModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {}

        func revert(on db: Database) async throws {}
    }
}
