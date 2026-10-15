#pragma once

#include <QString>
#include <QStringView>
#include <QTextBoundaryFinder>
#include <QVector>

// A small, GUI-free AST for the simplified, line-oriented markdown dialect used
// by the chat input. The tree is the single source of truth: consumers walk it
// to apply live syntax highlighting, to emit static formatted text, etc.
//
// Formatting characters (** , *, ~~, `, ```, "> ", fence info strings) are kept
// as first-class Delimiter leaf nodes so a consumer can decide to render them
// (live input highlighting) or to skip them (static text rendering).
namespace Markdown {

enum class NodeKind {
    Document,       // root

    // Block-level
    Paragraph,
    QuoteBlock,
    CodeBlock,      // fenced (```), content is not re-parsed

    // Inline formatting containers
    Strong,         // bold
    Emphasis,       // italic
    Strikethrough,
    CodeSpan,       // inline `code`, content is not re-parsed
    Link,           // auto-detected URL, or an explicit [label](url) link. Auto links hold a
                    // single Text child (= the URL); explicit links hold '[' / label / '](url)'
                    // as Delimiter + Text + Delimiter children. `destination` is the URL in both.
    WalletLink,     // auto-detected wallet address / ENS name → send-via-personal-chat
                    // link; `destination` holds the raw match (address or ENS name)

    // Leaves
    Text,           // literal content
    Delimiter,      // formatting characters (**, *, ~~, `, ```, "> ", fence info)
    Mention,        // embedded object (ObjectReplacementCharacter); metadata lives
                    // in the document char format, not in the AST
};

struct Node {
    NodeKind kind = NodeKind::Document;

    // Source range [start, end) over the original full text passed to parse().
    qsizetype start = 0;
    qsizetype end   = 0;

    QString literal;       // Text / Delimiter / CodeBlock+CodeSpan content
    QString destination;   // Link only — the URL

    QVector<Node> children;
};

// Serializes the AST into a readable, indented-tree textual form used by golden
// unit tests. With `withRanges` each node line includes its [start,end) range.
//
// Example for `Some **bold** text` (withRanges = true):
//
//   Document [0,18)
//     Paragraph [0,18)
//       Text [0,5) "Some "
//       Strong [5,13)
//         Delimiter [5,7) "**"
//         Text [7,11) "bold"
//         Delimiter [11,13) "**"
//       Text [13,18) " text"
QString dump(const Node& node, bool withRanges = true);

// Quick, range-based emoji detector (not a full Unicode emoji property test). Covers the
// common emoji blocks plus the joiners/modifiers that are part of an emoji grapheme cluster
// (ZWJ, variation selectors, regional indicators, keycap combiners) so a whole emoji
// sequence is treated as one unit. Shared by the live highlighter and the static renderer.
constexpr bool isEmojiCodePoint(char32_t cp) {
    return (cp >= 0x1F300 && cp <= 0x1FAFF) // emoticons / pictographs / transport
           // / supplemental / extended-A
           || (cp >= 0x1F000 && cp <= 0x1F0FF) // mahjong, dominoes, playing cards
           || (cp >= 0x2600 && cp <= 0x27BF)   // misc symbols + dingbats
           ||
           (cp >= 0x1F1E6 && cp <= 0x1F1FF) // regional indicator letters (flags)
           || (cp == 0x231A) || (cp == 0x231B) // ⌚ ⌛
           || (cp >= 0x23E9 && cp <= 0x23FA)   // media / timer symbols
           || (cp == 0x24C2)                   // Ⓜ
           || (cp >= 0x2B00 && cp <= 0x2BFF)   // stars / arrows (⭐ …)
           ||
           (cp >= 0x20D0 && cp <= 0x20FF) // combining enclosing marks (keycaps)
           || (cp >= 0xFE00 && cp <= 0xFE0F) // variation selectors
           || (cp == 0x200D);                // zero-width joiner
}

// Reads the code point at `i`, advancing `units` over a surrogate pair.
constexpr char32_t codePointAt(QStringView s, int i, int& units)
{
    const QChar c = s[i];
    if (c.isHighSurrogate() && i + 1 < s.size() && s[i + 1].isLowSurrogate()) {
        units = 2;
        return QChar::surrogateToUcs4(c, s[i + 1]);
    }
    units = 1;
    return c.unicode();
}

// True when `text` contains at least one emoji code point (isEmojiCodePoint).
constexpr bool clusterHasEmoji(QStringView text)
{
    for (int i = 0; i < text.size();) {
        int units = 1;
        if (isEmojiCodePoint(codePointAt(text, i, units)))
            return true;
        i += units;
    }
    return false;
}

// True when `text` consists solely of emoji code points and whitespace (spaces, tabs and line
// breaks are allowed between/around the emojis), with at least one emoji present. Used by the
// static renderer to enlarge emoji-only messages. Empty or whitespace-only text returns false.
bool isOnlyEmoji(const QString& text);

// Walks `text` grapheme cluster by grapheme cluster (the correct Unicode segmentation), invoking
// `fn(cluster, start, end)` for each — `start`/`end` being indices into `text`. `fn` returns bool:
// false stops the walk early, true continues. The cluster is a QStringView into `text` (no per-cluster
// allocation); it is valid only for the duration of the call, so a callback that keeps it beyond that
// (stores it, hands it to insertText, …) must `.toString()` a copy.
template<typename Fn>
void forEachGraphemeCluster(QStringView text, Fn&& fn)
{
    QTextBoundaryFinder bf(QTextBoundaryFinder::Grapheme, text);
    int cs = 0;
    for (int ce = bf.toNextBoundary(); ce >= 0; ce = bf.toNextBoundary()) {
        if (ce > cs && !fn(text.sliced(cs, ce - cs), cs, ce))
            return;
        cs = ce;
    }
}

// Maps one emoji grapheme cluster to the bundled Twemoji svg url under `base` (a directory url ending
// in '/', file:// or qrc:), following twemoji.js' rule. The set of available svg basenames under a
// base is listed once and cached, and is the source of truth for what renders as an image.
QString twemojiSvgUrl(const QString& base, QStringView cluster);

} // namespace Markdown
