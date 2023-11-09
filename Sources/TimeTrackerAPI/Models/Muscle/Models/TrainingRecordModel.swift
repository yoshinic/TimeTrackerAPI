import Foundation
import FluentKit

final class TrainingRecordModel: Model {
    static let schema = "training_records"

    enum FieldKeys {
        enum v1 {
            static var menuId: FieldKey { "menu_id" }
            static var set: FieldKey { "set" }
            static var weight: FieldKey { "weight" }
            static var number: FieldKey { "number" }
            static var speed: FieldKey { "speed" }
            static var duration: FieldKey { "duration" }
            static var slope: FieldKey { "slope" }
        }
    }

    @ID()
    var id: UUID?

    @Parent(key: FieldKeys.v1.menuId)
    var menu: TrainingMenuModel

    @Field(key: FieldKeys.v1.set)
    var set: Int

    @Field(key: FieldKeys.v1.weight)
    var weight: Float

    @Field(key: FieldKeys.v1.number)
    var number: Int

    @Field(key: FieldKeys.v1.speed)
    var speed: Float

    @Field(key: FieldKeys.v1.duration)
    var duration: Float

    @Field(key: FieldKeys.v1.slope)
    var slope: Float

    init() {}

    init(
        _ id: TrainingRecordModel.IDValue? = nil,
        menuId: TrainingMenuModel.IDValue,
        set: Int,
        weight: Float,
        number: Int,
        speed: Float,
        duration: Float,
        slope: Float
    ) {
        self.id = id
        self.$menu.id = menuId
        self.set = set
        self.weight = weight
        self.number = number
        self.speed = speed
        self.duration = duration
        self.slope = slope
    }
}
