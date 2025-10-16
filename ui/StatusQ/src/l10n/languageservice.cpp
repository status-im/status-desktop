#include "languageservice.h"

#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkReply>
#include <QNetworkRequest>

Q_LOGGING_CATEGORY(languageService, "status.languageService", QtInfoMsg)

using namespace Qt::Literals::StringLiterals;

LanguageService::LanguageService(QObject *parent)
    : QObject(parent)
    , m_qnam(new QNetworkAccessManager(this))
{
    fetchAvailableLanguages();
    fetchLokaliseLanguages();
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

QVariantMap LanguageService::lokaliseLanguages() const
{
    return m_lokaliseLanguages;
}

void LanguageService::fetchLokaliseLanguages()
{
    QNetworkRequest req(QUrl("https://api.lokalise.com/api2/projects/562366815b97551836b8f1.55149963"_L1));
    req.setHeaders(QHttpHeaders::fromListOfPairs({{"accept", "application/json"},
                                                  {"X-Api-Token", "59d26a505a4e2f0e975589e3208eda1f3241a278"}}));

    connect(m_qnam, &QNetworkAccessManager::finished, this, [&](QNetworkReply *reply) {
        m_lokaliseLanguages.clear();
        reply->deleteLater();

        if (reply->error() != QNetworkReply::NoError) {
            qCWarning(languageService) << Q_FUNC_INFO << "Error fetching Lokalise JSON statistics:" << reply->errorString();
            return;
        }

        QJsonParseError err;
        QJsonDocument doc = QJsonDocument::fromJson(reply->readAll(), &err);
        if (err.error != QJsonParseError::NoError) {
            qCWarning(languageService) << Q_FUNC_INFO << "Error parsing Lokalise JSON lang statistics:" << err.errorString();
            return;
        }

        QJsonObject rootObj(doc.object());
        if (rootObj.isEmpty()) {
            qCWarning(languageService) << Q_FUNC_INFO << "Lokalise JSON root object is empty";
            return;
        }
        QJsonObject statsObj = rootObj.value("statistics"_L1).toObject();
        if (statsObj.isEmpty()) {
            qCWarning(languageService) << Q_FUNC_INFO << "Lokalise JSON statistics object is empty";
            return;
        }

        const QJsonArray languagesArr(statsObj.value("languages"_L1).toArray());
        for (const auto& lang: languagesArr) {
            QJsonObject langObj(lang.toObject());
            m_lokaliseLanguages.insert(langObj.value("language_iso"_L1).toString(), langObj.value("progress"_L1).toInt(-1));
        }

        emit lokaliseLanguagesChanged();
    });

    m_qnam->get(req);
}
