import Foundation
import FluentKit

final class DefaultTrainingMusclePartModel: Model {
    static let schema = "default_training_muscle_parts"

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
    var menu: DefaultTrainingMenuModel

    @Parent(key: FieldKeys.v1.muscleId)
    var muscle: DefaultMuscleModel

    @Field(key: FieldKeys.v1.effect)
    var effect: Int

    init() {}

    init(
        _ id: DefaultTrainingMusclePartModel.IDValue? = nil,
        menuId: DefaultTrainingMenuModel.IDValue,
        muscleId: DefaultMuscleModel.IDValue,
        effect: Int
    ) {
        self.id = id
        self.$menu.id = menuId
        self.$muscle.id = muscleId
        self.effect = effect
    }
}
