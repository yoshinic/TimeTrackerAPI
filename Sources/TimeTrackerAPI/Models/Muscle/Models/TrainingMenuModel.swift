import Foundation
import FluentKit

final class TrainingMenuModel: Model {
    static let schema = "training_menus"

    enum FieldKeys {
        enum v1 {
            static var name: FieldKey { "name" }
            static var aerobic: FieldKey { "aerobic" }
            static var order: FieldKey { "order" }
        }
    }

    @ID()
    var id: UUID?

    @Field(key: FieldKeys.v1.name)
    var name: String

    @Field(key: FieldKeys.v1.aerobic)
    var aerobic: Bool

    @Field(key: FieldKeys.v1.order)
    var order: Int

    @Children(for: \.$id.$menu)
    var trainingMuscleParts: [TrainingMusclePartModel]

    @Children(for: \.$menu)
    var menus: [TrainingRecordModel]

    init() {}

    init(
        _ id: TrainingMenuModel.IDValue? = nil,
        name: String,
        aerobic: Bool,
        order: Int
    ) {
        self.id = id
        self.name = name
        self.aerobic = aerobic
        self.order = order
    }
}
