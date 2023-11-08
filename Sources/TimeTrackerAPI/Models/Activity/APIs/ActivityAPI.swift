import FluentKit

extension ActivityModel {
    @discardableResult
    static func create(
        _ data: CreateActivity,
        on db: Database
    ) async throws -> ActivityModel {
        let founds = try await fetch(.init(name: data.name), on: db)

        switch founds.count {
        case 0:
            let newActivity = ActivityModel(
                data.id,
                categoryId: data.categoryId,
                name: data.name,
                color: data.color,
                icon: data.icon,
                order: data.order
            )
            try await newActivity.create(on: db)
            try await newActivity.$category.load(on: db)
            return newActivity
        case 1:
            return founds[0]
        default:
            throw AppError.duplicate
        }
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
            }
            .sort(CategoryModel.self, \.$order)
            .sort(\.$order)
            .all()
            .compactMap { try assignJoinedCategory(to: $0) }
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

        found.$category.id = data.categoryId
        found.name = data.name
        found.color = data.color
        found.icon = data.icon
        found.order = data.order

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
            }
            .delete()
    }

    static func count(on db: Database) async throws -> Int {
        try await ActivityModel.query(on: db).count()
    }

    static func defaultData(on db: Database) async throws -> [DefaultActivityModel] {
        try await DefaultActivityModel.query(on: db).all()
    }

    @discardableResult
    static func assignJoinedCategory(
        to activity: ActivityModel?
    ) throws -> ActivityModel?  {
        activity?.$category.value = try activity?.joined(CategoryModel.self)
        return activity
    }
}

struct CreateActivity: Codable {
    let id: UUID?
    let categoryId: UUID?
    let name: String
    let color: String
    let icon: String
    let order: Int

    init(
        id: UUID? = nil,
        categoryId: UUID?,
        name: String,
        color: String,
        icon: String,
        order: Int
    ) {
        self.id = id
        self.categoryId = categoryId
        self.name = name
        self.color = color
        self.icon = icon
        self.order = order
    }
}

struct FetchActivity: Codable {
    let id: UUID?
    let categoryId: UUID?
    let name: String?

    init(
        id: UUID? = nil,
        categoryId: UUID? = nil,
        name: String? = nil
    ) {
        self.id = id
        self.categoryId = categoryId
        self.name = name
    }
}

struct UpdateActivity: Codable {
    let id: UUID
    let categoryId: UUID?
    let name: String
    let color: String
    let icon: String
    let order: Int

    init(
        id: UUID,
        categoryId: UUID? = nil,
        name: String,
        color: String,
        icon: String,
        order: Int
    ) {
        self.id = id
        self.categoryId = categoryId
        self.name = name
        self.color = color
        self.icon = icon
        self.order = order
    }
}

struct DeleteActivity: Codable {
    let id: UUID?
    let categoryId: UUID?

    init(
        id: UUID?,
        categoryId: UUID? = nil
    ) {
        self.id = id
        self.categoryId = categoryId
    }
}
