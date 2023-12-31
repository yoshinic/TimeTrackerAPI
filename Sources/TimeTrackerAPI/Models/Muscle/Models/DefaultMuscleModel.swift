import Foundation
import FluentKit

final class DefaultMuscleModel: Model {
    static let schema = "default_muscles"

    enum FieldKeys {
        enum v1 {
            static var musclePartId: FieldKey { "muscle_part_id" }
            static var musclePartDetailId: FieldKey { "muscle_part_detail_id" }
            static var name: FieldKey { "name" }
            static var muscleDetail: FieldKey { "muscle_detail" }
            static var ruby: FieldKey { "ruby" }
            static var order: FieldKey { "order" }
        }
    }

    @ID()
    var id: UUID?

    @Parent(key: FieldKeys.v1.musclePartId)
    var musclePart: DefaultMusclePartModel

    @OptionalParent(key: FieldKeys.v1.musclePartDetailId)
    var musclePartDetail: DefaultMusclePartDetailModel?

    @Field(key: FieldKeys.v1.name)
    var name: String

    @Field(key: FieldKeys.v1.muscleDetail)
    var muscleDetail: String

    @Field(key: FieldKeys.v1.ruby)
    var ruby: String

    @Field(key: FieldKeys.v1.order)
    var order: Int

    @Children(for: \.$muscle)
    var trainingMuscleParts: [DefaultTrainingMusclePartModel]

    init() {}

    init(
        _ id: DefaultMuscleModel.IDValue? = nil,
        musclePartId: DefaultMusclePartModel.IDValue,
        musclePartDetailId: DefaultMusclePartDetailModel.IDValue? = nil,
        name: String,
        muscleDetail: String,
        ruby: String,
        order: Int
    ) {
        self.id = id
        self.$musclePart.id = musclePartId
        self.$musclePartDetail.id = musclePartDetailId
        self.name = name
        self.muscleDetail = muscleDetail
        self.ruby = ruby
        self.order = order
    }
}
