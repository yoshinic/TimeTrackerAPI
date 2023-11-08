import FluentKit

enum DefaultActivityMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(DefaultActivityModel.schema)
                .id()
                .field(DefaultActivityModel.FieldKeys.v1.name, .string, .required)
                .field(DefaultActivityModel.FieldKeys.v1.categoryId, .uuid)
                .field(DefaultActivityModel.FieldKeys.v1.color, .string, .required)
                .field(DefaultActivityModel.FieldKeys.v1.icon, .string, .required)
                .field(DefaultActivityModel.FieldKeys.v1.order, .int, .required)

                .foreignKey(
                    DefaultActivityModel.FieldKeys.v1.categoryId,
                    references: DefaultCategoryModel.schema,
                    .id
                )

                .unique(on: DefaultActivityModel.FieldKeys.v1.name)

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(DefaultActivityModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {
            let cs = try await DefaultCategoryModel.query(on: db).all()
            guard
                let work = cs.filter({ $0.name == "仕事" }).first,
                let lang = cs.filter({ $0.name == "語学" }).first,
                let exce = cs.filter({ $0.name == "運動" }).first,
                let daily = cs.filter({ $0.name == "日常" }).first
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

            var order = 0
            var categoryId: UUID? = nil
            for e in data {
                if e.cid != categoryId {
                    order = 0
                    categoryId = e.cid
                }

                let m: DefaultActivityModel = .init(
                    categoryId: e.cid,
                    name: e.name,
                    color: e.color,
                    icon: e.icon,
                    order: order + 1
                )
                try await m.save(on: db)

                order += 1
            }
        }

        func revert(on _: Database) async throws {}
    }
}
