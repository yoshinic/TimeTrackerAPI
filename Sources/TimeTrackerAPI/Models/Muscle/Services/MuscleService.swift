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
}
