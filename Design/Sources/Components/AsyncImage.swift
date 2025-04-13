import SwiftUI
import Dependencies
import CacheService
import UIKit

// Pulsing effect modifier
private struct PulsingEffect: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.3),
                                Color.purple.opacity(0.3),
                                Color.pink.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(isPulsing ? 1.1 : 1.0)
                    .opacity(isPulsing ? 0.5 : 0.3)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isPulsing
                    )
            )
            .onAppear {
                isPulsing = true
            }
    }
}

private extension View {
    func pulsing() -> some View {
        modifier(PulsingEffect())
    }
}

public struct AsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    @State private var imageData: Data?
    @State private var isLoading = true
    
    @Dependency(\.cacheService) private var cacheService
    
    public init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    public var body: some View {
        Group {
            if let imageData = imageData,
               let uiImage = UIImage(data: imageData) {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .pulsing()
                    .task {
                        await loadImage()
                    }
            }
        }
    }
    
    private func loadImage() async {
        guard let url = url else {
            return 
        }
        let cacheKey = url.absoluteString
        
        // Try to get from cache first
        if let cachedData = cacheService.get(cacheKey) {
            await setImageData(cachedData)
            return
        }
        
        // If not in cache, load from network
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    return
                }
            }
            
            // Cache the downloaded data
            cacheService.set(data, cacheKey)
            await setImageData(data)
        } catch {
        }
    }
    
    @MainActor
    private func setImageData(_ data: Data) {
        self.imageData = data
        self.isLoading = false
    }
}

// Convenience initializer for common use case
public extension AsyncImage where Content == Image, Placeholder == ProgressView<EmptyView, EmptyView> {
    init(url: URL) {
        self.init(
            url: url,
            content: { $0 },
            placeholder: { ProgressView() }
        )
    }
} 

#Preview {
    VStack(spacing: 20) {
        // Basic usage with pulsing
        AsyncImage(url: URL(string: "https://i.pravatar.cc/300?u=1")!)
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        
        // Custom content and pulsing placeholder
        AsyncImage(
            url: URL(string: "https://i.pravatar.cc/300?u=1")!,
            content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            },
            placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 300, height: 200)
            }
        )
        
        // Loading state with custom pulsing placeholder
        AsyncImage(
            url: URL(string: "https://i.pravatar.cc/300?u=1")!,
            content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
            },
            placeholder: {
                VStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 200)
                    Text("Loading image...")
                        .foregroundColor(.gray)
                }
                .frame(height: 200)
            }
        )
    }
    .padding()
} 
