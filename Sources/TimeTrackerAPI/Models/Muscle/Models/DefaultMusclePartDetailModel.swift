import Foundation
import FluentKit

final class DefaultMusclePartDetailModel: Model {
    static let schema = "default_muscle_part_details"

    enum FieldKeys {
        enum v1 {
            static var musclePartId: FieldKey { "muscle_part_id" }
            static var name: FieldKey { "name" }
            static var order: FieldKey { "order" }
        }
    }

    @ID()
    var id: UUID?

    @Parent(key: FieldKeys.v1.musclePartId)
    var musclePart: DefaultMusclePartModel

    @Field(key: FieldKeys.v1.name)
    var name: String

    @Field(key: FieldKeys.v1.order)
    var order: Int

    @ChildrenProperty(for: \.$musclePartDetail)
    var muscles: [DefaultMuscleModel]

    init() {}

    init(
        _ id: DefaultMusclePartDetailModel.IDValue? = nil,
        musclePartId: DefaultMusclePartModel.IDValue,
        name: String,
        order: Int
    ) {
        self.id = id
        self.$musclePart.id = musclePartId
        self.name = name
        self.order = order
    }
}
