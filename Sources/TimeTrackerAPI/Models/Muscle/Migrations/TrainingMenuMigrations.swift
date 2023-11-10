import FluentKit

enum TrainingMenuMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(TrainingMenuModel.schema)
                .id()
                .field(TrainingMenuModel.FieldKeys.v1.name, .string, .required)
                .field(TrainingMenuModel.FieldKeys.v1.mainPart, .uuid, .required)
                .field(TrainingMenuModel.FieldKeys.v1.aerobic, .bool, .required)
                .field(TrainingMenuModel.FieldKeys.v1.order, .int, .required)

                .foreignKey(
                    TrainingMenuModel.FieldKeys.v1.mainPart,
                    references: MusclePartModel.schema,
                    .id
                )

                .unique(on: TrainingMenuModel.FieldKeys.v1.name)

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(TrainingMenuModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {
            let a = try await DefaultTrainingMenuModel.query(on: db).all()
            for e in a {
                guard
                    try await TrainingMenuModel.find(e.id, on: db) == nil
                else { continue }

                try await TrainingMenuModel(
                    e.id,
                    name: e.name,
                    mainPartId: e.$mainPart.id,
                    aerobic: e.aerobic,
                    order: e.order
                ).create(on: db)
            }
        }

        func revert(on db: Database) async throws {}
    }
}
