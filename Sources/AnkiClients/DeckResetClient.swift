import AnkiBackend
import AnkiKit
import AnkiProtoBridge
public import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct DeckResetClient: Sendable {
    /// Resets every card matched by the deck search to Anki's New state and
    /// returns the number of cards changed.
    public var resetEntireDeck: @Sendable (_ deckName: String) async throws -> Int
}

extension DeckResetClient: DependencyKey {
    public static let liveValue: Self = {
        @Dependency(\.ankiBackend) var backend
        return Self(
            resetEntireDeck: { deckName in
                try await backendOffload {
                    let escaped = deckName
                        .replacingOccurrences(of: "\\", with: "\\\\")
                        .replacingOccurrences(of: "\"", with: "\\\"")
                    let cardIds = try backend.invoke(.searchCardIds(query: "deck:\"\(escaped)\""))
                    guard !cardIds.isEmpty else { return 0 }
                    try backend.invoke(.scheduleCardsAsNew(cardIds: cardIds, log: true))
                    return cardIds.count
                }
            }
        )
    }()
}

extension DeckResetClient: TestDependencyKey {
    public static let testValue = DeckResetClient()
}

extension DependencyValues {
    public var deckResetClient: DeckResetClient {
        get { self[DeckResetClient.self] }
        set { self[DeckResetClient.self] = newValue }
    }
}
