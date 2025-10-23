#include "StatusQ/urlutils.h"

#include <QDir>
#include <QFile>
#include <QImageReader>
#include <QStandardPaths>
#include <QUrl>

#ifdef Q_OS_IOS
#include "ios_utils.h"
#endif

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
    // don't convert "content:/" like URLs to an empty path
    const auto filePath = url.isLocalFile() ? url.toLocalFile() : url.toString();
    const auto mimeType = m_mimeDb.mimeTypeForFile(filePath, QMimeDatabase::MatchContent).name();

    return m_validImageMimeTypes.contains(mimeType);
}

qint64 UrlUtils::getFileSize(const QUrl& url)
{
    // don't convert "content:/" like URLs to an empty path
    const auto filePath = url.isLocalFile() ? url.toLocalFile() : url.toString();
    return QFile(filePath).size(); // will return 0 for unknown file paths
}

QString UrlUtils::convertUrlToLocalPath(const QString &url) const {
#ifdef Q_OS_ANDROID
    return resolveAndroidContentUrl(url);
#endif

    const auto localFileOrUrl = urlFromUserInput(url); // accept both "file:/foo/bar" and "/foo/bar"
    if (localFileOrUrl.isLocalFile()) {
#ifdef Q_OS_IOS
        return resolveIOSPhotoAsset(localFileOrUrl.toLocalFile());
#endif
        return localFileOrUrl.toLocalFile();
    }
    return {};
}

#ifdef Q_OS_ANDROID
QString UrlUtils::resolveAndroidContentUrl(const QString& urlPath) const {
    // test if we already have a real (resolved) path
    if (urlPath.startsWith('/'))
        return urlPath;

    // test if we already have a real (resolved) path in URL form
    if (urlPath.startsWith(QStringLiteral("file:/")))
        return urlFromUserInput(urlPath).toLocalFile();

    QDir dir(urlPath);
    if (urlPath.endsWith('/') || dir.exists())
        return urlPath; // a directory, just return it

    QFile fileIn(urlPath);
    if (!fileIn.open(QIODevice::ReadOnly))
        return urlPath;

    // save to a temp file, and return the filepath
    const auto newFilePath = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + '/' + QUuid::createUuid().toString(QUuid::WithoutBraces);
    QFile fileOut(newFilePath);
    if (!fileOut.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return urlPath;
    if (fileOut.write(fileIn.readAll()) != -1)
        return fileOut.fileName(); // return the real filename, not the virtual "content:/" URI

    return urlPath;
}
#endif

QStringList UrlUtils::convertUrlsToLocalPaths(const QStringList &urls) const {
    QStringList result;
    for (const auto& url: urls) {
        const auto localPath = convertUrlToLocalPath(url);
        if (!localPath.isEmpty())
            result << localPath;
    }
    return result;
}

QUrl UrlUtils::urlFromUserInput(const QString &input) const
{
    return QUrl::fromUserInput(input);
}
