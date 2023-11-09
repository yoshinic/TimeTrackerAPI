import FluentKit

enum TrainingRecordMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(TrainingRecordModel.schema)
                .id()
                .field(TrainingRecordModel.FieldKeys.v1.menuId, .uuid, .required)
                .field(TrainingRecordModel.FieldKeys.v1.startedAt, .datetime, .required)
                .field(TrainingRecordModel.FieldKeys.v1.endedAt, .datetime)
                .field(TrainingRecordModel.FieldKeys.v1.set, .int, .required)
                .field(TrainingRecordModel.FieldKeys.v1.weight, .float, .required)
                .field(TrainingRecordModel.FieldKeys.v1.number, .int, .required)
                .field(TrainingRecordModel.FieldKeys.v1.speed, .float, .required)
                .field(TrainingRecordModel.FieldKeys.v1.duration, .float, .required)
                .field(TrainingRecordModel.FieldKeys.v1.slope, .float, .required)

                .foreignKey(
                    TrainingRecordModel.FieldKeys.v1.menuId,
                    references: TrainingMenuModel.schema,
                    .id
                )

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(TrainingRecordModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {}

        func revert(on db: Database) async throws {}
    }
}
