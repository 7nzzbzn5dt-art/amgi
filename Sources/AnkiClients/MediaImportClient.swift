import AnkiBackend
import AnkiKit
import AnkiProtoBridge
public import Dependencies
import DependenciesMacros
public import Foundation

@DependencyClient
public struct MediaImportClient: Sendable {
    public var add: @Sendable (_ data: Data, _ desiredName: String) async throws -> String
}

extension MediaImportClient: DependencyKey {
    public static let liveValue: Self = {
        @Dependency(\.ankiBackend) var backend
        return Self(
            add: { data, desiredName in
                try await backend.invoke(.addMediaFile(data: data, desiredName: desiredName))
            }
        )
    }()
}

extension MediaImportClient: TestDependencyKey {
    public static let testValue = MediaImportClient()
}

extension DependencyValues {
    public var mediaImportClient: MediaImportClient {
        get { self[MediaImportClient.self] }
        set { self[MediaImportClient.self] = newValue }
    }
}
