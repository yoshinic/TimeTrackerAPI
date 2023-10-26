import FluentKit

enum RecordMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(RecordModel.schema)
                .id()
                .field(RecordModel.FieldKeys.v1.activityId, .uuid)
                .field(RecordModel.FieldKeys.v1.startedAt, .datetime, .required)
                .field(RecordModel.FieldKeys.v1.endedAt, .datetime)
                .field(RecordModel.FieldKeys.v1.note, .string, .required)

                .foreignKey(
                    RecordModel.FieldKeys.v1.activityId,
                    references: ActivityModel.schema,
                    .id
                )

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(RecordModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on _: Database) async throws {}

        func revert(on _: Database) async throws {}
    }
}
