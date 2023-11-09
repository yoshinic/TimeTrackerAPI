import FluentKit

enum TrainingMusclePartMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(TrainingMusclePartModel.schema)
                .field(
                    TrainingMusclePartModel.FieldKeys.v1.menuId,
                    .uuid,
                    .required
                )
                .field(
                    TrainingMusclePartModel.FieldKeys.v1.muscleId,
                    .uuid,
                    .required
                )
                .field(
                    TrainingMusclePartModel.FieldKeys.v1.effect,
                    .int,
                    .required
                )

                .compositeIdentifier(
                    over:
                    TrainingMusclePartModel.FieldKeys.v1.menuId,
                    TrainingMusclePartModel.FieldKeys.v1.muscleId
                )

                .foreignKey(
                    TrainingMusclePartModel.FieldKeys.v1.menuId,
                    references: TrainingMenuModel.schema,
                    .id
                )
                .foreignKey(
                    TrainingMusclePartModel.FieldKeys.v1.muscleId,
                    references: MuscleModel.schema,
                    .id
                )

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(TrainingMusclePartModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {}

        func revert(on db: Database) async throws {}
    }
}
