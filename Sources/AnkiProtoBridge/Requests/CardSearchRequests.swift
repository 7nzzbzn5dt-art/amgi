import Foundation
public import AnkiBackend
public import AnkiKit
import AnkiProto
import SwiftProtobuf

extension Request where Response == [CardID] {
    /// Runs an Anki card search and returns matching card IDs.
    public static func searchCardIds(query: String) -> Self {
        Self(
  serviceId: ServiceID.search,
  methodId: SearchMethod.searchCards,
  encode: {
      var proto = Anki_Search_SearchRequest()
      proto.search = query.isEmpty ? "deck:*" : query
      return try proto.serializedData()
  },
  decode: { bytes in
      let response = try Anki_Search_SearchResponse(serializedBytes: bytes)
      return response.ids.map(CardID.init)
  }
        )
    }
}
