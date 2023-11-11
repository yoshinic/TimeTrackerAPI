import FluentKit
import Foundation

final class DefaultTrainingMenuEffectModel: Model {
    static let schema = "default_training_menu_effects"

    enum FieldKeys {
        enum v1 {
            static var trainingMenu: FieldKey { "training_menu" }
            static var trainingMenuEffect: FieldKey { "training_menu_effect" }
        }
    }

    @ID()
    var id: UUID?

    @Field(key: FieldKeys.v1.trainingMenu)
    var trainingMenu: DefaultTrainingMenuJSON

    @Field(key: FieldKeys.v1.trainingMenuEffect)
    var trainingMenuEffect: DefaultTrainingMenuEffectJSON

    init() {}

    init(
        _ id: DefaultTrainingMenuEffectModel.IDValue? = nil,
        trainingMenu: DefaultTrainingMenuJSON,
        trainingMenuEffect: DefaultTrainingMenuEffectJSON
    ) {
        self.id = id
        self.trainingMenu = trainingMenu
        self.trainingMenuEffect = trainingMenuEffect
    }
}

public struct DefaultTrainingMenuEffectJSON: Codable {
    let data: [DefaultTrainingMenuEffectJSONData]
    init(_ data: [DefaultTrainingMenuEffectJSONData]) {
        self.data = data
    }
}

public struct DefaultTrainingMenuEffectJSONData: Codable {
    let menuId: DefaultTrainingMenuModel.IDValue
    var data: [DefaultMusclePartJSONData]
    init(
        _ menuId: DefaultTrainingMenuModel.IDValue,
        _ data: [DefaultMusclePartJSONData]
    ) {
        self.menuId = menuId
        self.data = data
    }
}

public struct DefaultMusclePartJSONData: Codable, Hashable {
    let id: UUID
    let name: String
    let order: Int

    var details: [DefaultMusclePartDetailJSONData]

    init(
        _ id: UUID,
        _ name: String,
        _ order: Int,
        _ details: [DefaultMusclePartDetailJSONData]
    ) {
        self.id = id
        self.name = name
        self.order = order
        self.details = details
    }
}

public struct DefaultMusclePartDetailJSONData: Codable, Hashable {
    let id: UUID?
    let name: String
    let order: Int

    var effects: [DefaultTrainingEffectJSONData]

    init(
        _ id: UUID? = nil,
        _ name: String = "",
        _ order: Int,
        _ effects: [DefaultTrainingEffectJSONData]
    ) {
        self.id = id
        self.name = name
        self.order = order
        self.effects = effects
    }
}

public struct DefaultTrainingEffectJSONData: Codable, Hashable {
    let id: UUID?
    let name: String
    let detail: String
    let ruby: String
    let effect: Int
    let order: Int

    init(
        _ id: UUID?,
        _ name: String,
        _ detail: String,
        _ ruby: String,
        _ effect: Int,
        _ order: Int
    ) {
        self.id = id
        self.name = name
        self.detail = detail
        self.ruby = ruby
        self.effect = effect
        self.order = order
    }
}

public struct DefaultTrainingMenuJSON: Codable, Hashable {
    let data: [DefaultTrainingPartJSONData]
    init(_ data: [DefaultTrainingPartJSONData]) {
        self.data = data
    }
}

public struct DefaultTrainingPartJSONData: Codable, Hashable {
    let id: UUID
    let name: String
    let order: Int

    var menus: [DefaultTrainingMenuJSONData]

    init(
        _ id: UUID,
        _ name: String,
        _ order: Int,
        _ menus: [DefaultTrainingMenuJSONData]
    ) {
        self.id = id
        self.name = name
        self.order = order
        self.menus = menus
    }
}

public struct DefaultTrainingMenuJSONData: Codable, Hashable {
    let id: UUID
    let name: String
    let aerobic: Bool
    let order: Int

    init(
        _ id: UUID,
        _ name: String,
        _ aerobic: Bool,
        _ order: Int
    ) {
        self.id = id
        self.name = name
        self.aerobic = aerobic
        self.order = order
    }
}
