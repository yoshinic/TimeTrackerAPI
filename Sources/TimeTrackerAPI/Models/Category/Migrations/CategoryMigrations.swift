import FluentKit

enum CategoryMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(CategoryModel.schema)
                .id()
                .field(CategoryModel.FieldKeys.v1.name, .string, .required)
                .field(CategoryModel.FieldKeys.v1.color, .string, .required)
                .field(CategoryModel.FieldKeys.v1.icon, .string, .required)
                .field(CategoryModel.FieldKeys.v1.order, .int, .required)

                .unique(on: CategoryModel.FieldKeys.v1.name)

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(CategoryModel.schema).delete()
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

            let service = CategoryService(db: db)
            for e in data {
                try await service.create(name: e.name, color: e.color, icon: e.icon)
            }
        }

        func revert(on db: Database) async throws {
//            let service = CategoryService(db: db)
//            for e in data.reversed() {
//                try await service.delete(name: e.name)
//            }
        }
    }
}
