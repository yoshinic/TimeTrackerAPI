import FluentKit
import Foundation

final class TrainingMenuModel: Model {
    static let schema = "training_menus"

    enum FieldKeys {
        enum v1 {
            static var name: FieldKey { "name" }
            static var mainPart: FieldKey { "main_part" }
            static var aerobic: FieldKey { "aerobic" }
            static var order: FieldKey { "order" }
        }
    }

    @ID()
    var id: UUID?

    @Field(key: FieldKeys.v1.name)
    var name: String

    @Parent(key: FieldKeys.v1.mainPart)
    var mainPart: MusclePartModel

    @Field(key: FieldKeys.v1.aerobic)
    var aerobic: Bool

    @Field(key: FieldKeys.v1.order)
    var order: Int

    @Children(for: \.$menu)
    var trainingMuscleParts: [TrainingMusclePartModel]

    @Children(for: \.$menu)
    var records: [TrainingRecordModel]

    init() {}

    init(
        _ id: TrainingMenuModel.IDValue? = nil,
        name: String,
        mainPartId: MusclePartModel.IDValue,
        aerobic: Bool,
        order: Int
    ) {
        self.id = id
        self.name = name
        self.$mainPart.id = mainPartId
        self.aerobic = aerobic
        self.order = order
    }
}
