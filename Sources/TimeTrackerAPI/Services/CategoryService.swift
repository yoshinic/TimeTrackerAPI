import FluentKit

public class CategoryService {
    public static let defaultId: UUID = CategoryModel.defaultId

    private let db: Database

    init(db: Database) {
        self.db = db
    }

    @discardableResult
    public func create(
        id: UUID? = nil,
        name: String,
        color: String
    ) async throws -> CategoryData? {
        try await CategoryModel
            .create(
                .init(
                    id: id,
                    name: name,
                    color: color,
                    order: await CategoryModel.count(on: db) + 1
                ),
                on: db
            )
            .toData
    }

    public func fetch(
        id: UUID? = nil,
        name: String? = nil,
        color: String? = nil
    ) async throws -> [CategoryData] {
        try await CategoryModel
            .fetch(
                .init(id: id, name: name, color: color),
                on: db
            )
            .map { $0.toData }
    }

    @discardableResult
    public func update(
        id: UUID,
        name: String? = nil,
        color: String? = nil,
        order: Int? = nil
    ) async throws -> CategoryData {
        try await CategoryModel
            .update(
                .init(
                    id: id,
                    name: name,
                    color: color,
                    order: order
                ),
                on: db
            )
            .toData
    }

    // 与えられた配列の順番通りに order を設定し直す
    public func updateOrder(ids: [UUID]) async throws {
        for (i, id) in ids.enumerated() {
            try await update(id: id, order: i + 1)
        }
    }

    public func delete(
        id: UUID? = nil,
        name: String? = nil,
        color: String? = nil
    ) async throws {
        try await CategoryModel.delete(
            .init(id: id, name: name, color: color),
            on: db
        )
    }
}

public struct CategoryData: Codable, Identifiable {
    public let id: UUID
    public let name: String
    public let color: String
    public let order: Int

    public init(
        id: UUID,
        name: String,
        color: String,
        order: Int
    ) {
        self.id = id
        self.name = name
        self.color = color
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
            order: self.order
        )
    }
}
