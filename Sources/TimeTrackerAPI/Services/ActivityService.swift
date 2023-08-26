import FluentKit

public class ActivityService {
    private let db: Database

    init(db: Database) {
        self.db = db
    }

    @discardableResult
    public func create(
        name: String,
        color: String
    ) async throws -> ActivityData {
        let new = try await ActivityModel.create(.init(name: name, color: color), on: db)
        return .init(name: new.name, color: new.color)
    }

    public func fetch(
        id: UUID? = nil,
        name: String? = nil,
        color: String? = nil
    ) async throws -> [ActivityData] {
        let a = try await ActivityModel.fetch(
            .init(id: id, name: name, color: color),
            on: db
        )
        return a.map { .init(name: $0.name, color: $0.color) }
    }

    @discardableResult
    public func update(
        id: UUID,
        name: String? = nil,
        color: String? = nil
    ) async throws -> ActivityData {
        let updated = try await ActivityModel.update(
            .init(id: id, name: name, color: color),
            on: db
        )
        return .init(name: updated.name, color: updated.color)
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

public struct ActivityData: Codable {
    public let name: String
    public let color: String
}
