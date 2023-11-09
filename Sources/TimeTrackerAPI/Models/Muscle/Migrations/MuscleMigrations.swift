import FluentKit

enum MuscleMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(MuscleModel.schema)
                .id()
                .field(MuscleModel.FieldKeys.v1.name, .string, .required)
                .field(MuscleModel.FieldKeys.v1.muscleDetail, .string, .required)
                .field(MuscleModel.FieldKeys.v1.ruby, .string, .required)
                .field(
                    MuscleModel.FieldKeys.v1.musclePartId,
                    .uuid,
                    .required
                )
                .field(
                    MuscleModel.FieldKeys.v1.musclePartDetailId,
                    .uuid
                )
                .field(MuscleModel.FieldKeys.v1.order, .int, .required)

                .foreignKey(
                    MuscleModel.FieldKeys.v1.musclePartId,
                    references: MusclePartModel.schema,
                    .id
                )
                .foreignKey(
                    MuscleModel.FieldKeys.v1.musclePartDetailId,
                    references: MusclePartDetailModel.schema,
                    .id
                )

                .unique(on: MuscleModel.FieldKeys.v1.name,
                        MuscleModel.FieldKeys.v1.muscleDetail)

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(MuscleModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {}

        func revert(on db: Database) async throws {}
    }
}
