#pragma once

#include <QLoggingCategory>
#include <QObject>

Q_DECLARE_LOGGING_CATEGORY(languageService)

class LanguageService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList availableLanguages READ availableLanguages NOTIFY availableLanguagesChanged FINAL)

public:
    explicit LanguageService(QObject* parent = nullptr);

    Q_INVOKABLE void fetchAvailableLanguages();

signals:
    void availableLanguagesChanged();

private:
    QStringList m_availableLanguages;
    QStringList availableLanguages() const;
};
