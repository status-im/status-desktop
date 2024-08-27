#include "StatusQ/urlutils.h"

#include <QFile>
#include <QUrl>

#include <algorithm>

QObject* UrlUtils::qmlInstance(QQmlEngine*, QJSEngine*)
{
    return new UrlUtils;
}

bool UrlUtils::isValidImageUrl(const QUrl& url, const QStringList& acceptedExtensions)
{
    const auto strippedUrl = url.url(
                QUrl::RemoveAuthority | QUrl::RemoveFragment | QUrl::RemoveQuery);

    return std::any_of(acceptedExtensions.constBegin(),
                       acceptedExtensions.constEnd(),
                       [strippedUrl](const auto & ext) {
        return strippedUrl.endsWith(ext, Qt::CaseInsensitive);
    });
}

qint64 UrlUtils::getFileSize(const QUrl& url)
{
    if (url.isLocalFile())
        return QFile(url.toLocalFile()).size();

    return 0;
}
