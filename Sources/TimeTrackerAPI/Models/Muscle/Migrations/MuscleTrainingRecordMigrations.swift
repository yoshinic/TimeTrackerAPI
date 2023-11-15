import FluentKit

enum MuscleTrainingRecordMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(MuscleTrainingRecordModel.schema)
                .id()
                .field(
                    MuscleTrainingRecordModel.FieldKeys.v1.recordId,
                    .uuid,
                    .required
                )
                .field(
                    MuscleTrainingRecordModel.FieldKeys.v1.trainingRecordId,
                    .uuid,
                    .required
                )

                .foreignKey(
                    MuscleTrainingRecordModel.FieldKeys.v1.recordId,
                    references: RecordModel.schema,
                    .id
                )
                .foreignKey(
                    MuscleTrainingRecordModel.FieldKeys.v1.trainingRecordId,
                    references: TrainingRecordModel.schema,
                    .id
                )

                .unique(
                    on:
                    MuscleTrainingRecordModel.FieldKeys.v1.recordId,
                    MuscleTrainingRecordModel.FieldKeys.v1.trainingRecordId
                )

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(MuscleTrainingRecordModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {}

        func revert(on db: Database) async throws {}
    }
}
