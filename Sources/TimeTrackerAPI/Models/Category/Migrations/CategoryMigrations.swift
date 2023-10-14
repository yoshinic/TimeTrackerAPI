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
                .unique(on: CategoryModel.FieldKeys.v1.order)
                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(CategoryModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        private let data: [CategoryData] = [
            CategoryModel.default,
            .init(id: UUID(), name: "語学", color: "#FF0000", order: 2),
            .init(id: UUID(), name: "運動", color: "00FF00", order: 3),
        ]

        func prepare(on db: Database) async throws {
            for e in data {
                let new = CategoryModel(
                    e.id,
                    name: e.name,
                    color: e.color,
                    order: e.order
                )
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
