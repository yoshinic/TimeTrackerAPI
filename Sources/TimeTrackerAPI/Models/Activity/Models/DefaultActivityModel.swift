import FluentKit

final class DefaultActivityModel: Model {
    static let schema = "default_activities"

    enum FieldKeys {
        enum v1 {
            static var categoryId: FieldKey { "category_id" }
            static var name: FieldKey { "name" }
            static var color: FieldKey { "color" }
            static var icon: FieldKey { "icon" }
            static var order: FieldKey { "order" }
        }
    }

    @ID()
    var id: UUID?

    @OptionalParent(key: FieldKeys.v1.categoryId)
    var category: DefaultCategoryModel?

    @Field(key: FieldKeys.v1.name)
    var name: String

    @Field(key: FieldKeys.v1.color)
    var color: String

    @Field(key: FieldKeys.v1.icon)
    var icon: String

    @Field(key: FieldKeys.v1.order)
    var order: Int

    init() {}

    init(
        _ id: DefaultActivityModel.IDValue? = nil,
        categoryId: DefaultCategoryModel.IDValue?,
        name: String,
        color: String,
        icon: String,
        order: Int
    ) {
        self.id = id
        self.$category.id = categoryId
        self.name = name
        self.color = color
        self.icon = icon
        self.order = order
    }
}
