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

    final class IDValue: Fields, Hashable {
        @Parent(key: FieldKeys.v1.menuId)
        var menu: TrainingMenuModel

        @Parent(key: FieldKeys.v1.muscleId)
        var muscle: MuscleModel

        init() {}

        init(
            menuId: TrainingMenuModel.IDValue,
            muscleId: MuscleModel.IDValue
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
        menuId: TrainingMenuModel.IDValue,
        muscleId: MuscleModel.IDValue,
        effect: Int
    ) {
        self.id = .init(
            menuId: menuId,
            muscleId: muscleId
        )
        self.effect = effect
    }
}
