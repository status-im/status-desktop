#include "StatusQ/stringutilsinternal.h"

#include <QFile>
#include <QFileSelector>
#include <QQmlEngine>
#include <QQmlFileSelector>
#include <QUrl>

StringUtilsInternal::StringUtilsInternal(QQmlEngine* engine, QObject* parent)
    : m_engine(engine)
    , QObject(parent)
{ }

QString StringUtilsInternal::escapeHtml(const QString& unsafe) const
{
    return unsafe.toHtmlEscaped();
}

QString resolveFileUsingQmlImportPaths(QQmlEngine *engine, const QString &relativeFilePath) {
    QStringList importPaths = engine->importPathList();
    for (const auto &path : importPaths) {
        QString fullPath = path + "/" + relativeFilePath;
        QFile file(fullPath);
        if (file.exists()) {
            return fullPath;
        }
    }
    return "";
}

QString StringUtilsInternal::readTextFile(const QString& filePath) const
{
    auto selector = QQmlFileSelector::get(m_engine);
    if (!selector) {
        qWarning() << Q_FUNC_INFO << "No QQmlFileSelector available to load text file:" << filePath;
        return {};
    }

    const auto resolvedFilePath = selector->selector()->select(filePath);

    QFile file(resolvedFilePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        auto fileUrl = resolveFileUsingQmlImportPaths(m_engine, filePath);
        if (fileUrl.isEmpty()) {
            qWarning() << Q_FUNC_INFO << "Can't find file in QML import paths" << filePath;
            return {};
        }
        file.setFileName(fileUrl);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            qWarning() << Q_FUNC_INFO << "Error opening existing file" << fileUrl << "for reading";
            return {};
        }
    }

    return file.readAll();
}

QString StringUtilsInternal::extractDomainFromLink(const QString& link) const
{
    const auto url = QUrl::fromUserInput(link);
    if (!url.isValid()) {
        qWarning() << Q_FUNC_INFO << "Invalid URL:" << link;
        return {};
    }
    return url.host();
}
