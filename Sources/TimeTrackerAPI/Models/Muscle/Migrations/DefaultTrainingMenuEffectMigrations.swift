import FluentKit

enum DefaultTrainingMenuEffectMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(DefaultTrainingMenuEffectModel.schema)
                .id()
                .field(
                    DefaultTrainingMenuEffectModel.FieldKeys.v1.trainingMenu,
                    .json,
                    .required
                )
                .field(
                    DefaultTrainingMenuEffectModel.FieldKeys.v1.trainingMenuEffect,
                    .json,
                    .required
                )

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(DefaultTrainingMenuEffectModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {
            let m = try await DefaultTrainingMenuEffectModel
                .query(on: db)
                .first()
            guard m == nil else { return }
            try await DefaultTrainingMenuEffectModel.create(on: db)
        }

        func revert(on db: Database) async throws {
            try await DefaultTrainingMenuEffectModel.query(on: db).delete()
        }
    }
}
