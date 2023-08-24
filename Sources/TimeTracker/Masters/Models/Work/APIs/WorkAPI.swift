
import FluentKit

extension WorkModel {
    static func create(
        _ data: CreateWork,
        on db: Database
    ) async throws -> WorkModel {
        let newWork = WorkModel(name: data.name, color: data.color)
        try await newWork.create(on: db)
        return newWork
    }

    static func update(
        _ data: UpdateWork,
        on db: Database
    ) async throws -> WorkModel {
        guard
            let found = try await WorkModel
            .query(on: db)
            .filter(\.$id == data.workId)
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

struct CreateWork: Codable {
    let name: String
    let color: String
}

struct UpdateWork: Codable {
    let workId: WorkModel.IDValue
    let name: String
    let color: String
}
