#pragma once

#include <QLoggingCategory>
#include <QObject>
#include <QNetworkAccessManager>

Q_DECLARE_LOGGING_CATEGORY(languageService)

class LanguageService : public QObject
{
    Q_OBJECT
    ///< list of locally available translations (*.qm) as lang ISO codes
    Q_PROPERTY(QStringList availableLanguages READ availableLanguages NOTIFY availableLanguagesChanged FINAL)
    ///< Lokalise translation statistics, map of lang ISO codes to percent completed [langcode:string, percentage:int]
    Q_PROPERTY(QVariantMap lokaliseLanguages READ lokaliseLanguages NOTIFY lokaliseLanguagesChanged FINAL)

public:
    explicit LanguageService(QObject* parent = nullptr);

    Q_INVOKABLE void fetchAvailableLanguages();

signals:
    void availableLanguagesChanged();
    void lokaliseLanguagesChanged();

private:
    QStringList m_availableLanguages;
    QStringList availableLanguages() const;

    QVariantMap m_lokaliseLanguages;
    QVariantMap lokaliseLanguages() const;
    void fetchLokaliseLanguages();

    QNetworkAccessManager* m_qnam{nullptr};
};
