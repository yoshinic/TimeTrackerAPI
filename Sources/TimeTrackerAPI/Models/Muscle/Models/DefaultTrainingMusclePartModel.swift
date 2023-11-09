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

    final class IDValue: Fields, Hashable {
        @Parent(key: FieldKeys.v1.menuId)
        var menu: DefaultTrainingMenuModel

        @Parent(key: FieldKeys.v1.muscleId)
        var muscle: DefaultMuscleModel

        init() {}

        init(
            menuId: DefaultTrainingMenuModel.IDValue,
            muscleId: DefaultMuscleModel.IDValue
        ) {
            self.$menu.id = menuId
            self.$muscle.id = muscleId
        }

        static func == (lhs: IDValue, rhs: IDValue) -> Bool {
            lhs.$menu.id == rhs.$menu.id && lhs.$muscle.id == rhs.$muscle.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine($menu.id)
            hasher.combine($muscle.id)
        }
    }

    @CompositeID()
    var id: IDValue?

    @Field(key: FieldKeys.v1.effect)
    var effect: Int

    init() {}

    init(
        menuId: DefaultTrainingMenuModel.IDValue,
        muscleId: DefaultMuscleModel.IDValue,
        effect: Int
    ) {
        self.id = .init(
            menuId: menuId,
            muscleId: muscleId
        )
        self.effect = effect
    }
}
