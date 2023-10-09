import Fluent

enum CategoryMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(CategoryModel.schema)
                .id()
                .field(CategoryModel.FieldKeys.v1.name, .string, .required)
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
        let names = ["未登録", "語学", "運動"]

        func prepare(on db: Database) async throws {
            for (i, name) in names.enumerated() {
                let new = CategoryModel(name: name, order: i + 1)
                try await new.create(on: db)
            }
        }

        func revert(on db: Database) async throws {
//            let service = CategoryService(db: db)
//            for name in names.reversed() {
//                try await service.delete(name: name)
//            }
        }
    }
}
