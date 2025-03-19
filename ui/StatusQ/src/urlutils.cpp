#include "StatusQ/urlutils.h"

#include <QFile>
#include <QImageReader>
#include <QUrl>

namespace {
constexpr auto webpMime = "image/webp";
}

UrlUtils::UrlUtils(QObject *parent): QObject(parent) {
    const auto webpSupported = QImageReader::supportedMimeTypes().contains(webpMime);
    if (webpSupported)
        m_validImageMimeTypes.append(webpMime);

    QStringList imgFilters;
    for (const auto& mime: std::as_const(m_validImageMimeTypes)) {
        const auto mimeData = m_mimeDb.mimeTypeForName(mime);
        imgFilters.append(mimeData.globPatterns());
        m_imgExtensions.append(mimeData.preferredSuffix());
        m_allImgExtensions.append(mimeData.suffixes());
    }

    m_imgFilters = imgFilters.join(' ');
    m_imgFilters.append(QStringLiteral(" "));
    m_imgFilters.append(m_imgFilters.toUpper()); // include the uppercase extensions too for case sensitive file systems
}

bool UrlUtils::isValidImageUrl(const QUrl &url) const
{
    QString mimeType;
    if (url.isLocalFile())
        mimeType = m_mimeDb.mimeTypeForFile(url.toLocalFile(), QMimeDatabase::MatchContent).name();
    else
        mimeType = m_mimeDb.mimeTypeForUrl(url).name();

    return m_validImageMimeTypes.contains(mimeType);
}

qint64 UrlUtils::getFileSize(const QUrl& url)
{
    if (url.isLocalFile())
        return QFile(url.toLocalFile()).size();

    return 0;
}

QString UrlUtils::convertUrlToLocalPath(const QString &url) const {
    const auto localFileOrUrl = QUrl::fromUserInput(url); // accept both "file:/foo/bar" and "/foo/bar"
    if (localFileOrUrl.isLocalFile()) {
        return localFileOrUrl.toLocalFile();
    }
    return {};
}

QStringList UrlUtils::convertUrlsToLocalPaths(const QStringList &urls) const {
    QStringList result;
    for (const auto& url: urls) {
        const auto localPath = convertUrlToLocalPath(url);
        if (!localPath.isEmpty())
            result << localPath;
    }
    return result;
}
