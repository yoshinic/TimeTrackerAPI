import Foundation
import Fluent

final class CategoryModel: Model {
    static let schema = "categories"

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
    
    @Children(for: \.$category)
    var activities: [ActivityModel]
    
    init() {}

    init(
        _ id: CategoryModel.IDValue? = nil,
        name: String,
        order: Int
    ) {
        self.id = id
        self.name = name
        self.order = order
    }
}
