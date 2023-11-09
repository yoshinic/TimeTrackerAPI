import Foundation
import FluentKit

final class MusclePartDetailModel: Model {
    static let schema = "muscle_part_details"

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
    var musclePart: MusclePartModel

    @Field(key: FieldKeys.v1.name)
    var name: String

    @Field(key: FieldKeys.v1.order)
    var order: Int

    @ChildrenProperty(for: \.$musclePartDetail)
    var muscles: [MuscleModel]

    init() {}

    init(
        _ id: MusclePartDetailModel.IDValue? = nil,
        musclePartId: MusclePartModel.IDValue,
        name: String,
        order: Int
    ) {
        self.$musclePart.id = musclePartId
        self.name = name
        self.order = order
    }
}
