import Foundation
import FluentKit

final class DefaultCategoryModel: Model {
    static let schema = "default_categories"

    enum FieldKeys {
        enum v1 {
            static var name: FieldKey { "name" }
            static var color: FieldKey { "color" }
            static var icon: FieldKey { "icon" }
            static var order: FieldKey { "order" }
        }
    }

    @ID()
    var id: UUID?
    
    @Field(key: FieldKeys.v1.name)
    var name: String

    @Field(key: FieldKeys.v1.color)
    var color: String

    @Field(key: FieldKeys.v1.icon)
    var icon: String

    @Field(key: FieldKeys.v1.order)
    var order: Int

    @Children(for: \.$category)
    var activities: [DefaultActivityModel]

    init() {}

    init(
        _ id: DefaultCategoryModel.IDValue? = nil,
        name: String,
        color: String,
        icon: String,
        order: Int
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
        self.order = order
    }
}
