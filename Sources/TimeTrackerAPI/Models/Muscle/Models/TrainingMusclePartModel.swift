import Foundation
import FluentKit

final class TrainingMusclePartModel: Model {
    static let schema = "training_muscle_parts"

    enum FieldKeys {
        enum v1 {
            static var menuId: FieldKey { "menu_id" }
            static var muscleId: FieldKey { "muscle_id" }
            static var effect: FieldKey { "effect" }
        }
    }

    @ID()
    var id: UUID?

    @Parent(key: FieldKeys.v1.menuId)
    var menu: TrainingMenuModel

    @Parent(key: FieldKeys.v1.muscleId)
    var muscle: MuscleModel

    @Field(key: FieldKeys.v1.effect)
    var effect: Int

    init() {}

    init(
        _ id: TrainingMusclePartModel.IDValue? = nil,
        menuId: TrainingMenuModel.IDValue,
        muscleId: MuscleModel.IDValue,
        effect: Int
    ) {
        self.id = id
        self.$menu.id = menuId
        self.$muscle.id = muscleId
        self.effect = effect
    }
}
