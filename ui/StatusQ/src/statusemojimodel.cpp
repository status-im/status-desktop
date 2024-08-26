#include "StatusQ/statusemojimodel.h"

#include <QDebug>
#include <QJsonObject>

#include <array>
#include <algorithm>

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

const auto skinColors = std::array<const char*, 5>{"1f3fb", "1f3fc", "1f3fd", "1f3fe", "1f3ff"};

constexpr auto MAX_EMOJI_NUMBER = 36;

constexpr auto kRecentCategoryName = "recent";
}

StatusEmojiModel::StatusEmojiModel(QObject *parent)
    : QAbstractListModel(parent)
{}

int StatusEmojiModel::rowCount(const QModelIndex &parent) const
{
    return m_recentEmojis.size() + m_emojiJson.size();
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
    emit emojiJsonChanged();
    endResetModel();
}

QString StatusEmojiModel::getEmojiUnicodeFromShortname(const QString &shortname) const
{
    const auto it = std::find_if(m_emojiJson.cbegin(),
                                 m_emojiJson.cend(),
                                 [shortname](const auto &emoji) {
                                     return emoji.isObject()
                                            && emoji.toObject().value(kShortname).toString()
                                                   == shortname;
                                 });
    if (it != m_emojiJson.cend())
        return it->toObject().value(kUnicode).toString();
    return {};
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

QStringList StatusEmojiModel::categories() const
{
    static const QStringList categories{kRecentCategoryName,
                                        QStringLiteral("smileys, people & body"),
                                        QStringLiteral("animals & nature"),
                                        QStringLiteral("food & drink"),
                                        QStringLiteral("travel & places"),
                                        QStringLiteral("activities"),
                                        QStringLiteral("objects"),
                                        QStringLiteral("symbols"),
                                        QStringLiteral("flags")};
    return categories;
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
    m_recentEmojis.removeDuplicates();
    if (m_recentEmojis.size() > MAX_EMOJI_NUMBER) {
        while (m_recentEmojis.size() > MAX_EMOJI_NUMBER)
            m_recentEmojis.removeLast();
    }
}

void StatusEmojiModel::addRecentEmojisToModel(const QStringList &emojiHexcodes)
{
    const auto emojiForHexcode = [&](const QString &hexcode) -> QJsonValue {
        const auto it = std::find_if(m_emojiJson.cbegin(),
                                     m_emojiJson.cend(),
                                     [hexcode](const auto &emoji) {
                                         return emoji.isObject()
                                                && emoji.toObject().value(kUnicode).toString()
                                                       == hexcode;
                                     });
        if (it != m_emojiJson.cend())
            return *it;
        return {QJsonValue::Null};
    };

    QJsonArray recentEmojiArr;
    for (const auto &hexcode : emojiHexcodes) {
        const auto emoji = emojiForHexcode(hexcode);
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
