import Fluent

enum CategoryMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(CategoryModel.schema)
                .id()
                .field(CategoryModel.FieldKeys.v1.name, .string, .required)
                .field(CategoryModel.FieldKeys.v1.color, .string, .required)
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
        private let data: [CategoryTempData] = [
            ("未登録", "#FFFFFF"), ("語学", "#FF0000"), ("運動", "#00FF00"),
        ]

        func prepare(on db: Database) async throws {
            for (i, e) in data.enumerated() {
                let new = CategoryModel(name: e.name, color: e.color, order: i + 1)
                try await new.create(on: db)
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

private typealias CategoryTempData = (name: String, color: String)
