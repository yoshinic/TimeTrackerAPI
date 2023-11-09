import FluentKit

enum DefaultCategoryMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(DefaultCategoryModel.schema)
                .id()
                .field(DefaultCategoryModel.FieldKeys.v1.name, .string, .required)
                .field(DefaultCategoryModel.FieldKeys.v1.color, .string, .required)
                .field(DefaultCategoryModel.FieldKeys.v1.icon, .string, .required)
                .field(DefaultCategoryModel.FieldKeys.v1.order, .int, .required)

                .unique(on: DefaultCategoryModel.FieldKeys.v1.name)

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(DefaultCategoryModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {
            let data: [(name: String, color: String, icon: String)] = [
                (name: "仕事", color: "#EE0000", icon: "bag"),
                (name: "語学", color: "#00CC00", icon: "person.line.dotted.person"),
                (name: "運動", color: "0000DD", icon: "figure.strengthtraining.functional"),
                (name: "日常", color: "5555AA", icon: "house"),
            ]

            for (i, e) in data.enumerated() {
                if
                    let found = try await DefaultCategoryModel
                    .query(on: db)
                    .filter(\.$name == e.name)
                    .first()
                {
                    found.color = e.color
                    found.icon = e.icon
                    found.order = i + 1
                    try await found.update(on: db)
                } else {
                    let m: DefaultCategoryModel = .init(
                        name: e.name,
                        color: e.color,
                        icon: e.icon,
                        order: i + 1
                    )
                    try await m.create(on: db)
                }
            }
        }

        func revert(on db: Database) async throws {}
    }
}
