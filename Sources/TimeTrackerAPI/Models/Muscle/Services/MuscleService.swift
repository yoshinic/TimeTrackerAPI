import FluentKit

public class MuscleService {
    private let db: Database

    init(db: Database) {
        self.db = db
    }

    public func fetchDefaultData() async throws -> (
        menus: [DefaultTrainingPartJSONData],
        muscles: [UUID: [DefaultMusclePartJSONData]]
    ) {
        try await DefaultTrainingMenuEffectModel.fetch(on: db)
    }

    public func fetchRunningMenu() async throws -> TrainingMenuData {
        guard
            let m = try await TrainingMenuModel
            .query(on: db)
            .join(parent: \.$mainPart)
            .filter(\.$name == "ランニング")
            .first()
        else { throw AppError.notFound }

        return .init(
            id: try m.requireID(),
            name: m.name,
            mainPart: .init(
                id: try m.joined(MusclePartModel.self).requireID(),
                name: try m.joined(MusclePartModel.self).name,
                order: try m.joined(MusclePartModel.self).order
            ),
            aerobic: m.aerobic,
            order: m.order
        )
    }
}
