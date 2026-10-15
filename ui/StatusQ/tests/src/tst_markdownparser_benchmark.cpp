#include <QTest>

#include <StatusQ/markdownast.h>
#include <StatusQ/markdownhtml.h>
#include <StatusQ/markdownparser.h>

using namespace Markdown;

// Benchmarks for parsing and AST rendering — a reference point for future optimisations.
// Run with: make run-statusq-tests ARGS="-R MarkdownParserBenchmark"
// For stable timings: MarkdownParserBenchmark parse render -iterations 100 -median 7
// For heap profiling without calibration or two live ASTs:
//   heaptrack MarkdownParserBenchmark parseOnce:mixed-64k
class BenchMarkdownParser : public QObject
{
    Q_OBJECT

    enum Kind { Prose, Emphasis, Code, Quotes, Links, Mixed, Plain, ExplicitLinks, WalletLinks, Mentions, Emoji,
                DenseEmphasis, EmphasisTail, UnmatchedBackticks };

    // Representative unit block for each content kind (kept small; repeated to reach the
    // target size). Each exercises a distinct parser stage.
    static QString unitFor(Kind kind)
    {
        switch (kind) {
        case Prose:
            return QStringLiteral(
                "Hey team, quick update on the **release**: the *login* flow is fixed and the\n"
                "new `retry` logic landed. See the notes at https://status.im/notes for the\n"
                "details, and ping me if anything looks off. Thanks everyone for the help!\n\n");
        case Emphasis:
            return QStringLiteral(
                "**bold** and *italic* and ~~strike~~ and `code` plus ***both*** and __x__ y\n"
                "*a* **b** ~~c~~ `d` *e* **f** ~~g~~ `h` *i* **j** ~~k~~ `l` *m* **n** ~~o~~\n\n");
        case Code:
            return QStringLiteral(
                "Here is a snippet:\n"
                "```\n"
                "int main() {\n"
                "    for (int i = 0; i < 10; ++i)\n"
                "        sum += i * (i - 1);\n"
                "    return sum;\n"
                "}\n"
                "```\n\n");
        case Quotes:
            return QStringLiteral(
                "> quoted line one with some **bold** content here\n"
                "> quoted line two with a `code` span and more words\n"
                "> quoted line three, still going, plenty of text to scan\n\n");
        case Links:
            return QStringLiteral(
                "See https://status.im and http://example.org/path?q=1 and also\n"
                "https://github.com/status-im/status-desktop/issues/1234 plus a bare\n"
                "https://a.b.c/d/e/f/g link at the end of the line here now.\n\n");
        case Plain:
            return QStringLiteral("An ordinary message without formatting or links.\n\n");
        case ExplicitLinks:
            return QStringLiteral("[Status](https://status.im) [ENS](https://alice.eth/path)\n\n");
        case WalletLinks:
            return QStringLiteral("alice.eth 0x1234567890abcdef1234567890abcdef12345678\n\n");
        case Mentions:
            return QStringLiteral("Hello @0x00001 and @0x") + QString(130, QLatin1Char('a'))
                 + QStringLiteral("!\n\n");
        case Emoji:
            return QStringLiteral("\U0001F600\U0001F469\u200D\U0001F4BB\n");
        case DenseEmphasis:
            return QStringLiteral("*a* **b** ~~c~~ ***d*** ");
        case UnmatchedBackticks:
        case EmphasisTail:
            return {};
        case Mixed:
        default:
            return unitFor(Prose) + unitFor(Emphasis) + unitFor(Code)
                 + unitFor(Quotes) + unitFor(Links);
        }
    }

    static QString makeInput(Kind kind, int sizeChars)
    {
        if (kind == EmphasisTail) {
            // Opening-only '*' delimiters remain before sibling strikethrough pairs,
            // forcing vector erases to move data rather than just advancing its head.
            QString out = QStringLiteral("!*a ").repeated(sizeChars / 8);
            out.reserve(sizeChars + 8);
            while (out.size() < sizeChars)
                out += QStringLiteral("~~b~~ ");
            out.truncate(sizeChars);
            return out;
        }
        if (kind == UnmatchedBackticks) {
            QString out;
            out.reserve(sizeChars);
            // Increasing run lengths expose suffix rescans when no closer exists.
            for (int length = 1; out.size() < sizeChars; ++length)
                out += QString(length, QLatin1Char('`')) + QLatin1Char(' ');
            out.truncate(sizeChars);
            return out;
        }
        const QString unit = unitFor(kind);
        QString out;
        out.reserve(sizeChars + unit.size());
        while (out.size() < sizeChars)
            out += unit;
        out.truncate(sizeChars);
        return out;
    }

private slots:
    void parse_data()
    {
        QTest::addColumn<int>("kind");
        QTest::addColumn<int>("sizeChars");
        QTest::addColumn<bool>("detectLinks");

        const int kB = 1024;

        // Sizes count UTF-16 code units, not bytes of QString storage. These fixtures are
        // ASCII, so the row names also describe the UTF-8 input size.

        // Per-kind at a fixed size — compares the cost of each parser stage.
        QTest::newRow("prose-32k")    << int(Prose)    << 32 * kB << true;
        QTest::newRow("emphasis-32k") << int(Emphasis) << 32 * kB << true;
        QTest::newRow("code-32k")     << int(Code)     << 32 * kB << true;
        QTest::newRow("quotes-32k")   << int(Quotes)   << 32 * kB << true;
        QTest::newRow("links-32k")    << int(Links)    << 32 * kB << true;
        QTest::newRow("mixed-32k")    << int(Mixed)    << 32 * kB << true;
        QTest::newRow("plain-32k")    << int(Plain)    << 32 * kB << true;
        QTest::newRow("explicit-32k") << int(ExplicitLinks) << 32 * kB << true;
        QTest::newRow("wallet-32k")   << int(WalletLinks)   << 32 * kB << true;
        QTest::newRow("mentions-32k") << int(Mentions) << 32 * kB << true;

        // Isolate link-detection cost.
        QTest::newRow("mixed-32k-nolinks") << int(Mixed) << 32 * kB << false;

        // Scaling series and scanner-heavy inputs expose super-linear growth.
        QTest::newRow("mixed-8k")  << int(Mixed) <<  8 * kB << true;
        QTest::newRow("mixed-1k")  << int(Mixed) << kB << true;
        QTest::newRow("mixed-64k") << int(Mixed) << 64 * kB << true;
        QTest::newRow("mixed-256k") << int(Mixed) << 256 * kB << true;
        QTest::newRow("emphasis-128k") << int(Emphasis) << 128 * kB << true;
        QTest::newRow("explicit-128k") << int(ExplicitLinks) << 128 * kB << true;
        QTest::newRow("emphasis-512k") << int(Emphasis) << 512 * kB << true;
        QTest::newRow("dense-emphasis-32k") << int(DenseEmphasis) << 32 * kB << false;
        QTest::newRow("dense-emphasis-128k") << int(DenseEmphasis) << 128 * kB << false;
        QTest::newRow("emphasis-tail-32k") << int(EmphasisTail) << 32 * kB << false;
        QTest::newRow("emphasis-tail-128k") << int(EmphasisTail) << 128 * kB << false;
        QTest::newRow("backticks-8k") << int(UnmatchedBackticks) << 8 * kB << false;
        QTest::newRow("backticks-32k") << int(UnmatchedBackticks) << 32 * kB << false;
        QTest::newRow("backticks-128k") << int(UnmatchedBackticks) << 128 * kB << false;
    }

    void parse()
    {
        QFETCH(int, kind);
        QFETCH(int, sizeChars);
        QFETCH(bool, detectLinks);

        // Built outside the timed block so only parsing is measured.
        const QString input = makeInput(Kind(kind), sizeChars);

        Options opts;
        opts.detectLinks = detectLinks;

        Node doc;
        QBENCHMARK {
            doc = Markdown::parse(input, opts);
        }
        QVERIFY(doc.kind == NodeKind::Document); // guard against dead-code elision
        QCOMPARE(doc.end, qsizetype(sizeChars));
    }

    void parseOnce_data()
    {
        parse_data();
    }

    void parseOnce()
    {
        QFETCH(int, kind);
        QFETCH(int, sizeChars);
        QFETCH(bool, detectLinks);

        Options opts;
        opts.detectLinks = detectLinks;
        const Node doc = Markdown::parse(makeInput(Kind(kind), sizeChars), opts);
        QCOMPARE(doc.kind, NodeKind::Document);
        QCOMPARE(doc.end, qsizetype(sizeChars));
    }

    void render_data()
    {
        QTest::addColumn<int>("kind");
        QTest::newRow("mixed-32k") << int(Mixed);
        QTest::newRow("plain-32k") << int(Plain);
        QTest::newRow("emoji-32k") << int(Emoji);
    }

    void render()
    {
        QFETCH(int, kind);
        const Node doc = Markdown::parse(makeInput(Kind(kind), 32 * 1024));
        QVariantList blocks;
        QBENCHMARK {
            blocks = Markdown::toBlocks(doc, {}, 20);
        }
        QVERIFY(!blocks.isEmpty());
    }

    void renderOnce_data()
    {
        render_data();
    }

    void renderOnce()
    {
        QFETCH(int, kind);
        const Node doc = Markdown::parse(makeInput(Kind(kind), 32 * 1024));
        const QVariantList blocks = Markdown::toBlocks(doc, {}, 20);
        QVERIFY(!blocks.isEmpty());
    }
};

QTEST_GUILESS_MAIN(BenchMarkdownParser)
#include "tst_markdownparser_benchmark.moc"
