import AnkiClients
import Dependencies
import Foundation
import PhotosUI
import SwiftUI
import UIKit

struct PhotoAttachmentButton: View {
    @Binding var htmlText: String

    @Dependency(\.mediaImportClient) private var mediaImportClient
    @State private var selectedItem: PhotosPickerItem?
    @State private var isImporting = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
  PhotosPicker(selection: $selectedItem, matching: .images) {
      Label(isImporting ? "Adding Image..." : "Add Image", systemImage: "photo.badge.plus")
          .font(.caption)
  }
  .buttonStyle(.borderless)
  .disabled(isImporting)
  .onChange(of: selectedItem) { _, newItem in
      guard let newItem else { return }
      Task { await importPhoto(newItem) }
  }

  if let errorMessage {
      Text(errorMessage)
          .font(.caption2)
          .foregroundStyle(.red)
  }
        }
    }

    @MainActor
    private func importPhoto(_ item: PhotosPickerItem) async {
        isImporting = true
        errorMessage = nil
        defer {
  isImporting = false
  selectedItem = nil
        }

        do {
  guard let sourceData = try await item.loadTransferable(type: Data.self),
        let image = UIImage(data: sourceData),
        let jpegData = image.jpegData(compressionQuality: 0.92) else {
      throw PhotoAttachmentError.unreadableImage
  }

  let desiredName = "amgi-\(UUID().uuidString).jpg"
  let storedName = try await mediaImportClient.add(jpegData, desiredName)
  let escapedName = storedName
      .replacingOccurrences(of: "&", with: "&amp;")
      .replacingOccurrences(of: "\"", with: "&quot;")
  let imageTag = "<img src=\"\(escapedName)\">"
  htmlText += htmlText.isEmpty ? imageTag : "<br>\(imageTag)"
        } catch {
  errorMessage = "Could not attach image: \(error.localizedDescription)"
        }
    }
}

private enum PhotoAttachmentError: LocalizedError {
    case unreadableImage

    var errorDescription: String? {
        "The selected photo could not be converted to an image."
    }
}
