# EMA News Reader

**European Medicines Agency news, in a native SwiftUI app for iPhone and iPad.**

![Platform: iOS and iPadOS](https://img.shields.io/badge/platform-iOS%20%7C%20iPadOS-blue)
![Built with SwiftUI](https://img.shields.io/badge/built%20with-SwiftUI-orange)
[![License: GPL v3](https://img.shields.io/badge/license-GPL%20v3-blue)](LICENSE)

EMA News Reader brings the European Medicines Agency's public news feed into a focused reading interface. Browse the latest announcements, search for relevant stories, filter by category and topic, and keep track of articles you have opened or that have changed since a previous download.

The project is open source and under active development. News browsing and a configurable briefing are implemented; Events, Guidance, and Media are currently placeholder tabs.

This is an independent project and is not affiliated with or endorsed by the European Medicines Agency. News content comes from EMA; each article includes a link to its original source.

## Contents

- [App overview](#app-overview)
- [Downloading and offline access](#downloading-and-offline-access)
- [Article badges](#article-badges)
- [Search and filters](#search-and-filters)
- [Architecture and local storage](#architecture-and-local-storage)
- [Repository file guide](#repository-file-guide)
- [Testing](#testing)
- [Roadmap](#roadmap)
- [License](#license)

## App overview

| Area | What it offers today |
| --- | --- |
| **News** | A newest-first list of EMA news, title and summary search, category and topic filters, a count of new articles in the current results, and manual refresh. |
| **Article details** | The feed's summary, categories, topics, available publication and update dates, and an **Open original article** link. |
| **Your Briefing** | The default opening tab, showing the two latest articles and the last successful check time. **See all** opens News. |
| **Briefing editor** | Show or hide the news section. **Save** persists the choice; **Cancel** discards the draft. |
| **Offline access** | Previously saved feed entries and their summaries remain available when a download fails. |
| **Events, Guidance, Media** | Placeholders for future development, including a planned video section. |

The briefing currently shows the two latest articles regardless of read status, NEW badges, or filters selected in News. Hiding its news section does not disable feed loading.


## Downloading and offline access

### When news is downloaded

- **At app startup:** the root view requests an initial load. The store first attempts to restore its saved snapshot, then requests the EMA feed.
- **On demand:** use **Refresh news** in the News tab to request a fresh download. If no news is available, use **Load EMA news** or **Try again**.
- **Across tabs:** News and Your Briefing share one store. Switching tabs does not itself trigger another download once articles have loaded.

There is currently no scheduled background refresh, periodic polling, or automatic refresh on returning from the background. A load already in progress prevents another simultaneous load in the same store.

### What is downloaded

The app fetches EMA's English-language [news JSON report](https://www.ema.europa.eu/en/documents/report/news-json-report_en.json). It decodes the feed, sorts entries by their first publication date, and removes duplicate article URLs. Entries with missing or invalid publication dates appear after dated entries.

The downloaded data contains article metadata and summaries. **Full article web pages, images, videos, and attachments are not downloaded for offline use.** Opening the original article follows an external web link and normally requires internet access.

### What happens if a download fails

Previously loaded or restored news stays available. The News tab reports the failure and allows another refresh. **Last checked** records the most recent successful download, rather than the most recent attempt or EMA's own publication time.

Without a saved snapshot, an unsuccessful first download leaves the app without articles and offers a retry. If news loads successfully but saving fails, the News tab warns that the latest changes could not be saved for offline use.

## Article badges

Badges describe the app's local reading history and comparisons between downloaded snapshots.

| Badge | Meaning | When it clears |
| --- | --- | --- |
| **Read** | You have opened this article's detail screen from News or Your Briefing. Opening the original website is not required. | Read status is saved locally; there is currently no mark-as-unread control. |
| **NEW** | The article URL was absent from the previous loaded snapshot and has not already been marked read. | Opening its details clears the badge. A later download that finds another batch of added URLs replaces the previous NEW batch. |
| **UPDATED** | An existing URL has changed since the previous snapshot: title, summary, categories, topics, first publication date, or a newly available/later valid update date. | Opening the current downloaded version clears the badge. It otherwise persists across refreshes while the article remains in the feed. |

**NEW does not mean “published today” or simply “unread.”** On the first successful download without an earlier snapshot, no articles are marked NEW or UPDATED because there is nothing to compare against. A saved snapshot provides the comparison baseline on later launches.

If a refresh adds no new URLs, existing NEW badges remain for articles still in the feed that have not been read. If a refresh does add URLs, only unread articles in that latest addition batch receive NEW badges. Articles that disappear from the feed lose their NEW and UPDATED tracking.

An article can display **Read** and **UPDATED** together: you opened it previously, but the app has since detected a change. The update date in article details is supplied by EMA; an UPDATED badge is the app's own change detection, so the two do not always appear together.

## Search and filters

- **Search** matches text in article titles and summaries. Leading and trailing whitespace is ignored, and matching uses localized, case- and diacritic-insensitive text comparison.
- **Categories** and **Topics** come from values present in the loaded feed. Each menu supports multiple selections.
- **Match any selected** includes articles containing at least one selected value in that group. This is the default.
- **Match all selected** includes articles containing every selected value in that group.
- An empty selection leaves that group unrestricted.

Search, category filters, and topic filters combine: an article must satisfy **all three groups** to appear.

For example, selecting **Human** and **Veterinary** in Categories with **Match any selected** includes articles tagged with either category. Switching to **Match all selected** requires both. Adding a topic selection further narrows those results.

The red number on each filter button shows how many values are selected in that menu. It is not an article count. The new-article count above the list counts NEW articles within the current search and filter results.

Use **Clear categories** and **Clear topics** in their respective menus to remove selections, and clear the search field to remove the text query. There is currently no single reset-all control. Category/topic selections and their matching modes persist between launches; search text does not.

If results look unexpectedly empty, check saved filters. A previously selected category or topic can remain selected even if it is absent from the current feed; clearing that filter group removes it.

## Architecture and local storage

The app separates feed handling, shared state, persistence, and presentation:

```text
EMA JSON feed → NewsService → NewsStore → News and Your Briefing
                                 ↕
                         NewsCache / NewsSnapshot

UserDefaults → read history, filter preferences, briefing preference
```

- **SwiftUI** renders the interface; an observable, main-actor `NewsStore` owns the shared news state.
- **Foundation / URLSession** downloads the feed. Models decode its fields and implement sorting, filtering, date parsing, and change detection.
- **NewsCache** is an actor that reads and atomically writes a JSON snapshot in the app's Application Support directory at `EMAReader/news-state-v1.json`. The snapshot contains articles, NEW/UPDATED URL sets, and the last successful refresh time.
- **UserDefaults** stores read article URLs, category/topic selections and matching modes, and whether the briefing shows news.

These preferences and reading indicators are local to the app installation. There is no account or cross-device synchronization. The current source contains no analytics integration. Network requests go to EMA for the feed; following an original-article link opens its destination website.

## Repository file guide

This guide covers the tracked project files. Xcode-generated build output and personal workspace settings are excluded.

### Repository root

| File | Purpose |
| --- | --- |
| [README.md](README.md) | Project overview, setup, behavior, and contributor entry point. |
| [LICENSE](LICENSE) | GNU General Public License, version 3. |
| [.gitignore](.gitignore) | Excludes local macOS files, Xcode user settings, and temporary lock files. |

### App source

Files below are in [`ema-news-reader/ema-news-reader/`](ema-news-reader/ema-news-reader/).

| File | Purpose |
| --- | --- |
| [ema_news_readerApp.swift](ema-news-reader/ema-news-reader/ema_news_readerApp.swift) | App entry point; creates the window containing `ContentView`. |
| [ContentView.swift](ema-news-reader/ema-news-reader/ContentView.swift) | Main tabs, shared store creation, initial loading, briefing content, and briefing editor presentation. Includes placeholder tabs and sample previews. |
| [BriefingEditor.swift](ema-news-reader/ema-news-reader/BriefingEditor.swift) | Form for editing the briefing's news visibility with Save and Cancel actions. |
| [LiveNewsView.swift](ema-news-reader/ema-news-reader/LiveNewsView.swift) | Connects the store to the news list and presents loading, download errors, cache warnings, refresh controls, and the last-check time. |
| [NewsView.swift](ema-news-reader/ema-news-reader/NewsView.swift) | Searchable, filterable article list; filter menus and saved preferences; new-result count; navigation and empty states. |
| [NewsCard.swift](ema-news-reader/ema-news-reader/NewsCard.swift) | Reusable article card with title, categories, topics, and Read/NEW/UPDATED badges. |
| [NewsDetailView.swift](ema-news-reader/ema-news-reader/NewsDetailView.swift) | Article summary and metadata, valid date display, and link to the original article. |
| [FilterMenuLabel.swift](ema-news-reader/ema-news-reader/FilterMenuLabel.swift) | Filter button icon with selection-count badge and accessibility descriptions. |
| [NewsFeed.swift](ema-news-reader/ema-news-reader/NewsFeed.swift) | `NewsFeed` and `NewsRecord` models, JSON field mapping, sample articles, date and URL validation, category/topic parsing, sorting, search/filter rules, and change detection. |
| [NewsService.swift](ema-news-reader/ema-news-reader/NewsService.swift) | Downloads the EMA report, validates HTTP responses, decodes JSON, sorts articles, and removes duplicate URLs. |
| [NewsStore.swift](ema-news-reader/ema-news-reader/NewsStore.swift) | Shared observable state: loading, errors, read history, NEW/UPDATED detection, timestamps, cache restoration, and queued snapshot saves. |
| [NewsCache.swift](ema-news-reader/ema-news-reader/NewsCache.swift) | Actor-based JSON snapshot storage, directory creation, and atomic writes. |
| [NewsSnapshot.swift](ema-news-reader/ema-news-reader/NewsSnapshot.swift) | Codable snapshot model for articles, badge state, and successful-refresh time. |

### Assets and Xcode configuration

| File | Purpose |
| --- | --- |
| [Assets.xcassets/Contents.json](ema-news-reader/ema-news-reader/Assets.xcassets/Contents.json) | Asset catalog metadata. |
| [AccentColor.colorset/Contents.json](ema-news-reader/ema-news-reader/Assets.xcassets/AccentColor.colorset/Contents.json) | Accent-color asset definition. |
| [AppIcon.appiconset/Contents.json](ema-news-reader/ema-news-reader/Assets.xcassets/AppIcon.appiconset/Contents.json) | App-icon slots and asset metadata. |
| [project.pbxproj](ema-news-reader/ema-news-reader.xcodeproj/project.pbxproj) | Xcode targets, build settings, signing configuration, deployment targets, and source-folder references. |
| [contents.xcworkspacedata](ema-news-reader/ema-news-reader.xcodeproj/project.xcworkspace/contents.xcworkspacedata) | Internal workspace reference for the Xcode project. |

### Tests

| File | Purpose |
| --- | --- |
| [ema_news_readerTests.swift](ema-news-reader/ema-news-readerTests/ema_news_readerTests.swift) | Swift Testing coverage for response decoding, model validation, sorting/search/filtering, loading and refresh failures, timestamps, read persistence, badges, and cache behavior. |
| [ema_news_readerUITests.swift](ema-news-reader/ema-news-readerUITests/ema_news_readerUITests.swift) | XCTest UI scaffolding with a basic launch example and launch-performance measurement. |
| [ema_news_readerUITestsLaunchTests.swift](ema-news-reader/ema-news-readerUITests/ema_news_readerUITestsLaunchTests.swift) | Launch checks across UI configurations with screenshot attachments. |


## Roadmap

Potential next steps, without a fixed release schedule:

- Add a single control to reset search and all filters.
- Offer a briefing focused on newly detected articles.
- Refine the placement of the UPDATED badge.
- Implement the Events, Guidance, and Media tabs.
- Expand UI and accessibility test coverage.
- Align deployment settings and document a verified Xcode/OS support matrix.

Filter-selection badges and a new-article count in filtered results are already implemented. 


## License

The project includes the [GNU General Public License, version 3](LICENSE). See the license file for its full terms. EMA news content remains attributed to its original publisher; the repository's software license does not establish a license for third-party content.
