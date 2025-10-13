#include "languageservice.h"

#include <QDir>
#include <QGuiApplication>

Q_LOGGING_CATEGORY(languageService, "status.languageService", QtInfoMsg)

LanguageService::LanguageService(QQmlEngine *engine, QObject *parent)
    : m_engine(engine)
{
    fetchAvailableLanguages();
}

bool LanguageService::setLanguage(const QString &newCurrentLanguage, bool shouldRetranslate)
{
    if (m_currentLanguage == newCurrentLanguage)
        return false;
    m_currentLanguage = newCurrentLanguage;

    qCDebug(languageService) << Q_FUNC_INFO << m_currentLanguage << shouldRetranslate;

    if (shouldRetranslate) {
        if (m_translator && !m_translator->isEmpty()) {
            qCDebug(languageService) << "!!! REMOVING PREV TRANSLATION:" << m_translator->language();
            bool result = qApp->removeTranslator(m_translator.get());
            qCDebug(languageService) << "!!! REMOVED OLD TRANSLATION:" << result;
        }
        m_translator.reset(new QTranslator);
        const auto qmFile = QStringLiteral("%1/qml_%2.qm").arg(m_qmDirPath, m_currentLanguage);
        qCDebug(languageService) << "!!! LOADING" << m_currentLanguage << "from:" << qmFile;

        if (!m_translator->load(qmFile))
            return false;

        qCDebug(languageService) << "!!! LOADED:" << qmFile;

        bool success = qApp->installTranslator(m_translator.get());
        qCDebug(languageService) << "!!! TRANSLATOR INSTALLED:" << success;
        if (!success)
            return false;

        if (m_engine) {
            m_engine->retranslate();
            qCDebug(languageService) << "!!! RETRANSLATED !!!";
        }
    }

    return true;
}

QStringList LanguageService::availableLanguages() const
{
    return m_availableLanguages;
}

void LanguageService::fetchAvailableLanguages()
{
    m_availableLanguages.clear();

    const auto appDirPath = qApp->applicationDirPath();

    qCDebug(languageService) << Q_FUNC_INFO << "!!! appDirPath BIN PATH:" << appDirPath;

    QDir qmDir(appDirPath);
    const auto pathsToProbe = {"i18n", "../i18n", "../resources/i18n", "Resources/i18n", "../../assets/i18n"};

    for (const auto& probePath: pathsToProbe) {
        qmDir.setPath(appDirPath % '/' % probePath);
        qCDebug(languageService) << Q_FUNC_INFO << "!!! Probing" << qmDir.absolutePath() << "for translations";
        if (!qmDir.exists())
            continue;

        const auto qmFiles = qmDir.entryInfoList({"*.qm"}, QDir::Files | QDir::Readable);
        if (!qmFiles.isEmpty()) {
            m_qmDirPath = qmDir.absolutePath();
            qCDebug(languageService) << Q_FUNC_INFO << "!!! Found translations:" << qmFiles << "in" << m_qmDirPath;

            for (const auto& qmFile: qmFiles) {
                const auto langCode = qmFile.baseName().section('_', 1);
                qCDebug(languageService) << Q_FUNC_INFO << "!!! Adding language:" << langCode;
                m_availableLanguages.append(langCode);
            }
            break;
        }
    }

    if (m_availableLanguages.isEmpty())
        qCWarning(languageService) << Q_FUNC_INFO << "!!! Didn't find any translation files to offer in" << pathsToProbe;
}
