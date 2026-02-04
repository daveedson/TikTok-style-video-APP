# TakTik - TikTok-Style Video App

A TikTok-style short video feed app built with SwiftUI. This was a fun project to explore vertical video feeds, video player management, and smooth scrolling experiences.

## Design Preview 
<img width="1065" height="854" alt="Screenshot 2026-02-04 at 6 55 56 AM" src="https://github.com/user-attachments/assets/efa8aef6-327a-4f46-9b37-c75f82a3738e" />

## App ScreenShot
<img width="368" height="734" alt="Screenshot 2026-02-04 at 6 02 46 PM" src="https://github.com/user-attachments/assets/5fa0b3ba-67f5-4386-967c-ff1adac192c8" />
<img width="376" height="755" alt="Screenshot 2026-02-04 at 6 01 38 PM" src="https://github.com/user-attachments/assets/187746ae-2f7c-4816-8743-0862438fc71a" />
<img width="362" height="734" alt="Screenshot 2026-02-04 at 6 01 57 PM" src="https://github.com/user-attachments/assets/c791466c-e36f-4fb4-a2fb-8817f55cfc00" />
<img width="371" height="748" alt="Screenshot 2026-02-04 at 6 02 26 PM" src="https://github.com/user-attachments/assets/f278df09-1d0b-4e03-8501-9f891082c79e" />

## What I Built


- Vertical scrolling video feed (like TikTok's "For You" page)
- Profile page with video grid
- Like and bookmark functionality (persisted locally)
- Tap to pause/play
- Smooth video transitions when scrolling

## Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/yourusername/TikTok-style-video-APP.git
   ```

2. **Add your API key**
   ```bash
   cd TikTok-Style-App/TikTok-Style-App/Config
   cp Keys.swift.template Keys.swift
   ```
   Then open `Keys.swift` and add your [Pexels API key](https://www.pexels.com/api/).

3. **Open in Xcode**
   ```bash
   open TikTok-Style-App.xcodeproj
   ```

4. **Run it**
   - Select a simulator (iPhone 14 Pro or newer recommended)
   - Hit `Cmd + R`

## Architecture

```
├── Core/
│   ├── Models/          # Video, User, API response models
│   ├── Network/         # API calls (Alamofire)
│   ├── Player/          # Video player + manager
│   ├── Local/           # UserDefaults persistence
│   └── Services/        # VideoService
│
├── Features/
│   ├── Feed/            # Main video feed
│   ├── Profile/         # User profile + video grid
│   └── Splash/          # Launch screen
```

**Key pieces:**

- **MVVM pattern** - Views observe ViewModels, ViewModels handle logic
- **VideoPlayerManager** - Singleton that manages all AVPlayers
- **LikesStore** - Saves liked/bookmarked videos to UserDefaults

### How I Handled Virtualization

Memory is a big deal when playing videos. Here's what I did:

1. **Only 3 players in memory** - The `VideoPlayerManager` keeps a max of 3 AVPlayer instances (current video + one above + one below). When you scroll past that, old players get released.

2. **LazyVStack** - Videos are loaded lazily as you scroll. SwiftUI only creates views when they're about to appear.

3. **Paging scroll** - Using `.scrollTargetBehavior(.paging)` so each video snaps to full screen, making it easy to track which video should be playing.

```swift
// From VideoPlayerManager.swift
private let maxCachedPlayers = 3

private func cleanupIfNeeded(currentId: Int) {
    guard players.count > maxCachedPlayers else { return }
    let idsToKeep = Set([currentId - 1, currentId, currentId + 1])
    // Release everything else...
}
```

## Limitations

**What's not perfect:**

- **No real user accounts** - Profile is just mock data. Likes/bookmarks are stored locally only.
- **Video quality** - Using whatever Pexels gives us. No adaptive bitrate.
- **No caching of video files** - Videos re-buffer if you scroll back to them.
- **Close button on profile video player** - Has some gesture conflicts (still working on this).
- **Basic error handling** - Could be more graceful when network fails.

**Design vs Reality:**

I tried to match the design as closely as possible, but some things are simplified:
- Music/audio visualization not implemented
- Comments section not built
- Share functionality is UI-only

## What I'd Do With More Time

**1. Use HLS/DASH protocols**

Right now I'm just fetching video URLs from Pexels API and playing them directly. In a real app, I'd use:
- **HLS (HTTP Live Streaming)** for adaptive bitrate
- **DASH** as an alternative
- This would give better quality on good connections and prevent buffering on slow ones

**2. Video preloading**

Preload the next 2-3 videos while watching the current one. The infrastructure is there (`preload` method exists) but it's not being used effectively.

**3. Disk caching**

Cache video segments to disk so rewatching doesn't need network. Something like:
- First 5 seconds cached for quick replay
- Full video cached after watching 50%+

**4. Better state management**

Move to a more robust solution like TCA (The Composable Architecture) for:
- Cleaner data flow
- Easier testing
- Better side effect handling

**5. Real backend**

- User authentication
- Cloud-synced likes/bookmarks
- Actual video upload functionality
- Comments and social features

## Tech Stack

- **SwiftUI** - UI framework
- **AVFoundation** - Video playback
- **Alamofire** - Networking
- **Pexels API** - Video content
- **UserDefaults** - Local persistence


---

Built by David Onoh
