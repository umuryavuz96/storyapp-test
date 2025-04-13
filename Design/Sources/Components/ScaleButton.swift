import SwiftUI

public struct ScaleButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(
                .interpolatingSpring(
                    mass: 0.2,
                    stiffness: 100,
                    damping: 10,
                    initialVelocity: 0
                ),
                value: configuration.isPressed
            )
    }
}

public extension ButtonStyle where Self == ScaleButtonStyle {
    static var scale: ScaleButtonStyle { ScaleButtonStyle() }
}

#Preview {
    VStack(spacing: 20) {
        // Basic usage
        Button(action: { print("Tapped!") }) {
            Text("Tap Me")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .buttonStyle(.scale)
        
        // With custom content
        Button(action: { print("Image tapped!") }) {
            Image(systemName: "heart.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
                .padding()
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
        .buttonStyle(.scale)
        
        // Example with StoryListCellView style content
        Button(action: { print("Story tapped!") }) {
            VStack(spacing: 4) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .pink, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 68, height: 68)
                    .overlay(
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 64, height: 64)
                    )
                
                Text("username")
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .frame(width: 70)
            }
            .frame(width: 70)
        }
        .buttonStyle(.scale)
    }
    .padding()
} 
