import Foundation
import FluentKit

final class MuscleModel: Model {
    static let schema = "muscles"

    enum FieldKeys {
        enum v1 {
            static var name: FieldKey { "name" }
            static var muscleDetail: FieldKey { "muscle_detail" }
            static var ruby: FieldKey { "ruby" }
            static var musclePartId: FieldKey { "muscle_part_id" }
            static var musclePartDetailId: FieldKey { "muscle_part_detail_id" }
            static var order: FieldKey { "order" }
        }
    }

    @ID()
    var id: UUID?

    @Field(key: FieldKeys.v1.name)
    var name: String

    @Field(key: FieldKeys.v1.muscleDetail)
    var muscleDetail: String

    @Field(key: FieldKeys.v1.ruby)
    var ruby: String

    @Parent(key: FieldKeys.v1.musclePartId)
    var musclePart: MusclePartModel

    @OptionalParent(key: FieldKeys.v1.musclePartDetailId)
    var musclePartDetail: MusclePartDetailModel?

    @Field(key: FieldKeys.v1.order)
    var order: Int

    @Children(for: \.$id.$muscle)
    var trainingMuscleParts: [TrainingMusclePartModel]
    
    init() {}

    init(
        _ id: MuscleModel.IDValue? = nil,
        name: String,
        muscleDetail: String,
        ruby: String,
        musclePartId: MusclePartModel.IDValue,
        musclePartDetailId: MusclePartDetailModel.IDValue? = nil,
        order: Int
    ) {
        self.id = id
        self.name = name
        self.muscleDetail = muscleDetail
        self.ruby = ruby
        self.$musclePart.id = musclePartId
        self.$musclePartDetail.id = musclePartDetailId
        self.order = order
    }
}
