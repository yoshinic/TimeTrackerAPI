protocol ServiceFactory {
    func createCategoryService() -> CategoryService
    func createActivityService() -> ActivityService
    func createRecordService() -> RecordService
}
