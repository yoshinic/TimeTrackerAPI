import FluentKit

class ActivityService {
    private let db: Database

    init(db: Database) {
        self.db = db
    }

    func create(
        name: String,
        color: String
    ) async throws -> ActivityModel {
        try await ActivityModel.create(.init(name: name, color: color), on: db)
    }

    func fetch(
        id: ActivityModel.IDValue? = nil,
        name: String? = nil,
        color: String? = nil
    ) async throws -> [ActivityModel] {
        try await ActivityModel.fetch(
            .init(id: id, name: name, color: color),
            on: db
        )
    }

    func update(
        id: ActivityModel.IDValue,
        name: String? = nil,
        color: String? = nil
    ) async throws -> ActivityModel {
        try await ActivityModel.update(
            .init(id: id, name: name, color: color),
            on: db
        )
    }

    func delete(
        id: ActivityModel.IDValue? = nil,
        name: String? = nil,
        color: String? = nil
    ) async throws {
        try await ActivityModel.delete(
            .init(id: id, name: name, color: color),
            on: db
        )
    }
}
