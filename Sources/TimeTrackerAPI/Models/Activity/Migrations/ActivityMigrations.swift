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
            let cs = CategoryService(db: db)
            guard
                let work = try await cs.fetch(name: "仕事").first,
                let lang = try await cs.fetch(name: "語学").first,
                let exce = try await cs.fetch(name: "運動").first
            else {
                throw AppError.notFound
            }

            let data: [(cid: UUID?, name: String, color: String)] = [
                (work.id, "作業", "#AA0000"),
                (lang.id, "リスニング", "$00AA00"),
                (lang.id, "リーディング", "$00AA00"),
                (lang.id, "スピーキング", "$00AA00"),
                (lang.id, "ライティング", "$00AA00"),
                (exce.id, "ウェイトトレーニング", "$0000AA"),
                (exce.id, "ランニング", "$0000AA"),
            ]

            let service = ActivityService(db: db)

            for e in data {
                try await service.create(
                    categoryId: e.cid,
                    name: e.name,
                    color: e.color
                )
            }
        }

        func revert(on _: Database) async throws {}
    }
}
