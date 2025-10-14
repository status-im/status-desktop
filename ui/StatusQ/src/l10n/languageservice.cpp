#include "languageservice.h"

#include <QDir>

Q_LOGGING_CATEGORY(languageService, "status.languageService", QtInfoMsg)

using namespace Qt::Literals::StringLiterals;

LanguageService::LanguageService(QObject *parent)
    : QObject(parent)
{
    fetchAvailableLanguages();
}

QStringList LanguageService::availableLanguages() const
{
    return m_availableLanguages;
}

void LanguageService::fetchAvailableLanguages()
{
    m_availableLanguages.clear();

    QDir qmDir(":/i18n"_L1); // default prefix for QQmlApplicationEngine

    qCDebug(languageService) << Q_FUNC_INFO << "!!! Probing" << qmDir.absolutePath() << "for translations";

    const auto qmFiles = qmDir.entryInfoList({"*.qm"_L1}, QDir::Files | QDir::Readable);
    if (!qmFiles.isEmpty()) {
        qCDebug(languageService) << Q_FUNC_INFO << "!!! Found translations:" << qmFiles << "in" << qmDir.absolutePath();

        for (const auto& qmFile: qmFiles) {
            const auto langCode = qmFile.baseName().section('_', 1);
            qCDebug(languageService) << Q_FUNC_INFO << "!!! Adding language:" << langCode;
            m_availableLanguages.append(langCode);
        }
    }

    if (m_availableLanguages.isEmpty())
        qCWarning(languageService) << Q_FUNC_INFO << "!!! Didn't find any translation files to offer";

    emit availableLanguagesChanged();
}
