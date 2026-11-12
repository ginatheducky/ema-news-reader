# How it works

[README](../README.md) · [Project map](project-map.md)

## Follow a news feed

Events and guidelines use the same sequence with their own feed types, mappers, and loaders.

1. `NewsFeedLoader.load(from:)` asks `EMAClient` for bytes from the supplied URL. The client uses `URLSession.shared` by default and accepts HTTP responses with status codes from 200 through 299.
2. The loader decodes the bytes into a `NewsFeed` using `JSONDecoder`. The feed contains a `data` array of `NewsRecord` values and a `meta` object. Dates, flags, and links still have their source string values at this stage.
3. `NewsItemMapper` converts each usable record into a `NewsItem`. For example, `Yes` becomes `true`, semicolon-separated categories become an array of trimmed names, and the source link becomes a validated HTTPS `URL`.
4. The loader returns a `LoadedNewsFeed` with the mapped items and the original metadata. EMA's record count can differ from the number of usable items.

All three mappers parse publication dates in `dd/MM/yyyy` format. An empty or invalid update date becomes `nil`. The News mapper turns an empty summary into `nil`. The events mapper keeps the schedule in its original text form.

## When something fails

| Situation | Result |
| --- | --- |
| Request fails, response is non-HTTP, or HTTP status is outside the 2xx range | The load throws before decoding. |
| JSON cannot decode into the feed type | The load throws for the whole feed. |
| A record decodes but a required value fails mapping | The loader skips that record and keeps any usable items. |
| A nonempty feed has no usable records | The loader throws `noUsableRecords`. |
| The feed has an empty `data` array | The loader returns an empty item array with metadata. |

## App startup and refresh

`ema_news_readerApp.swift` creates one shared `EMAClient` and three observable stores, one per feed. The app injects the stores into the SwiftUI environment. When the scene first becomes active or returns to the foreground, it asks all three stores to refresh concurrently if needed. Tab selection does not trigger a fetch.

`NewsStore` keeps the loaded feed, loading state, most recent error, and last successful check in memory. An automatic refresh runs when there is no loaded feed or more than one hour has elapsed since the last successful check. Exactly one hour still counts as fresh. Pull to refresh and Retry call the manual refresh method, which skips the freshness check. An in-flight guard prevents overlapping requests to the same store.

A successful load replaces the feed and records the check time. A failed refresh keeps the previous feed and records the error. Cancellation leaves the previous feed and check time intact without reporting a refresh error.

## From the News tab to an EMA article

1. `ContentView` starts on Briefing and offers News, Events, Briefing, Guidelines, and Media tabs. News uses the shared store. The other tabs currently show placeholders, including Events and Guidelines, whose feeds already load at app scope.
2. `NewsScreen` observes the store. It handles first-load progress and errors, and keeps a loaded list visible if a later refresh fails.
3. `NewsListView` shows an empty state or a scrollable stack of `NewsCard` views. Each card opens its article in a `NavigationStack`.
4. `NewsDetailView` shows the title, date-only publication and update dates, and available summary, categories, topics, and related medicines or referrals. Press releases get a conditional label. The source action opens the original EMA article via its URL.

## Offline previews

`NewsPreview.json` supplies bundled News data. `NewsItemPreview.swift` can decode and map it for card, list, and detail previews, or supply the raw bytes to a stubbed client for previews that exercise the store and loader.
