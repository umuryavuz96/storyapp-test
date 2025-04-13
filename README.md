# Stories App

This is a demonstration app showcasing how to build an Instagram-like stories feature using SwiftUI. The app includes horizontal scrolling story cells with profile pictures, story viewing functionality, like capability, and pagination.

## Features

- Horizontal scrolling stories list with visually appealing UI
- Full-screen story viewing experience
- Progress bar animation when viewing stories
- Like functionality with visual feedback
- State persistence between sessions
- Pagination for loading more stories
- Clean, modular architecture

## Architecture & Technical Approach

I structured this app using The Composable Architecture (TCA) because I wanted to demonstrate a scalable, testable architecture that properly manages state. While it might seem a bit heavyweight for a simple app, it really shines when you start adding more complex features.

### Why TCA?

I chose TCA for several reasons:
- It enforces a unidirectional data flow, making state management predictable
- The modular approach allows components to be developed and tested in isolation
- It provides great support for handling side effects and dependencies
- The architecture naturally scales as the app grows more complex

### Project Structure

The app is organized into several modules:

- **Core**: Contains all the shared services and models
  - ApiModels: Data models used throughout the app
  - NetworkService: Handles API requests and local JSON loading
  - CacheService: Manages data caching
  - ViewedStoriesService: Handles story state persistence

- **Design**: Contains reusable UI components
  - Components: Includes StoryListCellView and other shared UI elements

- **Features**: Contains the main feature modules
  - StoryList: Shows the horizontal list of stories
  - StoryView: Handles the full-screen story viewing experience
  - Home: Combines features into a cohesive home screen

### State Management

Each feature has its own state, action, and reducer:

- **StoryListReducer**: Manages the list of stories, handles pagination, and coordinates with the StoryViewReducer
- **StoryViewReducer**: Manages the story viewing experience, including progress animation and like functionality
- **HomeReducer**: Coordinates between features and handles the overall app experience

State persistence is handled by the ViewedStoriesService, which saves viewed and liked states to a JSON file in the app's documents directory.

## Dependencies

I kept external dependencies to a minimum, only including what was necessary for the architecture:

- **The Composable Architecture**: For state management and UI architecture
- **Dependencies**: A lightweight dependency injection system that works with TCA

I consciously avoided using any libraries for the story viewing animation or UI components, preferring to build these myself to demonstrate understanding of SwiftUI animations and layout.

## Performance Considerations

To ensure the app performs well, I implemented several optimizations:

- **Pagination**: Stories are loaded in batches to minimize memory usage
- **Lazy Loading**: Images are loaded asynchronously using AsyncImage
- **State Updates**: Optimized to only update the UI when necessary

## Challenges & Solutions

### Independent Liked/Viewed States

One interesting challenge was managing the independent viewed and liked states. I implemented a solution where:

- Stories can be either viewed, liked, both, or neither
- The UI accurately reflects these states with appropriate borders and indicators
- State changes are persisted between sessions

### Efficient UI Updates

Updating the UI efficiently when state changes was another challenge. To address this, I:

- Created a dedicated action for updating story states in bulk
- Used a dictionary for faster lookups when updating multiple stories
- Only triggered updates when actual state changes occurred

## Future Improvements

Given more time, I would consider adding:

- More sophisticated animations for transitions
- Story creation functionality
- User authentication
- Real-time synchronization with a backend
- Offline support with local caching

## Building and Running

The app uses Swift 5.9 and targets iOS 17+. To run the app:

1. Clone the repository
2. Open the Xcode project
3. Build and run on a simulator or device

No additional setup or API keys are required as the app uses local JSON data.

## Conclusion

This app demonstrates my approach to building a feature-rich, performant, and maintainable iOS application. By leveraging modern Swift features, SwiftUI, and a solid architecture, I've created an app that not only meets the requirements but is also ready for future expansion. 