import FluentKit

enum MusclePartDetailMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(MusclePartDetailModel.schema)
                .id()
                .field(
                    MusclePartDetailModel.FieldKeys.v1.musclePartId,
                    .uuid,
                    .required
                )
                .field(
                    MusclePartDetailModel.FieldKeys.v1.name,
                    .string,
                    .required
                )
                .field(
                    MusclePartDetailModel.FieldKeys.v1.order,
                    .int,
                    .required
                )

                .unique(
                    on:
                    MusclePartDetailModel.FieldKeys.v1.musclePartId,
                    MusclePartDetailModel.FieldKeys.v1.name
                )

                .foreignKey(
                    MusclePartDetailModel.FieldKeys.v1.musclePartId,
                    references: MusclePartModel.schema,
                    .id
                )

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(MusclePartDetailModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {}

        func revert(on db: Database) async throws {}
    }
}
