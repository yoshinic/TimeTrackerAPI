import FluentKit

public class CategoryService {
    private let db: Database

    init(db: Database) {
        self.db = db
    }

    @discardableResult
    public func create(
        id: UUID? = nil,
        name: String
    ) async throws -> CategoryData {
        let order = try await CategoryModel.count(on: db) + 1
        guard
            let new = try await CategoryModel.create(
                .init(id: id, name: name, order: order),
                on: db
            )
        else { throw AppError.duplicate }
        return .init(id: new.id!, name: new.name)
    }

    public func fetch(
        id: UUID? = nil,
        name: String? = nil
    ) async throws -> [CategoryData] {
        let a = try await CategoryModel.fetch(
            .init(id: id, name: name),
            on: db
        )
        return a.map {
            .init(id: $0.id!, name: $0.name)
        }
    }

    @discardableResult
    public func update(
        id: UUID,
        name: String? = nil,
        order: Int? = nil
    ) async throws -> CategoryData {
        let updated = try await CategoryModel.update(
            .init(
                id: id,
                name: name,
                order: order
            ),
            on: db
        )
        return .init(
            id: updated.id!,
            name: updated.name
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
        name: String? = nil
    ) async throws {
        try await CategoryModel.delete(.init(id: id, name: name), on: db)
    }
}

public struct CategoryData: Codable, Identifiable {
    public let id: UUID
    public let name: String

    public init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
}
