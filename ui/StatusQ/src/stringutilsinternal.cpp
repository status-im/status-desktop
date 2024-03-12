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
    const auto importPaths = engine->importPathList();
    for (const auto &path : importPaths) {
        const auto fullPath = path + QStringLiteral("/") + relativeFilePath;
        QFile file(fullPath);
        if (file.exists()) {
            return fullPath;
        }
    }
    return {};
}

QString StringUtilsInternal::readTextFile(const QString& filePath) const
{
    auto selector = QQmlFileSelector::get(m_engine);
    if (!selector) {
        qWarning() << Q_FUNC_INFO << "No QQmlFileSelector available to load text file:" << filePath;
        return {};
    }

    QString selectedFilePath;
    const auto maybeFileUrl = QUrl(filePath).toLocalFile(); // support local file URLs (e.g. "file:///foo/bar/baz.txt")

    if (QFile::exists(maybeFileUrl))
        selectedFilePath = maybeFileUrl;
    else
        selectedFilePath = selector->selector()->select(filePath);

    if (selectedFilePath.startsWith(QLatin1String("qrc:/"))) // for some reason doesn't work with the "qrc:/" prefix, drop it
        selectedFilePath.remove(0, 3);

    QFile file(selectedFilePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        const auto resolvedFilePath = resolveFileUsingQmlImportPaths(m_engine, filePath);
        if (resolvedFilePath.isEmpty()) {
            qWarning() << Q_FUNC_INFO << "Can't find file in QML import paths" << filePath;
            return {};
        }
        file.setFileName(resolvedFilePath);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            qWarning() << Q_FUNC_INFO << "Error opening existing file" << resolvedFilePath << "for reading";
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
