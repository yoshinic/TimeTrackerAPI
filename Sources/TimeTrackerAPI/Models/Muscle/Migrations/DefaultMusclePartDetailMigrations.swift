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
        func prepare(on db: Database) async throws {
            let defaultMuscleParts = try await DefaultMusclePartModel
                .query(on: db)
                .all()

            guard
                let back2 = defaultMuscleParts.filter({ $0.name == "下背" }).first,
                let thigh1 = defaultMuscleParts.filter({ $0.name == "大腿" }).first
            else { throw AppError.notFound }

            let data: [(musclePartId: UUID, name: String)] = [
                (back2.id!, "脊柱起立筋"),
                (back2.id!, "下部深背諸筋"),
                (thigh1.id!, "大腿四頭筋"),
                (thigh1.id!, "ハムストリング"),
            ]
            
            var order = 1
            var musclePartId: UUID? = nil
            for e in data {
                if e.musclePartId != musclePartId {
                    order = 1
                    musclePartId = e.musclePartId
                }

                if
                    let found = try await DefaultMusclePartDetailModel
                    .query(on: db)
                    .filter(\.$musclePart.$id == e.musclePartId)
                    .filter(\.$name == e.name)
                    .first()
                {
                    found.order = order
                    try await found.update(on: db)
                } else {
                    let m = DefaultMusclePartDetailModel(
                        musclePartId: e.musclePartId,
                        name: e.name,
                        order: order
                    )
                    try await m.create(on: db)
                }

                order += 1
            }
        }

        func revert(on db: Database) async throws {}
    }
}
