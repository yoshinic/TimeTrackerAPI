import FluentKit

public class ActivityService {
    private let db: Database
    private let categoryService: CategoryService

    init(db: Database) {
        self.db = db
        self.categoryService = .init(db: self.db)
    }

    @discardableResult
    public func create(
        id: UUID? = nil,
        categoryId: UUID?,
        name: String,
        color: String,
        icon: String
    ) async throws -> ActivityData {
        try await db.transaction {
            try await ActivityModel
                .create(
                    .init(
                        id: id,
                        categoryId: categoryId,
                        name: name,
                        color: color,
                        icon: icon,
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
        name: String? = nil
    ) async throws -> [ActivityData] {
        try await ActivityModel
            .fetch(
                .init(id: id, categoryId: categoryId, name: name),
                on: db
            )
            .map { $0.toData }
    }

    @discardableResult
    public func update(
        id: UUID,
        categoryId: UUID?,
        name: String,
        color: String,
        icon: String,
        order: Int
    ) async throws -> ActivityData {
        try await ActivityModel
            .update(
                .init(
                    id: id,
                    categoryId: categoryId,
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
    public func updateOrder(_ activities: [ActivityData]) async throws {
        for (i, activity) in activities.enumerated() {
            try await update(
                id: activity.id,
                categoryId: activity.category?.id,
                name: activity.name,
                color: activity.color,
                icon: activity.icon,
                order: i + 1
            )
        }
    }

    public func delete(
        id: UUID? = nil,
        name: String? = nil
    ) async throws {
        try await ActivityModel.delete(
            .init(id: id),
            on: db
        )
    }

    public func defaultData() async throws -> [ActivityData] {
        try await ActivityModel.defaultData(on: db).map { $0.toData }
    }

    public func defaultWeightTrainingData() async throws -> ActivityData {
        guard
            let m = try await defaultData()
            .first(where: { $0.name == "ウェイトトレーニング" })
        else { throw AppError.notFound }
        return m
    }
}

public struct ActivityData: Codable, Identifiable {
    public let id: UUID
    public let category: CategoryData?
    public let name: String
    public let color: String
    public let icon: String
    public let order: Int

    public init(
        id: UUID,
        category: CategoryData?,
        name: String,
        color: String,
        icon: String,
        order: Int
    ) {
        self.id = id
        self.category = category
        self.name = name
        self.color = color
        self.icon = icon
        self.order = order
    }
}

extension ActivityData: Hashable {}

extension ActivityModel {
    var toData: ActivityData {
        ActivityData(
            id: self.id!,
            category: self.$category.wrappedValue?.toData,
            name: self.name,
            color: self.color,
            icon: self.icon,
            order: self.order
        )
    }
}

extension DefaultActivityModel {
    var toData: ActivityData {
        ActivityData(
            id: self.id!,
            category: self.$category.wrappedValue?.toData,
            name: self.name,
            color: self.color,
            icon: self.icon,
            order: self.order
        )
    }
}
