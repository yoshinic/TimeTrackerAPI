import FluentKit

enum DefaultMuscleMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(DefaultMuscleModel.schema)
                .id()
                .field(DefaultMuscleModel.FieldKeys.v1.name, .string, .required)
                .field(DefaultMuscleModel.FieldKeys.v1.muscleDetail, .string, .required)
                .field(DefaultMuscleModel.FieldKeys.v1.ruby, .string, .required)
                .field(
                    DefaultMuscleModel.FieldKeys.v1.musclePartId,
                    .uuid,
                    .required
                )
                .field(
                    DefaultMuscleModel.FieldKeys.v1.musclePartDetailId,
                    .uuid
                )
                .field(DefaultMuscleModel.FieldKeys.v1.order, .int, .required)

                .foreignKey(
                    DefaultMuscleModel.FieldKeys.v1.musclePartId,
                    references: MusclePartModel.schema,
                    .id
                )
                .foreignKey(
                    DefaultMuscleModel.FieldKeys.v1.musclePartDetailId,
                    references: MusclePartDetailModel.schema,
                    .id
                )

                .unique(on: DefaultMuscleModel.FieldKeys.v1.name,
                        DefaultMuscleModel.FieldKeys.v1.muscleDetail)

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(DefaultMuscleModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {}

        func revert(on db: Database) async throws {}
    }
}
