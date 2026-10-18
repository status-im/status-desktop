#include <QJsonArray>
#include <QJsonObject>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>
#include <QSignalSpy>
#include <QTest>

#include <StatusQ/statusemojimodel.h>

using namespace Qt::Literals::StringLiterals;

class tst_StatusEmojiModel : public QObject
{
    Q_OBJECT

    StatusEmojiModel *m_model = nullptr;
    QQmlEngine *m_engine = nullptr;
    QObject *m_benchObj = nullptr;

    static QStringList unicodes(const QJsonArray &emojis)
    {
        QStringList result;
        for (const auto &emoji : emojis)
            result.append(emoji.toObject().value("unicode").toString());
        return result;
    }

private slots:
    void initTestCase()
    {
        m_model = new StatusEmojiModel(this);
        // the emoji JSON DB is loaded lazily (queued) from the QRC
        QSignalSpy spy(m_model, &StatusEmojiModel::emojiJsonChanged);
        QVERIFY(spy.wait());
        QVERIFY(m_model->property("emojiJson").toJsonArray().size() > 0);

        // Benchmark harness: the original JS implementation vs. the C++ one, both called
        // from QML so that the QML <-> C++ conversion costs are accounted for
        m_engine = new QQmlEngine(this);
        m_engine->rootContext()->setContextProperty("emojiModel", m_model);
        QQmlComponent component(m_engine);
        component.setData(R"(
            import QtQml
            QtObject {
                readonly property var emojiJSON: emojiModel.emojiJson
                function jsImpl(input) {
                    return emojiJSON.filter(emoji => emoji.name.includes(input) ||
                        emoji.shortname.includes(input) ||
                        emoji.aliases.some(a => a.includes(input)) ||
                        emoji.keywords.some(k => k.includes(input)))
                }
                function cppImpl(input) { return emojiModel.getSuggestions(input) }
                function count(useCpp: bool, input: string): int {
                    return (useCpp ? cppImpl(input) : jsImpl(input)).length
                }
            }
        )", {});
        m_benchObj = component.create();
        QVERIFY2(m_benchObj, qPrintable(component.errorString()));
    }

    void cleanupTestCase()
    {
        delete m_benchObj;
    }

    void getSuggestions_matchesKeyword()
    {
        const auto result = m_model->getSuggestions("grin");
        QCOMPARE(result.size(), 9);
        QCOMPARE(unicodes(result).mid(0, 4),
                 QStringList({"1f600", "1f603", "1f604", "1f601"}));
    }

    void getSuggestions_matchesShortnameIncludingSkins()
    {
        const auto result = m_model->getSuggestions("thumbsup");
        QCOMPARE(result.size(), 6);
        const auto uc = unicodes(result);
        QCOMPARE(uc.constFirst(), "1f44d");
        QVERIFY(uc.contains("1f44d-1f3fb"));
    }

    void getSuggestions_matchesAlias()
    {
        const auto result = m_model->getSuggestions(":grinning_face:");
        QCOMPARE(result.size(), 1);
        const auto emoji = result.first().toObject();
        QCOMPARE(emoji.value("unicode").toString(), "1f600");
        QCOMPARE(emoji.value("name").toString(), "grinning face");
        QCOMPARE(emoji.value("shortname").toString(), ":grinning:");
    }

    void getSuggestions_isCaseSensitive()
    {
        QVERIFY(m_model->getSuggestions("GRIN").isEmpty());
    }

    void getSuggestions_noMatch()
    {
        QVERIFY(m_model->getSuggestions("zzzxq").isEmpty());
    }

    void getSuggestions_emptyInputMatchesAll()
    {
        QCOMPARE(m_model->getSuggestions({}).size(),
                 m_model->property("emojiJson").toJsonArray().size());
    }

    void getSuggestions_excludesRecentDuplicates()
    {
        m_model->addRecentEmoji("1f600");
        QCOMPARE(m_model->getSuggestions(":grinning_face:").size(), 1);
    }

    void asciiAliases()
    {
        QCOMPARE(m_model->maxAsciiEmojiAliasLength(), 3);
        QCOMPARE(m_model->getEmojiFromAsciiAlias(":)"), QString::fromUtf8("\U0001F642"));
        QCOMPARE(m_model->getEmojiFromAsciiAlias(">:)"), QString::fromUtf8("\U0001F608"));
        QVERIFY(m_model->getEmojiFromAsciiAlias("not-an-emoticon").isEmpty());
        QVERIFY(m_model->getEmojiFromAsciiAlias({}).isEmpty());
    }

    // The hexcode follows Twemoji's filename convention, which drops U+FE0F, so it must
    // not be turned back into a character by hand: the catalogue holds the fully-qualified
    // form, and without the selector these render in a text font rather than as emoji.
    void hexcodeLookupReturnsTheFullyQualifiedCharacter()
    {
        QCOMPARE(m_model->getEmojiFromHexcode("2764"), QString::fromUtf8("\u2764\uFE0F"));
        QCOMPARE(m_model->getEmojiFromHexcode("1f590"), QString::fromUtf8("\U0001F590\uFE0F"));
        // one that needs no selector, to show the lookup is not just appending one
        QCOMPARE(m_model->getEmojiFromHexcode("1f602"), QString::fromUtf8("\U0001F602"));
        // skin tone variants are keyed by their own hexcode
        QCOMPARE(m_model->getEmojiFromHexcode("1f590-1f3fb"),
                 QString::fromUtf8("\U0001F590\U0001F3FB"));
        QVERIFY(m_model->getEmojiFromHexcode("not-a-hexcode").isEmpty());
        QVERIFY(m_model->getEmojiFromHexcode({}).isEmpty());
    }

    // The catalogue follows emojibase, which spells a keycap "0031-fe0f-20e3"; the ids
    // this app persisted before (recents) and the ones peers send for reactions use
    // Twemoji's filename spelling, "31-20e3". Both have to find the same entry, or an old
    // reaction renders through the unqualified-codepoint fallback.
    void hexcodeLookupAcceptsEverySpelling_data()
    {
        QTest::addColumn<QString>("one");
        QTest::addColumn<QString>("other");

        QTest::newRow("keycap") << "31-20e3" << "0031-fe0f-20e3";
        QTest::newRow("keycap hash") << "23-20e3" << "0023-fe0f-20e3";
        QTest::newRow("copyright") << "a9" << "00a9";
        QTest::newRow("registered") << "ae" << "00ae";
        QTest::newRow("eye in speech bubble")
            << "1f441-200d-1f5e8" << "1f441-fe0f-200d-1f5e8-fe0f";
        QTest::newRow("upper case") << "1f602" << "1F602";
        QTest::newRow("selector on a plain id") << "1f602" << "1f602-fe0f";
    }

    void hexcodeLookupAcceptsEverySpelling()
    {
        QFETCH(QString, one);
        QFETCH(QString, other);

        const auto id = m_model->canonicalUnicode(one);
        QVERIFY2(!id.isEmpty(), qPrintable(one));
        QCOMPARE(m_model->canonicalUnicode(other), id);
        QVERIFY(!m_model->getEmojiFromHexcode(one).isEmpty());
        QCOMPARE(m_model->getEmojiFromHexcode(other), m_model->getEmojiFromHexcode(one));
    }

    // An entry with no shortname draws a blank row in the suggestion list, and two
    // entries sharing one cannot be told apart there. joypixels names neither the
    // Emoji 15.1 additions nor the skin variants, so the generator fills both in.
    void everyEntryHasAUniqueShortname()
    {
        const auto catalogue = m_model->property("emojiJson").toJsonArray();
        QStringList unnamed, duplicates;
        QSet<QString> seen;
        for (const auto &value : catalogue) {
            const auto entry = value.toObject();
            const auto shortname = entry.value("shortname").toString();
            if (shortname.isEmpty())
                unnamed.append(entry.value("name").toString());
            else if (seen.contains(shortname))
                duplicates.append(shortname);
            else
                seen.insert(shortname);
        }
        QVERIFY2(unnamed.isEmpty(), qPrintable(unnamed.mid(0, 5).join(u", "_s)));
        QVERIFY2(duplicates.isEmpty(), qPrintable(duplicates.mid(0, 5).join(u", "_s)));
    }

    void shortnamesDerivedFromLabelsAreTypeable()
    {
        QCOMPARE(m_model->getEmojiUnicodeFromShortname(":head_shaking_horizontally:"),
                 "1f642-200d-2194-fe0f"_L1);
        // the tone has to come from the `tone` field: emojibase gives these skins the
        // bare base label, so slugging alone would collide
        QCOMPARE(m_model->getEmojiUnicodeFromShortname(":person_walking_facing_right_tone1:"),
                 "1f6b6-1f3fb-200d-27a1-fe0f"_L1);
    }

    void canonicalUnicodeReportsUnknownIds()
    {
        QVERIFY(m_model->canonicalUnicode("not-a-hexcode").isEmpty());
        QVERIFY(m_model->canonicalUnicode("ffffff").isEmpty());
        QVERIFY(m_model->canonicalUnicode({}).isEmpty());
    }

    // Recents are persisted as ids, so a list written by an older version must still
    // show up - once, under the id the catalogue uses now.
    void recentEmojisStoredUnderAnOldIdAreHealed()
    {
        StatusEmojiModel model;
        QSignalSpy loaded(&model, &StatusEmojiModel::emojiJsonChanged);
        QVERIFY(loaded.wait());

        const auto keycap = model.canonicalUnicode("31-20e3");
        QVERIFY(!keycap.isEmpty());

        model.setProperty("recentEmojis", QStringList{"31-20e3", "0031-fe0f-20e3", "2764"});

        QCOMPARE(model.property("recentEmojis").toStringList(),
                 (QStringList{keycap, "2764"}));
        QCOMPARE(model.data(model.index(0, 0), StatusEmojiModel::UnicodeRole).toString(),
                 keycap);
        QCOMPARE(model.data(model.index(0, 0), StatusEmojiModel::CategoryRole).toString(),
                 "recent"_L1);
    }

    void benchmarkAsciiAliasLookup()
    {
        // mimics ChatTextArea's per-keystroke lookup of the text before the caret
        const QStringList chunks{">:)", ":)", ")", "abc", "bc", "c"};
        int found = 0;
        QBENCHMARK {
            found = m_model->maxAsciiEmojiAliasLength() > 0 ? 0 : -1;
            for (const auto &chunk : chunks)
                found += m_model->getEmojiFromAsciiAlias(chunk).isEmpty() ? 0 : 1;
        }
        QCOMPARE(found, 2);
    }

    void benchmarkGetSuggestions_data()
    {
        QTest::addColumn<bool>("useCpp");
        QTest::addColumn<QString>("input");

        for (const auto &input : {"gr", "grin", "thumbsup", "zzzxq", "fa"}) {
            QTest::addRow("js/%s", input) << false << QString::fromLatin1(input);
            QTest::addRow("cpp/%s", input) << true << QString::fromLatin1(input);
        }
    }

    void benchmarkGetSuggestions()
    {
        QFETCH(bool, useCpp);
        QFETCH(QString, input);

        int jsCount = -1, cppCount = -1;
        QMetaObject::invokeMethod(m_benchObj, "count", Q_RETURN_ARG(int, jsCount),
                                  Q_ARG(bool, false), Q_ARG(QString, input));
        QMetaObject::invokeMethod(m_benchObj, "count", Q_RETURN_ARG(int, cppCount),
                                  Q_ARG(bool, true), Q_ARG(QString, input));
        QCOMPARE(cppCount, jsCount);

        int count = 0;
        QBENCHMARK {
            QMetaObject::invokeMethod(m_benchObj, "count", Q_RETURN_ARG(int, count),
                                      Q_ARG(bool, useCpp), Q_ARG(QString, input));
        }
        QCOMPARE(count, jsCount);
    }
};

QTEST_GUILESS_MAIN(tst_StatusEmojiModel)
#include "tst_statusemojimodel.moc"
