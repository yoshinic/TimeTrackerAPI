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
        func prepare(on db: Database) async throws {
            let a = try await DefaultMusclePartDetailModel.query(on: db).all()
            for e in a {
                guard
                    try await MusclePartDetailModel.find(e.id, on: db) == nil
                else { continue }

                let m = MusclePartDetailModel(
                    e.id,
                    musclePartId: e.$musclePart.id,
                    name: e.name,
                    order: e.order
                )
                try await m.create(on: db)
            }
        }

        func revert(on db: Database) async throws {}
    }
}
