#pragma once

#include <QAbstractListModel>
#include <QHash>
#include <QJsonArray>
#include <QJsonValue>
#include <QVariant>

class StatusEmojiModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QString userUID READ userUID WRITE setUserUID NOTIFY userUIDChanged FINAL)
    Q_PROPERTY(QJsonArray emojiJson READ emojiJson NOTIFY emojiJsonChanged FINAL)
    Q_PROPERTY(QStringList categories READ categories CONSTANT FINAL)
    Q_PROPERTY(QStringList categoryIcons READ categoryIcons CONSTANT FINAL)
    Q_PROPERTY(QStringList recentEmojis READ recentEmojis WRITE setRecentEmojis NOTIFY
                   recentEmojisChanged FINAL)
    Q_PROPERTY(QString recentCategoryName READ recentCategoryName CONSTANT FINAL)
    Q_PROPERTY(QString baseSkinColorName READ baseSkinColorName CONSTANT FINAL)

public:
    enum EmojiRoles {
        AliasesRole = Qt::UserRole + 1,
        AliasesAsciiRole,
        CategoryRole,
        EmojiRole,
        EmojiOrderRole,
        KeywordsRole,
        NameRole,
        ShortnameRole,
        UnicodeRole,
        SkinColorRole,
    };
    Q_ENUM(EmojiRoles)

    explicit StatusEmojiModel(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE QString getEmojiUnicodeFromShortname(const QString &shortname) const;
    Q_INVOKABLE QString getEmojiFromAsciiAlias(const QString &alias) const;
    // The catalogue's character for a hexcode, e.g. "2764" -> "❤️". Rebuilding the
    // character from the hexcode instead would yield an unqualified sequence that renders
    // in a text font. Any spelling of the id is accepted (see canonicalUnicode), so ids
    // stored by older versions still resolve. Empty if unknown.
    Q_INVOKABLE QString getEmojiFromHexcode(const QString &hexcode) const;

    // The id the catalogue knows this emoji by, for any spelling of it: ids persisted by
    // older versions (recents) and ids coming from the backend (reactions) may carry or
    // omit U+FE0F and leading zeros, e.g. "31-20e3" is today's "0031-fe0f-20e3". Empty if
    // unknown.
    Q_INVOKABLE QString canonicalUnicode(const QString &hexcode) const;
    Q_INVOKABLE QJsonArray getSuggestions(const QString& name) const;
    Q_INVOKABLE int maxAsciiEmojiAliasLength() const;
    Q_INVOKABLE int getCategoryOffset(int categoryIndex) const;

    // One entry per section of the picker grid: { name, text, count, rows }, where `text`
    // holds the whole section's emoji as a single string. A grid that draws a section as one
    // text run gets everything it needs from this, instead of reading the model row by row
    // through a filtering proxy. `filter` matches name and shortname, case-insensitively;
    // `skinColor` picks which tone variant to show, the base one by default. `rows` are model
    // rows, for the single entry a hover or a click has to look up.
    Q_INVOKABLE QVariantList sections(const QString &filter = {},
                                      const QString &skinColor = {}) const;

    Q_INVOKABLE void addRecentEmoji(const QString &hexcode);

signals:
    void emojiJsonChanged();
    void recentEmojisChanged();
    void userUIDChanged();

private:
    QJsonArray emojiJson() const;
    void setEmojiJson(const QJsonArray &newEmojiJson);
    QJsonArray m_emojiJson;

    // Parses the catalogue if the queued load has not happened yet; every query calls it so
    // results never depend on load timing.
    void ensureLoaded() const;

    void rebuildLookupIndexes();
    QHash<QString, QString> m_asciiAliasToEmoji;
    QHash<QString, int> m_hexcodeToIndex;
    // normalised id -> the id the catalogue uses, so every spelling resolves
    QHash<QString, QString> m_canonicalToHexcode;
    int m_maxAsciiEmojiAliasLength = 0;

    // The catalogue entry for any spelling of `hexcode`, or a null value.
    QJsonValue entryForHexcode(const QString &hexcode) const;

    QStringList categories() const;
    QStringList categoryIcons() const;

    QStringList recentEmojis() const;
    void setRecentEmojis(const QStringList &newRecentEmojis);
    QStringList m_recentEmojis;
    QJsonArray m_recentEmojiJson;

    void cleanAndResizeRecentEmojis();
    void addRecentEmojisToModel(const QStringList &emojiHexcodes);

    QString recentCategoryName() const;
    QString baseSkinColorName() const;

    QString userUID() const;
    void setUserUID(const QString &newUserUID);
    QString m_userUID;

    QString settingsGroup() const;
    void saveRecentEmojis();
    void loadRecentEmojis();
};
