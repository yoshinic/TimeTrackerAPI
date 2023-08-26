protocol ServiceFactory {
    func createActivityService() -> ActivityService
    func createRecordService() -> RecordService
}
