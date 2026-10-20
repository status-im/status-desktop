#include "StatusQ/statusemojimodel.h"

#include <QDebug>
#include <QFile>
#include <QJsonObject>
#include <QJsonDocument>
#include <QSettings>

#include <array>
#include <algorithm>

using namespace Qt::Literals::StringLiterals;

namespace {
constexpr auto kAliases = "aliases";
constexpr auto kAliasesAscii = "aliases_ascii";
constexpr auto kCategory = "category";
constexpr auto kEmoji = "emoji";
constexpr auto kEmojiOrder = "emoji_order";
constexpr auto kKeywords = "keywords";
constexpr auto kName = "name";
constexpr auto kShortname = "shortname";
constexpr auto kUnicode = "unicode";
constexpr auto kHasSkins = "hasSkins";
constexpr auto kSkinColor = "skinColor";
constexpr auto kBaseColor = "base";

constexpr auto skinColors = std::array<const char*, 5>{"1f3fb", "1f3fc", "1f3fd", "1f3fe", "1f3ff"};

constexpr auto MAX_EMOJI_NUMBER = 36;

constexpr auto kRecentCategoryName = "recent"_L1;

constexpr auto kRecentEmojisSettingsEntry = "recentEmojis"_L1;

// The spelling-insensitive form of a hexcode: no variation selectors, no leading zeros.
// The catalogue follows emojibase, which writes "0031-fe0f-20e3"; ids persisted by older
// versions and ids seen on the wire use Twemoji's filename spelling, "31-20e3". Both must
// find the same entry. The generator guarantees these are unique across the catalogue.
QString canonicalForm(const QString &hexcode)
{
    QStringList parts;
    for (const auto &part : hexcode.toLower().split(u'-', Qt::SkipEmptyParts)) {
        if (part == "fe0f"_L1)
            continue;
        qsizetype digit = 0; // drop leading zeros, keeping at least one digit
        while (digit + 1 < part.size() && part.at(digit) == u'0')
            ++digit;
        parts.append(part.mid(digit));
    }
    return parts.join(u'-');
}
}

StatusEmojiModel::StatusEmojiModel(QObject *parent)
    : QAbstractListModel(parent)
{
    // lazy load the emoji_json from the QRC resource, not to block the CTOR
    QMetaObject::invokeMethod(this, [this]() { ensureLoaded(); }, Qt::QueuedConnection);
}

// Parses the catalogue if the queued load has not run yet. Queries must not depend on that
// timing: a lookup made before it (an emoticon typed right after the input appears, say) would
// otherwise silently answer "no such emoji".
void StatusEmojiModel::ensureLoaded() const
{
    if (!m_emojiJson.isEmpty())
        return;

    QFile f(":/StatusQ/Core/Utils/emojiList.json"_L1);
    if (!f.open(QFile::ReadOnly | QFile::Text)) {
        qWarning() << "Failed to open EmojiJSON DB from file:" << f.fileName();
        return;
    }
    const auto jsonDB = f.readAll();
    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(jsonDB, &err);
    if (err.error != QJsonParseError::NoError) {
        qWarning() << "Failed to parse EmojiJSON:" << err.error << err.errorString() << "; at offset:" << err.offset;
        return;
    }
    if (!doc.isArray()) {
        qWarning() << "Malformed EmojiJSON, not a JSON array: " << f.fileName();
        return;
    }
    auto* self = const_cast<StatusEmojiModel*>(this);
    self->setEmojiJson(doc.array());
    self->addRecentEmojisToModel(m_recentEmojis);
}

int StatusEmojiModel::rowCount(const QModelIndex &parent) const
{
    return m_recentEmojiJson.size() + m_emojiJson.size();
}

QVariant StatusEmojiModel::data(const QModelIndex &index, int role) const
{
    const auto row = index.row();
    if (row < 0 || row >= rowCount())
        return {};

    const auto &emoji = row < m_recentEmojiJson.size()
                            ? m_recentEmojiJson.at(row).toObject()
                            : m_emojiJson.at(row - m_recentEmojiJson.size()).toObject();
    const auto unicodeValue = emoji.value(kUnicode).toString();

    switch (static_cast<EmojiRoles>(role)) {
    case AliasesRole:
        return emoji.value(kAliases).toArray();
    case AliasesAsciiRole:
        return emoji.value(kAliasesAscii).toArray();
    case CategoryRole:
        return emoji.value(kCategory).toString();
    case EmojiRole:
        return emoji.value(kEmoji).toString();
    case EmojiOrderRole:
        return emoji.value(kEmojiOrder).toInt();
    case KeywordsRole:
        return emoji.value(kKeywords).toArray();
    case NameRole:
        return emoji.value(kName).toString();
    case ShortnameRole:
        return emoji.value(kShortname).toString();
    case UnicodeRole:
        return unicodeValue;
    case SkinColorRole:
        const auto colorIt = std::find_if(skinColors.cbegin(),
                                          skinColors.cend(),
                                          [unicodeValue](const auto &skinColor) {
                                              return unicodeValue.contains(skinColor);
                                          });
        if (colorIt != skinColors.cend())
            return *colorIt;

        if (emoji.value(kHasSkins).toBool(false))
            return kBaseColor;
        return QString();
    }

    return {};
}

QHash<int, QByteArray> StatusEmojiModel::roleNames() const
{
    static const QHash<int, QByteArray> roles{
        {AliasesRole, kAliases},
        {AliasesAsciiRole, kAliasesAscii},
        {CategoryRole, kCategory},
        {EmojiRole, kEmoji},
        {EmojiOrderRole, kEmojiOrder},
        {KeywordsRole, kKeywords},
        {NameRole, kName},
        {ShortnameRole, kShortname},
        {UnicodeRole, kUnicode},
        {SkinColorRole, kSkinColor},
    };

    return roles;
}

QJsonArray StatusEmojiModel::emojiJson() const
{
    return m_emojiJson;
}

void StatusEmojiModel::setEmojiJson(const QJsonArray &newEmojiJson)
{
    if (newEmojiJson == m_emojiJson)
        return;

    beginResetModel();
    m_emojiJson = newEmojiJson;
    rebuildLookupIndexes();
    emit emojiJsonChanged();
    endResetModel();
}

QString StatusEmojiModel::getEmojiUnicodeFromShortname(const QString &shortname) const
{
    ensureLoaded();
    const auto it = std::find_if(m_emojiJson.cbegin(),
                                 m_emojiJson.cend(),
                                 [&shortname](const auto &emoji) {
                                     return emoji.isObject()
                                            && emoji.toObject().value(kShortname).toString()
                                                   == shortname;
                                 });
    if (it != m_emojiJson.cend())
        return it->toObject().value(kUnicode).toString();
    return {};
}

QString StatusEmojiModel::getEmojiFromAsciiAlias(const QString &alias) const
{
    ensureLoaded();
    return m_asciiAliasToEmoji.value(alias);
}

QString StatusEmojiModel::getEmojiFromHexcode(const QString &hexcode) const
{
    ensureLoaded();
    const auto entry = entryForHexcode(hexcode);
    return entry.isObject() ? entry.toObject().value(kEmoji).toString() : QString();
}

QString StatusEmojiModel::canonicalUnicode(const QString &hexcode) const
{
    ensureLoaded();
    const auto entry = entryForHexcode(hexcode);
    return entry.isObject() ? entry.toObject().value(kUnicode).toString() : QString();
}

QJsonValue StatusEmojiModel::entryForHexcode(const QString &hexcode) const
{
    auto it = m_hexcodeToIndex.constFind(hexcode);
    if (it == m_hexcodeToIndex.cend()) {
        const auto known = m_canonicalToHexcode.value(canonicalForm(hexcode));
        if (known.isEmpty())
            return {QJsonValue::Null};
        it = m_hexcodeToIndex.constFind(known);
        if (it == m_hexcodeToIndex.cend())
            return {QJsonValue::Null};
    }
    return m_emojiJson.at(*it);
}

QJsonArray StatusEmojiModel::getSuggestions(const QString &name) const
{
    ensureLoaded();
    const auto anyContains = [&name](const QJsonArray &values) {
        return std::any_of(values.cbegin(), values.cend(), [&name](const auto &value) {
            return value.toString().contains(name);
        });
    };

    QJsonArray result;
    for (const auto &emojiValue : std::as_const(m_emojiJson)) {
        if (!emojiValue.isObject())
            continue;

        const auto emoji = emojiValue.toObject();
        if (emoji.value(kName).toString().contains(name)
            || emoji.value(kShortname).toString().contains(name)
            || anyContains(emoji.value(kAliases).toArray())
            || anyContains(emoji.value(kKeywords).toArray()))
            result.append(emoji);
    }
    return result;
}

int StatusEmojiModel::maxAsciiEmojiAliasLength() const
{
    ensureLoaded();
    return m_maxAsciiEmojiAliasLength;
}

void StatusEmojiModel::rebuildLookupIndexes()
{
    m_asciiAliasToEmoji.clear();
    m_hexcodeToIndex.clear();
    m_canonicalToHexcode.clear();
    m_maxAsciiEmojiAliasLength = 0;
    for (int i = 0; i < m_emojiJson.size(); ++i) {
        const auto emojiValue = m_emojiJson.at(i);
        if (!emojiValue.isObject())
            continue;

        const auto emoji = emojiValue.toObject();
        const auto emojiStr = emoji.value(kEmoji).toString();
        const auto hexcode = emoji.value(kUnicode).toString();
        m_hexcodeToIndex.insert(hexcode, i);
        m_canonicalToHexcode.insert(canonicalForm(hexcode), hexcode);

        const auto aliases = emoji.value(kAliasesAscii).toArray();
        if (aliases.isEmpty())
            continue;
        for (const auto &aliasValue : aliases) {
            const auto alias = aliasValue.toString();
            // first occurrence wins, same as the former linear search
            if (!m_asciiAliasToEmoji.contains(alias))
                m_asciiAliasToEmoji.insert(alias, emojiStr);
            m_maxAsciiEmojiAliasLength = qMax(m_maxAsciiEmojiAliasLength, alias.size());
        }
    }
}

int StatusEmojiModel::getCategoryOffset(int categoryIndex) const {
    if (categoryIndex <= 0 || categoryIndex >= categories().size())
        return 0;

    const auto categoryName = categories().at(categoryIndex);
    const auto catIt = std::find_if(m_emojiJson.cbegin(),
                                    m_emojiJson.cend(),
                                    [categoryName](const auto &emoji) {
                                        return emoji.isObject()
                                        && emoji.toObject().value(kCategory).toString()
                                            == categoryName;
                                    });
    if (catIt != m_emojiJson.cend())
        return std::distance(m_emojiJson.cbegin(), catIt) + m_recentEmojiJson.size();
    return 0;
}

QVariantList StatusEmojiModel::sections(const QString &filter, const QString &skinColor) const
{
    ensureLoaded();

    // The catalogue carries every tone of an emoji as its own entry and the grid shows one
    // of them: the requested tone where there is one, and otherwise the toneless entry.
    // Mirrors what the skinColor role plus the picker's filters resolve to today.
    const auto toneOf = [](const QString &unicode) {
        const auto it = std::find_if(skinColors.cbegin(), skinColors.cend(),
                                     [&unicode](const auto *tone) {
                                         return unicode.contains(QLatin1String(tone));
                                     });
        return it == skinColors.cend() ? QString() : QString::fromLatin1(*it);
    };
    const auto wantedTone = skinColor == QLatin1String(kBaseColor) ? QString() : skinColor;

    QVariantList sections;
    QString name;
    QString text;
    QList<int> rows;

    const auto flush = [&sections, &name, &text, &rows] {
        if (rows.isEmpty())
            return;
        sections.append(QVariantMap{{"name"_L1, name},
                                    {"text"_L1, text},
                                    {"count"_L1, static_cast<int>(rows.size())},
                                    {"rows"_L1, QVariant::fromValue(rows)}});
        text.clear();
        rows.clear();
    };

    const auto recentCount = static_cast<int>(m_recentEmojiJson.size());
    // while searching there are no recents, the same as in the picker today
    const auto firstRow = filter.isEmpty() ? 0 : recentCount;

    for (auto row = firstRow; row < rowCount(); ++row) {
        const auto emoji = row < recentCount
                               ? m_recentEmojiJson.at(row).toObject()
                               : m_emojiJson.at(row - recentCount).toObject();

        const auto tone = toneOf(emoji.value(kUnicode).toString());
        const auto wanted = wantedTone.isEmpty()
                                ? tone.isEmpty()
                                : (tone == wantedTone
                                   || (tone.isEmpty() && !emoji.value(kHasSkins).toBool(false)));
        if (!wanted)
            continue;

        if (!filter.isEmpty()
            && !emoji.value(kName).toString().contains(filter, Qt::CaseInsensitive)
            && !emoji.value(kShortname).toString().contains(filter, Qt::CaseInsensitive))
            continue;

        const auto category = emoji.value(kCategory).toString();
        if (category != name) {
            flush();
            name = category;
        }

        text += emoji.value(kEmoji).toString();
        rows.append(row);
    }
    flush();

    return sections;
}

QStringList StatusEmojiModel::categories() const
{
    static const QStringList categories{kRecentCategoryName,
        "smileys, people & body"_L1,
        "animals & nature"_L1,
        "food & drink"_L1,
        "travel & places"_L1,
        "activities"_L1,
        "objects"_L1,
        "symbols"_L1,
        "flags"_L1
    };
    return categories;
}

QStringList StatusEmojiModel::categoryIcons() const
{
    static const QStringList categoryIcons{
        "time"_L1,
        "smileys-and-people"_L1,
        "animals-and-nature"_L1,
        "food-and-drinks"_L1,
        "activity"_L1,
        "travel-and-places"_L1,
        "objects"_L1,
        "symbols"_L1,
        "flags"_L1
    };
    return categoryIcons;
}

QStringList StatusEmojiModel::recentEmojis() const
{
    return m_recentEmojis;
}

void StatusEmojiModel::setRecentEmojis(const QStringList &newRecentEmojis)
{
    if (m_recentEmojis == newRecentEmojis)
        return;
    m_recentEmojis = newRecentEmojis;
    cleanAndResizeRecentEmojis();
    addRecentEmojisToModel(m_recentEmojis);
    emit recentEmojisChanged();
}

void StatusEmojiModel::addRecentEmoji(const QString &hexcode)
{
    m_recentEmojis.prepend(hexcode);
    cleanAndResizeRecentEmojis();
    addRecentEmojisToModel(m_recentEmojis);
    emit recentEmojisChanged();
}

void StatusEmojiModel::cleanAndResizeRecentEmojis()
{
    if (m_recentEmojis.isEmpty())
        return;
    // Rewrite ids an older version stored under a different spelling, so the list
    // self-heals and the two spellings cannot both sit in it.
    for (auto &hexcode : m_recentEmojis) {
        const auto entry = entryForHexcode(hexcode);
        if (entry.isObject())
            hexcode = entry.toObject().value(kUnicode).toString();
    }
    m_recentEmojis.removeDuplicates();
    if (m_recentEmojis.size() > MAX_EMOJI_NUMBER) {
        while (m_recentEmojis.size() > MAX_EMOJI_NUMBER)
            m_recentEmojis.removeLast();
    }
}

void StatusEmojiModel::addRecentEmojisToModel(const QStringList &emojiHexcodes)
{
    QJsonArray recentEmojiArr;
    for (const auto &hexcode : emojiHexcodes) {
        const auto emoji = entryForHexcode(hexcode);
        if (!emoji.isNull() && emoji.isObject()) {
            auto emojiObj = emoji.toObject();
            emojiObj[kCategory] = kRecentCategoryName;
            emojiObj[kEmojiOrder] = 0; // sort by insertion order, before any regular ones
            recentEmojiArr.append(emojiObj);
        }
    }

    beginResetModel();
    m_recentEmojiJson = recentEmojiArr;
    endResetModel();
}

QString StatusEmojiModel::recentCategoryName() const
{
    return kRecentCategoryName;
}

QString StatusEmojiModel::baseSkinColorName() const
{
    return kBaseColor;
}

QString StatusEmojiModel::userUID() const
{
    return m_userUID;
}

void StatusEmojiModel::setUserUID(const QString &newUserUID)
{
    if (m_userUID == newUserUID)
        return;
    m_userUID = newUserUID;
    emit userUIDChanged();

    loadRecentEmojis();
    connect(this, &StatusEmojiModel::recentEmojisChanged, this, &StatusEmojiModel::saveRecentEmojis);
}

QString StatusEmojiModel::settingsGroup() const
{
    return QStringLiteral("AppMainLocalSettings_%1").arg(m_userUID);
}

void StatusEmojiModel::saveRecentEmojis()
{
    QSettings settings;
    settings.beginGroup(settingsGroup());
    settings.setValue(kRecentEmojisSettingsEntry, m_recentEmojis);
    settings.endGroup();
}

void StatusEmojiModel::loadRecentEmojis()
{
    QSettings settings;
    settings.beginGroup(settingsGroup());
    setRecentEmojis(settings.value(kRecentEmojisSettingsEntry).toStringList());
    settings.endGroup();
}
