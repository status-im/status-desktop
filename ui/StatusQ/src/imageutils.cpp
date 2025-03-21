#include "StatusQ/imageutils.h"

#include <QDebug>
#include <QEventLoop>
#include <QImage>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QUrl>
#include <QUuid>

namespace {
constexpr auto kBase64JPGPrefix = "data:image/jpeg;base64,";
}

ImageUtils::ImageUtils(QObject *parent)
    : QObject(parent)
{}

QString ImageUtils::resizeImage(const QString &imagePathOrData, int maxSize, const QString& tmpDirPath) const
{
    QImage img;
    bool loadResult = false;

    // load the contents
    if (imagePathOrData.startsWith(kBase64JPGPrefix)) { // binary BLOB
        loadResult = img.loadFromData(QByteArray::fromBase64(imagePathOrData.mid(qstrlen(kBase64JPGPrefix)).toLatin1())); // strip the prefix, decode from b64
    } else { // local file or URL
        const auto localFileOrUrl = QUrl::fromUserInput(imagePathOrData); // accept both "file:/foo/bar" and "/foo/bar"
        if (localFileOrUrl.isLocalFile()) {
            loadResult = img.load(localFileOrUrl.toLocalFile());
        } else {
            qWarning() << "ImageUtils::resizeImage: remote URLs are not supported:" << localFileOrUrl;
            return {};
        }
    }

    if (!loadResult) {
        qWarning() << "ImageUtils::resizeImage: failed to (down)load image";
        return {};
    }

    // scale it
    img = img.scaled(img.size().boundedTo(QSize(maxSize, maxSize)), Qt::KeepAspectRatio, Qt::SmoothTransformation);
    const auto newFilePath = tmpDirPath + '/' + QUuid::createUuid().toString(QUuid::WithoutBraces) + QStringLiteral(".jpg");
    if (img.save(newFilePath, "JPG"))
        return newFilePath;

    qWarning() << "ImageUtils::resizeImage: failed to save image to" << newFilePath;
    return {};
}

QStringList ImageUtils::resizeImages(const QStringList &imagePathsOrData, int maxSize, const QString &tmpDirPath) const
{
    QStringList result;
    for (const auto& imgPath: imagePathsOrData) {
        const auto resultPath = resizeImage(imgPath, maxSize, tmpDirPath);
        if (!resultPath.isEmpty())
            result.append(resultPath);
    }
    return result;
}
