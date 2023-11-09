import FluentKit

enum TrainingMusclePartMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(TrainingMusclePartModel.schema)
                .id()
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

                .unique(
                    on:
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
        func prepare(on db: Database) async throws {
            let a = try await DefaultTrainingMusclePartModel
                .query(on: db)
                .all()

            for e in a {
                guard
                    try await TrainingMusclePartModel.find(e.id, on: db) == nil
                else { continue }

                try await TrainingMusclePartModel(
                    e.id,
                    menuId: e.$menu.id,
                    muscleId: e.$muscle.id,
                    effect: e.effect
                ).create(on: db)
            }
        }

        func revert(on db: Database) async throws {}
    }
}
