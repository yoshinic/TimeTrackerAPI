import FluentKit

enum DefaultMusclePartMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(DefaultMusclePartModel.schema)
                .id()
                .field(DefaultMusclePartModel.FieldKeys.v1.name, .string, .required)
                .field(DefaultMusclePartModel.FieldKeys.v1.order, .int, .required)

                .unique(on: DefaultMusclePartModel.FieldKeys.v1.name)

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(DefaultMusclePartModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {
            let data: [String] = [
                "首", "肩", "胸", "上背", "上腕二頭筋", "上腕三頭筋", "前腕",
                "腹", "下背", "大腿", "下腿", "その他",
            ]

            for (i, s) in data.enumerated() {
                if
                    let found = try await DefaultMusclePartModel
                    .query(on: db)
                    .filter(\.$name == s)
                    .first()
                {
                    found.order = i + 1
                    try await found.update(on: db)
                } else {
                    let m = DefaultMusclePartModel(name: s, order: i + 1)
                    try await m.create(on: db)
                }
            }
        }

        func revert(on db: Database) async throws {}
    }
}
