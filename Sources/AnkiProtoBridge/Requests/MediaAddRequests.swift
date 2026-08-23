public import Foundation
public import AnkiBackend
public import AnkiKit
import AnkiProto
import SwiftProtobuf

extension Request where Response == String {
    /// Adds bytes through Anki's media service and returns the actual stored
    /// filename (the backend may rename it to avoid a collision).
    public static func addMediaFile(data: Data, desiredName: String) -> Self {
        Self(
            serviceId: ServiceID.media,
            methodId: MediaMethod.addMediaFile,
            encode: {
                var proto = Anki_Media_AddMediaFileRequest()
                proto.desiredName = desiredName
                proto.data = data
                return try proto.serializedData()
            },
            decode: { bytes in
                try Anki_Generic_String(serializedBytes: bytes).val
            }
        )
    }
}
