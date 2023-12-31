import Foundation
import FluentKit

final class MusclePartModel: Model {
    static let schema = "muscle_parts"

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

    @Children(for: \.$musclePart)
    var details: [MusclePartDetailModel]
    
    @Children(for: \.$musclePart)
    var muscles: [MuscleModel]
    
    @Children(for: \.$mainPart)
    var menus: [TrainingMenuModel]
    
    init() {}

    init(
        _ id: MusclePartModel.IDValue? = nil,
        name: String,
        order: Int
    ) {
        self.id = id
        self.name = name
        self.order = order
    }
}
