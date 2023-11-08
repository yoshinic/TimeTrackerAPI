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
            let defaultCategories = try await DefaultCategoryModel.query(on: db).all()
            for category in defaultCategories {
                try await CategoryModel.create(
                    .init(
                        id: category.id,
                        name: category.name,
                        color: category.color,
                        icon: category.icon,
                        order: category.order
                    ),
                    on: db
                )
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
