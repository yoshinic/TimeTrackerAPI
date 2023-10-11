import FluentKit

extension ActivityModel {
    @discardableResult
    static func create(
        _ data: CreateActivity,
        on db: Database
    ) async throws -> ActivityModel {
        let newActivity = ActivityModel(
            data.id,
            categoryId: data.categoryId,
            name: data.name,
            color: data.color,
            order: data.order
        )
        try await newActivity.create(on: db)
        try await newActivity.$category.load(on: db)
        return newActivity
    }

    static func fetch(
        _ data: FetchActivity? = nil,
        on db: Database
    ) async throws -> [ActivityModel] {
        try await ActivityModel
            .query(on: db)
            .join(parent: \.$category)
            .group { and in
                guard let data = data else { return }
                if let activityId = data.id {
                    and.filter(\.$id == activityId)
                }
                if let categoryId = data.categoryId {
                    and.filter(\.$category.$id == categoryId)
                }
                if let name = data.name {
                    and.filter(\.$name == name)
                }
                if let color = data.color {
                    and.filter(\.$color == color)
                }
            }
            .sort(\.$order)
            .all()
            .map { try assignJoinedCategory(to: $0) }
    }

    @discardableResult
    static func update(
        _ data: UpdateActivity,
        on db: Database
    ) async throws -> ActivityModel {
        guard
            let found = try await ActivityModel
            .query(on: db)
            .join(parent: \.$category)
            .filter(\.$id == data.id)
            .first()
        else {
            throw AppError.notFound
        }

        if let categoryId = data.categoryId {
            found.$category.id = categoryId
        }
        if let name = data.name {
            found.name = name
        }
        if let color = data.color {
            found.color = color
        }
        if let order = data.order {
            found.order = order
        }

        try await found.update(on: db)
        try await found.$category.load(on: db)
        return found
    }

    static func delete(
        _ data: DeleteActivity,
        on db: Database
    ) async throws {
        try await ActivityModel
            .query(on: db)
            .join(parent: \.$category)
            .group(.and) { and in
                if let activityId = data.id {
                    and.filter(\.$id == activityId)
                }
                if let categoryId = data.categoryId {
                    and.filter(\.$category.$id == categoryId)
                }
                if let name = data.name {
                    and.filter(\.$name == name)
                }
                if let color = data.color {
                    and.filter(\.$color == color)
                }
            }
            .delete()
    }

    static func count(on db: Database) async throws -> Int {
        try await ActivityModel.query(on: db).count()
    }

    @discardableResult
    static func assignJoinedCategory(
        to activity: ActivityModel
    ) throws -> ActivityModel  {
        activity.$category.value = try activity.joined(CategoryModel.self)
        return activity
    }
}

struct CreateActivity: Codable {
    let id: UUID?
    let categoryId: UUID
    let name: String
    let color: String
    let order: Int

    init(
        id: UUID? = nil,
        categoryId: UUID,
        name: String,
        color: String,
        order: Int
    ) {
        self.id = id
        self.categoryId = categoryId
        self.name = name
        self.color = color
        self.order = order
    }
}

struct FetchActivity: Codable {
    let id: UUID?
    let categoryId: UUID?
    let name: String?
    let color: String?

    init(
        id: UUID? = nil,
        categoryId: UUID? = nil,
        name: String? = nil,
        color: String? = nil
    ) {
        self.id = id
        self.categoryId = categoryId
        self.name = name
        self.color = color
    }
}

struct UpdateActivity: Codable {
    let id: UUID
    let categoryId: UUID?
    let name: String?
    let color: String?
    let order: Int?

    init(
        id: UUID,
        categoryId: UUID? = nil,
        name: String? = nil,
        color: String? = nil,
        order: Int? = nil
    ) {
        self.id = id
        self.categoryId = categoryId
        self.name = name
        self.color = color
        self.order = order
    }
}

struct DeleteActivity: Codable {
    let id: UUID?
    let categoryId: UUID?
    let name: String?
    let color: String?

    init(
        id: UUID?,
        categoryId: UUID? = nil,
        name: String? = nil,
        color: String? = nil
    ) {
        self.id = id
        self.categoryId = categoryId
        self.name = name
        self.color = color
    }
}
