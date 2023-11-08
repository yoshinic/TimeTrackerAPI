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
            let cs = CategoryService(db: db)
            guard
                let work = try await cs.fetch(name: "仕事").first,
                let lang = try await cs.fetch(name: "語学").first,
                let exce = try await cs.fetch(name: "運動").first,
                let daily = try await cs.fetch(name: "日常").first
            else {
                throw AppError.notFound
            }

            let data: [(cid: UUID?, name: String, color: String, icon: String)] = [
                (work.id, "作業", "#EE0000", "building"),
                (work.id, "移動", "#EE0000", "bicycle"),
                (lang.id, "リスニング", "#00BB00", "ear"),
                (lang.id, "リーディング", "#00BB00", "book"),
                (lang.id, "スピーキング", "#00BB00", "ellipsis.bubble"),
                (lang.id, "ライティング", "#00BB00", "highlighter"),
                (lang.id, "シャドーイング", "#00BB00", "bubble.left.and.bubble.right"),
                (exce.id, "ランニング", "#0000AA", "figure.run"),
                (exce.id, "ウェイトトレーニング", "#0000AA", "figure.strengthtraining.traditional"),
                (daily.id, "食事", "#00AAAA", "fork.knife"),
                (daily.id, "睡眠", "#00AAAA", "bed.double"),
                (daily.id, "買い物", "#00AAAA", "cart"),
            ]

            let service = ActivityService(db: db)

            for e in data {
                try await service.create(
                    categoryId: e.cid,
                    name: e.name,
                    color: e.color,
                    icon: e.icon
                )
            }
        }

        func revert(on _: Database) async throws {}
    }
}
