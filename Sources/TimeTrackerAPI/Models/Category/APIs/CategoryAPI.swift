import Foundation
import FluentKit

extension CategoryModel {
    @discardableResult
    static func create(
        _ data: CreateCategory,
        on db: Database
    ) async throws -> CategoryModel? {
        let founds = try await fetch(.init(name: data.name), on: db)

        switch founds.count {
        case 0:
            let newCategory = CategoryModel(
                name: data.name,
                color: data.color,
                order: data.order
            )
            try await newCategory.create(on: db)

            return newCategory
        case 1:
            return founds[0]
        default:
            throw AppError.duplicate
        }
    }

    static func fetch(
        _ data: FetchCategory? = nil,
        on db: Database
    ) async throws -> [CategoryModel] {
        try await CategoryModel
            .query(on: db)
            .group(.and) { and in
                guard let data = data else { return }
                if let id = data.id {
                    and.filter(\.$id == id)
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
        _ data: UpdateCategory,
        on db: Database
    ) async throws -> CategoryModel {
        guard
            let found = try await CategoryModel
            .query(on: db)
            .filter(\.$id == data.id)
            .first()
        else {
            throw AppError.notFound
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
        return found
    }

    static func delete(
        _ data: DeleteCategory? = nil,
        on db: Database
    ) async throws {
        try await CategoryModel
            .query(on: db)
            .group(.and) { and in
                guard let data = data else { return }
                if let id = data.id {
                    and.filter(\.$id == id)
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
        try await CategoryModel.query(on: db).count()
    }
}

struct CreateCategory: Codable {
    let id: UUID?
    let name: String
    let color: String
    let order: Int

    init(
        id: UUID? = nil,
        name: String,
        color: String,
        order: Int
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.order = order
    }
}

struct FetchCategory: Codable {
    let id: UUID?
    let name: String?
    let color: String?

    init(
        id: UUID? = nil,
        name: String? = nil,
        color: String? = nil
    ) {
        self.id = id
        self.name = name
        self.color = color
    }
}

struct UpdateCategory: Codable {
    let id: UUID
    let name: String?
    let color: String?
    let order: Int?

    init(
        id: UUID,
        name: String? = nil,
        color: String? = nil,
        order: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.order = order
    }
}

struct DeleteCategory: Codable {
    let id: UUID?
    let name: String?
    let color: String?

    init(
        id: UUID?,
        name: String? = nil,
        color: String? = nil
    ) {
        self.id = id
        self.name = name
        self.color = color
    }
}