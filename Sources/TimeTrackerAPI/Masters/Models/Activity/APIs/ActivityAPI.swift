import FluentKit

public extension ActivityModel {
    static func create(
        _ data: CreateActivity,
        on db: Database
    ) async throws -> ActivityModel {
        let newActivity = ActivityModel(name: data.name, color: data.color)
        try await newActivity.create(on: db)
        return newActivity
    }

    static func update(
        _ data: UpdateActivity,
        on db: Database
    ) async throws -> ActivityModel {
        guard
            let found = try await ActivityModel
            .query(on: db)
            .filter(\.$id == data.activityId)
            .first()
        else {
            throw AppError.notFound
        }

        found.name = data.name
        found.color = data.color
        try await found.update(on: db)
        return found
    }
}

public struct CreateActivity: Codable {
    let name: String
    let color: String
}

public struct UpdateActivity: Codable {
    let activityId: ActivityModel.IDValue
    let name: String
    let color: String
}
