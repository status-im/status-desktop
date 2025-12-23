# Jump to screen (Home Page) FURPS ([#17971](https://github.com/status-im/status-app/issues/17971))

## Functionality
- Support navigation to communities, chats, accounts, or dApps through a unified launcher interface.
- Display recent items with live metadata (e.g., unread count, media preview, timestamps).
- Order from most recent. When item is clicked, it moves to the top.
- Bottom navigation shows main sections and pinned items.
- Items can be pinned and unpinned from the bottom navigation.

## Usability
- Provide a visually clear grid layout for quick access.
- Offer intuitive icons and labels for each tile.
- Use familiar interaction patterns (hover, click, unread badges, etc.).
- Allow search or filtering through the top input (placeholder suggests "Jump to...").

## Reliability
- Ensure tile content updates in real-time or on refresh (e.g., unread status, timestamps).
- Maintain stability when rapidly switching or searching.
- Handle missing or malformed data gracefully (e.g., default thumbnails, fallback titles).

## Performance
- Fast rendering of tiles with smooth animations and no visual lag.
- Optimize for low memory/CPU impact, especially with media previews.
- Quick response when jumping to a tile target (chat, community, etc.).

## Supportability
- Built modularly to allow adding/removing content types (e.g., NFTs, media, tokens).
- Testable interface components with mockable data (storybook).
