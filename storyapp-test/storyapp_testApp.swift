import SwiftUI
import ComposableArchitecture
import ApiModels
import Dependencies

@main
struct storyapp_testApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(
                store: Store(
                    initialState: HomeReducer.State(),
                    reducer: { HomeReducer() }
                )
            )
        }
    }
}
