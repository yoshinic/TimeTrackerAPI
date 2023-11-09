import FluentKit

enum DefaultTrainingMusclePartMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(DefaultTrainingMusclePartModel.schema)
                .field(
                    DefaultTrainingMusclePartModel.FieldKeys.v1.menuId,
                    .uuid,
                    .required
                )
                .field(
                    DefaultTrainingMusclePartModel.FieldKeys.v1.muscleId,
                    .uuid,
                    .required
                )
                .field(
                    DefaultTrainingMusclePartModel.FieldKeys.v1.effect,
                    .int,
                    .required
                )

                .compositeIdentifier(
                    over:
                    DefaultTrainingMusclePartModel.FieldKeys.v1.menuId,
                    DefaultTrainingMusclePartModel.FieldKeys.v1.muscleId
                )

                .foreignKey(
                    DefaultTrainingMusclePartModel.FieldKeys.v1.menuId,
                    references: DefaultTrainingMenuModel.schema,
                    .id
                )
                .foreignKey(
                    DefaultTrainingMusclePartModel.FieldKeys.v1.muscleId,
                    references: DefaultMuscleModel.schema,
                    .id
                )

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(DefaultTrainingMusclePartModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {}

        func revert(on db: Database) async throws {}
    }
}
