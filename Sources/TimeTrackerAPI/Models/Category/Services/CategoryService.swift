import FluentKit

public class CategoryService {
    private let db: Database

    init(db: Database) {
        self.db = db
    }

    @discardableResult
    public func create(
        id: UUID? = nil,
        name: String,
        color: String,
        icon: String
    ) async throws -> CategoryData? {
        try await CategoryModel
            .create(
                .init(
                    id: id,
                    name: name,
                    color: color,
                    icon: icon,
                    order: await CategoryModel.count(on: db) + 1
                ),
                on: db
            )
            .toData
    }

    public func fetch(
        id: UUID? = nil,
        name: String? = nil
    ) async throws -> [CategoryData] {
        try await CategoryModel
            .fetch(.init(id: id, name: name), on: db)
            .map { $0.toData }
    }

    @discardableResult
    public func update(
        id: UUID,
        name: String,
        color: String,
        icon: String,
        order: Int
    ) async throws -> CategoryData {
        try await CategoryModel
            .update(
                .init(
                    id: id,
                    name: name,
                    color: color,
                    icon: icon,
                    order: order
                ),
                on: db
            )
            .toData
    }

    // 与えられた配列の順番通りに order を設定し直す
    public func updateOrder(_ categories: [CategoryData]) async throws {
        for (i, category) in categories.enumerated() {
            try await update(
                id: category.id,
                name: category.name,
                color: category.color,
                icon: category.icon,
                order: i + 1
            )
        }
    }

    public func delete(
        id: UUID? = nil,
        name: String? = nil
    ) async throws {
        try await CategoryModel.delete(
            .init(id: id, name: name),
            on: db
        )
    }

    public func defaultCategory() async throws -> [CategoryData] {
        try await CategoryModel.defaultData(on: db).map { $0.toData }
    }
}

public struct CategoryData: Codable, Identifiable {
    public let id: UUID
    public let name: String
    public let color: String
    public let icon: String
    public let order: Int

    public init(
        id: UUID = UUID(),
        name: String,
        color: String,
        icon: String,
        order: Int
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
        self.order = order
    }
}

extension CategoryData: Hashable {}

extension CategoryModel {
    var toData: CategoryData {
        CategoryData(
            id: self.id!,
            name: self.name,
            color: self.color,
            icon: self.icon,
            order: self.order
        )
    }
}

extension DefaultCategoryModel {
    var toData: CategoryData {
        CategoryData(
            id: self.id!,
            name: self.name,
            color: self.color,
            icon: self.icon,
            order: self.order
        )
    }
}
