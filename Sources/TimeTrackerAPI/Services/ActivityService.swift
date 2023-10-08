import FluentKit

public class ActivityService {
    private let db: Database

    init(db: Database) {
        self.db = db
    }

    @discardableResult
    public func create(
        id: UUID? = nil,
        name: String,
        color: String
    ) async throws -> ActivityData {
        let order = try await ActivityModel.count(on: db) + 1
        let new = try await ActivityModel.create(
            .init(id: id, name: name, color: color, order: order),
            on: db
        )
        return .init(id: new.id!, name: new.name, color: new.color)
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
        return a.map {
            .init(id: $0.id!, name: $0.name, color: $0.color)
        }
    }

    @discardableResult
    public func update(
        id: UUID,
        name: String? = nil,
        color: String? = nil
    ) async throws -> ActivityData {
        let updated = try await ActivityModel.update(
            .init(id: id, name: name, color: color, order: nil),
            on: db
        )
        return .init(id: updated.id!, name: updated.name, color: updated.color)
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

        let a = try await ActivityModel.fetch(on: db)
        for o in a.enumerated() {
            o.element.order = o.offset
        }

        for (i, e) in a.enumerated() {
            try await ActivityModel.update(
                .init(id: e.id!, name: e.name, color: e.color, order: i + 1),
                on: db
            )
        }
    }

    @discardableResult
    public func move(
        sourceId: UUID,
        destinationId: UUID
    ) async throws -> [ActivityData] {
        let a = try await ActivityModel.move(
            .init(sourceId: sourceId, destinationId: destinationId),
            on: db
        )
        return a.map {
            .init(id: $0.id!, name: $0.name, color: $0.color)
        }
    }
}

public struct ActivityData: Codable, Identifiable {
    public let id: UUID
    public let name: String
    public let color: String

    public init(id: UUID, name: String, color: String) {
        self.id = id
        self.name = name
        self.color = color
    }
}
