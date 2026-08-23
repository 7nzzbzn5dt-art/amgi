import SwiftUI

/// Immediate answer reveal for the native card surface.
///
/// Both reveal and reset deliberately disable animation so the visible side
/// follows `showBack` with zero artificial transition time.
struct FlipContainer<Content: View>: View {
    let showBack: Bool
    @ViewBuilder let content: (_ isBack: Bool) -> Content

    var body: some View {
        content(showBack)
  .id(showBack)
  .transaction { transaction in
      transaction.disablesAnimations = true
  }
    }
}
