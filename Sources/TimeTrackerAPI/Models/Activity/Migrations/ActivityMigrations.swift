import FluentKit

enum ActivityMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(ActivityModel.schema)
                .id()
                .field(ActivityModel.FieldKeys.v1.name, .string, .required)
                .field(ActivityModel.FieldKeys.v1.categoryId, .uuid)
                .field(ActivityModel.FieldKeys.v1.color, .string, .required)
                .field(ActivityModel.FieldKeys.v1.icon, .string, .required)
                .field(ActivityModel.FieldKeys.v1.order, .int, .required)

                .foreignKey(
                    ActivityModel.FieldKeys.v1.categoryId,
                    references: CategoryModel.schema,
                    .id
                )

                .unique(on: ActivityModel.FieldKeys.v1.name)

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(ActivityModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {
            let defaultActivities = try await DefaultActivityModel
                .query(on: db)
                .all()
            for activity in defaultActivities {
                guard
                    let aid = activity.id,
                    try await ActivityModel.find(aid, on: db) == nil
                else { continue }
                try await ActivityModel.create(
                    .init(
                        id: aid,
                        categoryId: activity.$category.id,
                        name: activity.name,
                        color: activity.color,
                        icon: activity.icon,
                        order: activity.order
                    ),
                    on: db
                )
            }
        }

        func revert(on _: Database) async throws {}
    }
}
