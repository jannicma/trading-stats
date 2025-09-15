public protocol publicWs {
    func connect() async throws
    func disconnect() async throws

}
