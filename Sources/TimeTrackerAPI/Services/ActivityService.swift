import FluentKit

public class ActivityService {
    public static let defaultId: UUID = ActivityModel.defaultId

    private let db: Database
    private let categoryService: CategoryService

    init(db: Database) {
        self.db = db
        self.categoryService = .init(db: self.db)
    }

    @discardableResult
    public func create(
        id: UUID? = nil,
        categoryId: UUID,
        name: String,
        color: String
    ) async throws -> ActivityData {
        try await db.transaction {
            try await ActivityModel
                .create(
                    .init(
                        id: id,
                        categoryId: categoryId,
                        name: name,
                        color: color,
                        order: await ActivityModel.count(on: $0) + 1
                    ),
                    on: $0
                )
                .toData
        }
    }

    public func fetch(
        id: UUID? = nil,
        categoryId: UUID? = nil,
        name: String? = nil,
        color: String? = nil
    ) async throws -> [ActivityData] {
        try await ActivityModel
            .fetch(
                .init(
                    id: id,
                    categoryId: categoryId,
                    name: name,
                    color: color
                ),
                on: db
            )
            .map { $0.toData }
    }

    @discardableResult
    public func update(
        id: UUID,
        categoryId: UUID? = nil,
        name: String? = nil,
        color: String? = nil,
        order: Int? = nil
    ) async throws -> ActivityData {
        try await ActivityModel
            .update(
                .init(
                    id: id,
                    categoryId: categoryId,
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
        try await ActivityModel.delete(
            .init(id: id, name: name, color: color),
            on: db
        )
    }
}

public struct ActivityData: Codable, Identifiable {
    public let id: UUID
    public let category: CategoryData
    public let name: String
    public let color: String
    public let order: Int

    public init(
        id: UUID,
        category: CategoryData,
        name: String,
        color: String,
        order: Int
    ) {
        self.id = id
        self.category = category
        self.name = name
        self.color = color
        self.order = order
    }
}

extension ActivityData: Hashable {}

extension ActivityModel {
    var toData: ActivityData {
        ActivityData(
            id: self.id!,
            category: self.$category.wrappedValue.toData,
            name: self.name,
            color: self.color,
            order: self.order
        )
    }
}
