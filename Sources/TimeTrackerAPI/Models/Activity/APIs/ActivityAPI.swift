import FluentKit

extension ActivityModel {
    @discardableResult
    static func create(
        _ data: CreateActivity,
        on db: Database
    ) async throws -> ActivityModel {
        let newActivity = ActivityModel(data.id, name: data.name, color: data.color, order: data.order)
        try await newActivity.create(on: db)
        return newActivity
    }

    static func fetch(
        _ data: FetchActivity? = nil,
        on db: Database
    ) async throws -> [ActivityModel] {
        try await ActivityModel
            .query(on: db)
            .group { and in
                guard let data = data else { return }
                if let activityId = data.id {
                    and.filter(\.$id == activityId)
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
    }

    @discardableResult
    static func update(
        _ data: UpdateActivity,
        on db: Database
    ) async throws -> ActivityModel {
        guard
            let found = try await ActivityModel
            .query(on: db)
            .filter(\.$id == data.id)
            .first()
        else {
            throw AppError.notFound
        }

        found.name = data.name ?? found.name
        found.color = data.color ?? found.color
        found.order = data.order ?? found.order
        try await found.update(on: db)
        return found
    }

    static func delete(
        _ data: DeleteActivity,
        on db: Database
    ) async throws {
        try await ActivityModel
            .query(on: db)
            .group(.and) { and in
                if let activityId = data.id {
                    and.filter(\.$id == activityId)
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
}

struct CreateActivity: Codable {
    let id: UUID?
    let name: String
    let color: String
    let order: Int
}

struct FetchActivity: Codable {
    let id: UUID?
    let name: String?
    let color: String?

    init(id: UUID?, name: String? = nil, color: String? = nil) {
        self.id = id
        self.name = name
        self.color = color
    }
}

struct UpdateActivity: Codable {
    let id: UUID
    let name: String?
    let color: String?
    let order: Int?

    init(id: UUID, name: String? = nil, color: String? = nil, order: Int? = nil) {
        self.id = id
        self.name = name
        self.color = color
        self.order = order
    }
}

struct DeleteActivity: Codable {
    let id: UUID?
    let name: String?
    let color: String?

    init(id: UUID?, name: String? = nil, color: String? = nil) {
        self.id = id
        self.name = name
        self.color = color
    }
}
