# Project map

[README](../README.md) · [How it works](how-it-works.md)

| Folder | What's there |
| --- | --- |
| `apps/apple/` | The SwiftUI app and its Xcode project. Open `ema-news-reader.xcodeproj` here. |
| `sample-data/` | Example EMA JSON payloads for news, events, and scientific guidelines. |
| `docs/` | Project notes, the original design, and its mockups in `images/`. |

The following paths start at `apps/apple/ema-news-reader/`.

| File or folder | What it does |
| --- | --- |
| `ema_news_readerApp.swift` | SwiftUI entry point. Creates a window with `ContentView`. |
| `ContentView.swift` | Root view with placeholder text and its Xcode preview. |
| `Assets.xcassets/` | Asset catalog with entries for the app icon and accent color. |
| `Models/NewsItem.swift` | App model for a news article, including its summary, topics, categories, and source link. |
| `Models/EventItem.swift` | App model for an event, including its schedule text, online and broadcast flags, and optional location. |
| `Models/GuidelineItem.swift` | App model for a guideline, including its categories, publication dates, and source link. |
| `Services/EMA/EMAClient.swift` | Fetches response bytes and validates the HTTP status. |
| `Services/EMA/EMARecordParsing.swift` | Validates record links as absolute HTTPS URLs with a host. |
| `Services/EMA/MetaData.swift` | Models the total record count and timestamp in the feed's `meta` object. |

## Feed files

Each feed has its own folder under `Services/EMA/`.

| Folder | File | What it does |
| --- | --- | --- |
| `News/` | `NewsFeed.swift` | Models the news JSON and maps EMA keys to Swift properties. |
| | `NewsItemMapper.swift` | Converts a news record into a `NewsItem`, including dates, list fields, and the press release flag. |
| | `NewsFeedLoader.swift` | Fetches, decodes, and maps a news feed. Returns items and metadata. |
| `Events/` | `EventsFeed.swift` | Models the events JSON, including the source schedule and flags. |
| | `EventItemMapper.swift` | Converts dates and flags, keeps the schedule text, and turns an empty location into `nil`. |
| | `EventsFeedLoader.swift` | Fetches, decodes, and maps an events feed. Returns items and metadata. |
| `Guidelines/` | `GuidelinesFeed.swift` | Models the guidelines JSON, including the `url` key for the guideline link. |
| | `GuidelineItemMapper.swift` | Converts dates and splits the category string into a list. |
| | `GuidelinesFeedLoader.swift` | Fetches, decodes, and maps a guidelines feed. Returns items and metadata. |
