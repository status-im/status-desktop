#include "languagemodel.h"

#include <QLocale>

namespace
{
constexpr auto kLanguageCodeRoleName = "code";
constexpr auto kfullIsoCodeCodeRoleName = "fullIsoCode";
constexpr auto kLanguageNameRoleName = "name";
constexpr auto kLanguagenativeNameRoleName = "nativeName";
}

LanguageModel::LanguageModel(QObject* parent) : QAbstractListModel(parent)
{
}

LanguageModel::LanguageModel(const QStringList &languageCodes, QObject *parent)
    : QAbstractListModel(parent), m_languageCodes(languageCodes)
{
    rebuildModel();
}

int LanguageModel::rowCount(const QModelIndex& parent) const { return m_data.size(); }

QHash<int, QByteArray> LanguageModel::roleNames() const
{
    static const QHash<int, QByteArray> roles{
        {CodeRole, kLanguageCodeRoleName},
        {NameRole, kLanguageNameRoleName},
        {NativeNameRole, kLanguagenativeNameRoleName},
    };

    return roles;
}

QVariant LanguageModel::data(const QModelIndex& index, int role) const
{
    if (!checkIndex(index,
                    QAbstractItemModel::CheckIndexOption::IndexIsValid |
                        QAbstractItemModel::CheckIndexOption::ParentIsInvalid))
        return {};

    const auto& language = m_data.at(index.row());

    switch (static_cast<LanguageDataRoles>(role)) {
    case CodeRole:
        return language.code;
    case FullIsoCode:
        return language.fullIsoCode;
    case NameRole:
        return language.name;
    case NativeNameRole:
        return language.nativeName;
    }
    return {};
}

QStringList LanguageModel::languageCodes() const
{
    return m_languageCodes;
}

void LanguageModel::setLanguageCodes(const QStringList &newLanguageCodes)
{
    if (m_languageCodes == newLanguageCodes)
        return;
    m_languageCodes = newLanguageCodes;
    emit languageCodesChanged();

    rebuildModel();
}

void LanguageModel::rebuildModel()
{
    beginResetModel();
    m_data.clear();
    m_data.reserve(m_languageCodes.size());

    // build the model
    for (const auto& langCode: std::as_const(m_languageCodes)) {
        QLocale loc(langCode);
        if (loc == QLocale::c()) // invalid
            continue;

        LanguageData data;
        data.code = langCode; // just the translation language, e.g. "fr"
        data.fullIsoCode = loc.name(); // including country, e.g. "fr_CA"
        data.name = QLocale::languageToString(loc.language()); // english language name, e.g. "French" for "fr"

        if (data.code == "en")
            data.nativeName = data.name; // just "English"
        else if (data.code == "pt_BR") // differentiate between "pt" and "pt_BR"
            data.nativeName = "português brasileiro";
        else
            data.nativeName = loc.nativeLanguageName(); // native language name, e.g. "français" for "fr" or "français canadien" for "fr_CA"

        m_data.append(data);
    }
    endResetModel();
}
