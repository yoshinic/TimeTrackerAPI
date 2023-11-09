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

    final class IDValue: Fields, Hashable {
        @Parent(key: FieldKeys.v1.musclePartId)
        var musclePart: MusclePartModel

        @Field(key: FieldKeys.v1.name)
        var name: String

        init() {}

        init(
            musclePartId: MusclePartModel.IDValue,
            name: String
        ) {
            self.$musclePart.id = musclePartId
            self.name = name
        }

        static func == (lhs: IDValue, rhs: IDValue) -> Bool {
            lhs.$musclePart.id == rhs.$musclePart.id
                && lhs.name == rhs.name
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine($musclePart.id)
            hasher.combine(name)
        }
    }

    @CompositeID()
    var id: IDValue?

    @Field(key: FieldKeys.v1.order)
    var order: Int

    @ChildrenProperty(for: \.$musclePartDetail)
    var muscles: [MuscleModel]

    init() {}

    init(
        musclePartId: MusclePartModel.IDValue,
        name: String,
        order: Int
    ) {
        self.id = .init(
            musclePartId: musclePartId,
            name: name
        )
        self.order = order
    }
}
