#pragma once

#include <QLoggingCategory>
#include <QObject>
#include <QQmlEngine>
#include <QTranslator>

#include <memory>

Q_DECLARE_LOGGING_CATEGORY(languageService)

class LanguageService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList availableLanguages READ availableLanguages CONSTANT FINAL)

public:
    explicit LanguageService(QQmlEngine *engine, QObject* parent = nullptr);

    Q_INVOKABLE bool setLanguage(const QString &newCurrentLanguage, bool shouldRetranslate = false);

private:
    QString m_currentLanguage;

    QStringList m_availableLanguages;
    QStringList availableLanguages() const;
    void fetchAvailableLanguages();

    QString m_qmDirPath;

    std::unique_ptr<QTranslator> m_translator;
    QQmlEngine* m_engine;
};
