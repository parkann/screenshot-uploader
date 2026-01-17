import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)

                Text(message)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            .padding(.top, 20)

            Spacer()
        }
        .animation(.spring(), value: message)
    }
}
