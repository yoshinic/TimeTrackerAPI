import Fluent

final class ActivityModel: Model {
    static let schema = "activities"

    static let defaultId: UUID = .init()
    
    enum FieldKeys {
        enum v1 {
            static var categoryId: FieldKey { "category_id" }
            static var name: FieldKey { "name" }
            static var color: FieldKey { "color" }
            static var order: FieldKey { "order" }
        }
    }

    @ID()
    var id: UUID?
    
    @Parent(key: FieldKeys.v1.categoryId)
    var category: CategoryModel
    
    @Field(key: FieldKeys.v1.name)
    var name: String

    @Field(key: FieldKeys.v1.color)
    var color: String

    @Field(key: FieldKeys.v1.order)
    var order: Int

    @Children(for: \.$activity)
    var records: [RecordModel]

    init() {}

    init(
        _ id: ActivityModel.IDValue? = nil,
        categoryId: CategoryModel.IDValue,
        name: String,
        color: String,
        order: Int
    ) {
        self.id = id
        self.$category.id = categoryId
        self.name = name
        self.color = color
        self.order = order
    }
}
