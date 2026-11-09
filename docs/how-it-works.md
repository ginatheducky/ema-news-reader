# How it works

[README](../README.md) · [Project map](project-map.md)

## Follow a news feed

Events and guidelines use the same sequence with their own feed types, mappers, and loaders.

1. `NewsFeedLoader.load(from:)` asks `EMAClient` for bytes from the supplied URL. The client uses `URLSession.shared` by default and accepts HTTP responses with status codes from 200 through 299.
2. The loader decodes the bytes into a `NewsFeed` using `JSONDecoder`. The feed contains a `data` array of `NewsRecord` values and a `meta` object. Dates, flags, and links still have their source string values at this stage.
3. `NewsItemMapper` converts each usable record into a `NewsItem`. For example, `Yes` becomes `true`, semicolon-separated categories become an array of trimmed names, and the source link becomes a validated HTTPS `URL`.
4. The loader returns a `LoadedNewsFeed` with the mapped items and the original metadata. EMA's record count can differ from the number of usable items.

All three mappers parse publication dates in `dd/MM/yyyy` format. An empty or invalid update date becomes `nil`. The events mapper keeps the schedule in its original text form.

## When something fails

| Situation | Result |
| --- | --- |
| Request fails, response is non-HTTP, or HTTP status is outside the 2xx range | The load throws before decoding. |
| JSON cannot decode into the feed type | The load throws for the whole feed. |
| A record decodes but a required value fails mapping | The loader skips that record and keeps any usable items. |
| A nonempty feed has no usable records | The loader throws `noUsableRecords`. |
| The feed has an empty `data` array | The loader returns an empty item array with metadata. |

## Where SwiftUI fits today

The app starts in `ema_news_readerApp.swift` and opens `ContentView`. The view shows placeholder text and does not call the loaders. The [app design](description-and-technical-design.md) describes the planned screen behavior, refresh, and local storage.
