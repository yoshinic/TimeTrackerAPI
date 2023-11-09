import Foundation
import FluentKit

final class DefaultMusclePartModel: Model {
    static let schema = "default_muscle_parts"

    enum FieldKeys {
        enum v1 {
            static var name: FieldKey { "name" }
            static var order: FieldKey { "order" }
        }
    }

    @ID()
    var id: UUID?

    @Field(key: FieldKeys.v1.name)
    var name: String

    @Field(key: FieldKeys.v1.order)
    var order: Int

    @ChildrenProperty(for: \.$musclePart)
    var details: [DefaultMusclePartDetailModel]
    
    @ChildrenProperty(for: \.$musclePart)
    var muscles: [DefaultMuscleModel]

    init() {}

    init(
        _ id: DefaultMusclePartModel.IDValue? = nil,
        name: String,
        order: Int
    ) {
        self.id = id
        self.name = name
        self.order = order
    }
}
