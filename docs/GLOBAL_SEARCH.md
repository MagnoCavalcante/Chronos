# CHRONOS — Global Search Engine Architecture
## RFC-009 — Experience Layer (Sprint 5.2.0)

This document details the architectural decisions, structural implementation, and search algorithms developed for the **CHRONOS Global Search MVP**.

---

## 1. Architectural Design Overview

The Global Search engine is integrated into the CHRONOS platform as a core navigation vector. In compliance with CHRONOS architecture rules, it uses a decoupled, unified approach that consumes domain controllers exclusively, preventing any direct access to Infrastructure DataSources or Repositories from the Presentation layer.

```
       +------------------------------------+
       |          GlobalSearchPage          | <---+ Main Navigation Tab
       +------------------------------------+
                         |
                         v (ListenableBuilder)
       +------------------------------------+
       |       ChronosSearchController      |
       +------------------------------------+
           |             |            |
           v             v            v
      [ErasCtrl]    [EventsCtrl]  [CharactersCtrl] ... (Domain Controllers)
```

### Key Components:
1. **`ChronosSearchController`**: The central state manager that aggregates real-time records from all domain-specific controllers (`ErasController`, `HistoricalEventsController`, `HistoricalCharactersController`, `CivilizationsController`, `ArtifactsController`, `HistoricalLocationsController`) into a unified indexing model.
2. **`SearchResultItem`**: A wrapper that pairs a unified rendering display (`ChronosEntityDisplay`) with the raw domain Entity.
3. **`SearchInputBar`**: A high-fidelity input widget based on `ChronosSearchBar` supporting real-time reactive search queries.
4. **`SearchFilters`**: Standard category-filtering horizontal segment selectors paired with an elegant popup menu sorting controller.
5. **`SearchResults`**: The dynamic rendering listing grid/container with integrated item count and blank-state handler.
6. **`SearchResultCard`**: A custom-drawn, high-fidelity result card that provides **Relevance Highlights** matching exact substring indices while maintaining original case-sensitivities.

---

## 2. Advanced Search & Sorting Algorithm

### 2.1 Incremental Search with Debounce
To guarantee maximum frame rates (60fps/120fps) on weak hardware (mobile, web) during fast text entries, we implemented an asynchronous debounce timer.
- Standard delay: **300ms**
- Cancels trailing timers upon keypress to avoid visual stuttering and duplicate filtering operations.

### 2.2 Reconstructive Scoring (Relevance Mode)
When the user types a query, each matching result receives an algorithmic score based on occurrence fields:
- **Exact Prefix Match on Title**: `+100` points.
- **Generic Match on Title**: `+50` points.
- **Subtitle Match**: `+25` points.
- **Description Match**: `+10` points.

Items are sorted descendingly by their relevance score, falling back to case-insensitive alphabetical sorting on equal scores.

### 2.3 Comprehensive Sort Modes
1. **Relevance**: Dynamic scoring based on key matching fields.
2. **Alphabetical**: Standard case-insensitive sorting on entity titles.
3. **Chronological**: Strict ascending chronological order using `chronologyValue` (negative integers for B.C. years, positive integers for A.D. years), seamlessly handling null values.

---

## 3. High-Fidelity UI & Relevance Highlights

We implemented a custom substring extraction algorithm within `SearchResultCard` to dynamically inject `RichText` widgets with custom styling highlights:
- **Matching Text**: Highlighted with `ChronosColors.accent` background color with light opacity, emphasizing matches.
- **Surrounding Text**: Renders original typography styles.
- **Case-Insensitive Splitting**: Finds matches regardless of typing casing while retaining the database's original capitalization.

---

## 4. Navigation & Details Integration

Each search card wraps standard entity display mapping so that clicking a search result navigates directly to the unified, dynamic **`EntityDetailsPage`** (`RFC-008`). It resolves descriptors and metadata dynamically through the global `EntityRegistry`, keeping details modular and decoupled.
