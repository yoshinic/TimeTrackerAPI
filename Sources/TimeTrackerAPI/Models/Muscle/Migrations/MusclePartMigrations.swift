import FluentKit

enum MusclePartMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(MusclePartModel.schema)
                .id()
                .field(MusclePartModel.FieldKeys.v1.name, .string, .required)
                .field(MusclePartModel.FieldKeys.v1.order, .int, .required)

                .unique(on: MusclePartModel.FieldKeys.v1.name)

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(MusclePartModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {
            let a = try await DefaultMusclePartModel.query(on: db).all()
            for e in a {
                guard
                    try await MusclePartModel.find(e.id, on: db) == nil
                else { continue }

                let m = MusclePartModel(
                    e.id,
                    name: e.name,
                    order: e.order
                )
                try await m.create(on: db)
            }
        }

        func revert(on db: Database) async throws {}
    }
}
