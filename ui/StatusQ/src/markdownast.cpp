#include "StatusQ/markdownast.h"

#include <QHash>

using namespace Qt::Literals::StringLiterals;

namespace {

constexpr QLatin1String kindName(Markdown::NodeKind kind)
{
    using K = Markdown::NodeKind;
    switch (kind) {
    case K::Document:      return "Document"_L1;
    case K::Paragraph:     return "Paragraph"_L1;
    case K::QuoteBlock:    return "QuoteBlock"_L1;
    case K::CodeBlock:     return "CodeBlock"_L1;
    case K::Strong:        return "Strong"_L1;
    case K::Emphasis:      return "Emphasis"_L1;
    case K::Strikethrough: return "Strikethrough"_L1;
    case K::CodeSpan:      return "CodeSpan"_L1;
    case K::Link:          return "Link"_L1;
    case K::WalletLink:    return "WalletLink"_L1;
    case K::Text:          return "Text"_L1;
    case K::Delimiter:     return "Delimiter"_L1;
    case K::Mention:       return "Mention"_L1;
    }
    return "Unknown"_L1;
}

// Escapes a literal so a node fits on a single, readable line.
QString escapeLiteral(const QString& s)
{
    QString out;
    out.reserve(s.size() + 2);
    for (const QChar c : s) {
        if (c == QLatin1Char('\\'))      out += QStringLiteral("\\\\");
        else if (c == QLatin1Char('\n')) out += QStringLiteral("\\n");
        else if (c == QLatin1Char('\t')) out += QStringLiteral("\\t");
        else if (c == QLatin1Char('"'))  out += QStringLiteral("\\\"");
        else                             out += c;
    }
    return out;
}

void dumpNode(const Markdown::Node& node, int depth, bool withRanges, QString& out)
{
    using K = Markdown::NodeKind;

    out += QString(depth * 2, QLatin1Char(' '));
    out += kindName(node.kind);

    if (withRanges)
        out += QStringLiteral(" [%1,%2)").arg(node.start).arg(node.end);

    if (node.kind == K::Text || node.kind == K::Delimiter)
        out += QStringLiteral(" \"%1\"").arg(escapeLiteral(node.literal));
    else if (node.kind == K::Link || node.kind == K::WalletLink)
        out += QStringLiteral(" \"%1\"").arg(escapeLiteral(node.destination));
    // Textual mentions carry the pub key; U+FFFC pill mentions have none (metadata lives in
    // the document char format), so only annotate when present.
    else if (node.kind == K::Mention && !node.destination.isEmpty())
        out += QStringLiteral(" \"%1\"").arg(escapeLiteral(node.destination));

    out += QLatin1Char('\n');

    for (const auto& child : node.children)
        dumpNode(child, depth + 1, withRanges, out);
}

// Local path the base url (a directory ending in '/') resolves to, covering the two StatusQ
} // namespace

namespace Markdown {

QString dump(const Node& node, bool withRanges)
{
    QString out;
    dumpNode(node, 0, withRanges, out);
    if (out.endsWith(QLatin1Char('\n')))
        out.chop(1);
    return out;
}

bool isOnlyEmoji(const QString& text)
{
    // Classify per grapheme cluster (not per code point): a keycap (0-9 # *) or subdivision flag
    // has non-emoji code points inside an otherwise-emoji cluster, so a per-code-point test would
    // wrongly reject them. Whitespace between/around emojis is allowed.
    bool hasEmoji = false;
    bool onlyEmoji = true;
    forEachGraphemeCluster(text, [&](QStringView cluster, int, int) {
        if (cluster.trimmed().isEmpty())
            return true; // whitespace between/around emojis is allowed
        if (!clusterHasEmoji(cluster)) {
            onlyEmoji = false;
            return false; // a non-emoji cluster settles it — stop early
        }
        hasEmoji = true;
        return true;
    });
    return onlyEmoji && hasEmoji;
}

} // namespace Markdown
