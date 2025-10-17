#include "languagemodel.h"

using namespace Qt::Literals::StringLiterals;

namespace
{
constexpr auto kLanguageCodeRoleName = "code";
constexpr auto kfullIsoCodeCodeRoleName = "fullIsoCode";
constexpr auto kLanguageNameRoleName = "name";
constexpr auto kLanguagenativeNameRoleName = "nativeName";
constexpr auto kPercentRoleName = "percent";
}

LanguageModel::LanguageModel(QObject* parent)
    : QAbstractListModel(parent)
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
        {PercentRole, kPercentRoleName},
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
    case PercentRole:
        return m_lokalisedLanguageScores.value(language.code, -1).toInt();
    }
    return {};
}

QString LanguageModel::formattedNativeLanguageName(const QString &code, const QLocale& loc) const
{
    if (code == "en"_L1)
        return loc.languageToString(loc.language()); // just "English"
    if (code == "pt_BR"_L1) // differentiate between "pt" and "pt_BR"
        return u"Português Brasileiro"_s;
    return loc.nativeLanguageName(); // native language name, e.g. "français" for "fr" or "français canadien" for "fr_CA"
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
        data.nativeName = formattedNativeLanguageName(data.code, loc);

        m_data.append(data);
    }
    endResetModel();
}

QVariantMap LanguageModel::lokalisedLanguageScores() const
{
    return m_lokalisedLanguageScores;
}

void LanguageModel::setLokalisedLanguageScores(const QVariantMap &newLokalisedLanguageScores)
{
    if (m_lokalisedLanguageScores == newLokalisedLanguageScores)
        return;
    m_lokalisedLanguageScores = newLokalisedLanguageScores;
    emit lokalisedLanguageScoresChanged();
    emit dataChanged(createIndex(0, 0), createIndex(rowCount()-1, 0), {LanguageDataRoles::PercentRole});
}
