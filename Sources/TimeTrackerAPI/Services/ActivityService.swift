import FluentKit

public class ActivityService {
    private let db: Database

    init(db: Database) {
        self.db = db
    }

    @discardableResult
    public func create(
        id: UUID? = nil,
        categoryId: UUID,
        name: String,
        color: String
    ) async throws -> ActivityData {
        try await db.transaction { db in
            let order = try await ActivityModel.count(on: db) + 1
            let new = try await ActivityModel.create(
                .init(
                    id: id,
                    categoryId: categoryId,
                    name: name,
                    color: color,
                    order: order
                ),
                on: db
            )
            return .init(
                id: new.id!,
                categoryId: new.$category.id,
                name: new.name,
                color: new.color
            )
        }
    }

    public func fetch(
        id: UUID? = nil,
        categoryId: UUID? = nil,
        name: String? = nil,
        color: String? = nil
    ) async throws -> [ActivityData] {
        let a = try await ActivityModel.fetch(
            .init(
                id: id,
                categoryId: categoryId,
                name: name,
                color: color
            ),
            on: db
        )
        return a.map {
            .init(
                id: $0.id!,
                categoryId: $0.$category.id,
                name: $0.name,
                color: $0.color
            )
        }
    }

    @discardableResult
    public func update(
        id: UUID,
        categoryId: UUID? = nil,
        name: String? = nil,
        color: String? = nil,
        order: Int? = nil
    ) async throws -> ActivityData {
        let updated = try await ActivityModel.update(
            .init(
                id: id,
                categoryId: categoryId,
                name: name,
                color: color,
                order: order
            ),
            on: db
        )
        return .init(
            id: updated.id!,
            categoryId: updated.$category.id,
            name: updated.name,
            color: updated.color
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
        try await ActivityModel.delete(
            .init(id: id, name: name, color: color),
            on: db
        )
    }
}

public struct ActivityData: Codable, Identifiable {
    public let id: UUID
    public let categoryId: UUID
    public let name: String
    public let color: String

    public init(id: UUID, categoryId: UUID, name: String, color: String) {
        self.id = id
        self.categoryId = categoryId
        self.name = name
        self.color = color
    }
}
