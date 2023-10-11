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
        color: String
    ) async throws -> CategoryData {
        guard
            let category = try await CategoryModel.create(
                .init(
                    id: id,
                    name: name,
                    color: color,
                    order: await CategoryModel.count(on: db) + 1
                ),
                on: db
            )
        else { throw AppError.duplicate }
        return .init(
            id: category.id!,
            name: category.name,
            color: category.color,
            order: category.order
        )
    }

    public func fetch(
        id: UUID? = nil,
        name: String? = nil,
        color: String? = nil
    ) async throws -> [CategoryData] {
        let a = try await CategoryModel.fetch(
            .init(id: id, name: name, color: color),
            on: db
        )
        return a.map {
            .init(
                id: $0.id!,
                name: $0.name,
                color: $0.color,
                order: $0.order
            )
        }
    }

    @discardableResult
    public func update(
        id: UUID,
        name: String? = nil,
        color: String? = nil,
        order: Int? = nil
    ) async throws -> CategoryData {
        let updated = try await CategoryModel.update(
            .init(
                id: id,
                name: name,
                color: color,
                order: order
            ),
            on: db
        )
        return .init(
            id: updated.id!,
            name: updated.name,
            color: updated.color,
            order: updated.order
        )
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
