import FluentKit

extension ActivityModel {
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
            .all()
    }

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
    ) async throws {}

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
}

struct UpdateActivity: Codable {
    let id: UUID
    let name: String?
    let color: String?
    let order: Int?
}

struct DeleteActivity: Codable {
    let id: UUID?
    let name: String?
    let color: String?
}
