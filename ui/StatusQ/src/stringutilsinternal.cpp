#include "StatusQ/stringutilsinternal.h"

#include <QDebug>
#include <QFile>
#include <QUrl>
#include <QTextDocumentFragment>

StringUtilsInternal::StringUtilsInternal(QObject* parent) : QObject(parent)
{
}

QString StringUtilsInternal::escapeHtml(const QString& unsafe) const
{
    return unsafe.toHtmlEscaped();
}

QString StringUtilsInternal::readTextFile(const QString& filePath) const
{
    auto maybeFileUrl = QUrl::fromUserInput(filePath);
    if (!maybeFileUrl.isLocalFile()) {
        qWarning() << Q_FUNC_INFO << "Error, opening remote files is not supported" << maybeFileUrl;
        return {};
    }

    QFile file(maybeFileUrl.toLocalFile()); // support local file URLs (e.g. "file:///foo/bar/baz.txt")
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << Q_FUNC_INFO << "Error opening existing file" << maybeFileUrl << "for reading";
        return {};
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

QString StringUtilsInternal::plainText(const QString& htmlFragment) const
{
    return QTextDocumentFragment::fromHtml(htmlFragment).toPlainText();
}
