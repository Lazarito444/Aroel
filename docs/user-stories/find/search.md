# Find — Search

Epic E6 · Milestone M5 · Source: [`../README.md`](../README.md)

### US-601 · Find "that thing about the balcony"
As a **Writer**, I want one search field that matches even text I never wrote as an entry — day notes and gratitude lines too — with tag and rating filters, entirely offline, so that no memory depends on having filed it. [§5.9]

- Single search field; filters: tag, rating range. [§5.9]
- Index covers entry bodies, **day notes and gratitude lines**. **[invariant: these count as searchable content]** [§5.9]
- Offline FTS5 on device; Postgres FTS server-side when available. **[invariant: works offline]** [§5.9]
- Jump to the matched paragraph. [§5.9]
