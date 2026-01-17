import SwiftUI

struct ToastView: View {
    @Binding var message: String
    @Binding var isShowing: Bool

    var body: some View {
        if isShowing {
            HStack(spacing: 12) {
                Image(systemName: message.contains("Error") ? "xmark.circle.fill" : "checkmark.circle.fill")
                    .foregroundColor(message.contains("Error") ? .red : .green)
                    .font(.title3)

                Text(message)
                    .font(.body)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

#Preview {
    VStack {
        Spacer()
        ToastView(message: .constant("Link Copied! ✓"), isShowing: .constant(true))
            .padding()
    }
    .frame(width: 400, height: 300)
}
