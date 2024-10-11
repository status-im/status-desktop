#include "StatusQ/systemutilsinternal.h"

#include <QCoreApplication>
#include <QDir>
#include <QMimeDatabase>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QProcess>
#include <QSaveFile>

SystemUtilsInternal::SystemUtilsInternal(QObject *parent)
    : QObject{parent}
{}

QString SystemUtilsInternal::qtRuntimeVersion() const {
    return qVersion();
}

void SystemUtilsInternal::restartApplication() const
{
    QProcess::startDetached(QCoreApplication::applicationFilePath(), {});
    QMetaObject::invokeMethod(QCoreApplication::instance(), "quit", Qt::QueuedConnection);
}

void SystemUtilsInternal::downloadImageByUrl(
        const QUrl& url, const QString& path) const
{
    static thread_local QNetworkAccessManager manager;
    manager.setAutoDeleteReplies(true);

    QNetworkReply *reply = manager.get(QNetworkRequest(QUrl(url)));

    // accept both "file:/foo/bar" and "/foo/bar"
    auto targetDir = QUrl::fromUserInput(path).toLocalFile();

    if (targetDir.isEmpty())
        targetDir = QDir::homePath();

    QObject::connect(reply, &QNetworkReply::finished, [reply, targetDir] {
        if(reply->error() != QNetworkReply::NoError) {
            qWarning() << "SystemUtilsInternal::downloadImageByUrl: Downloading image"
                       << reply->request().url() << "failed!";
            return;
        }

        // Extract the image data to be able to load and save it
        const auto btArray = reply->readAll();
        Q_ASSERT(!btArray.isEmpty());

        // Get current Date/Time information to use in naming of the image file
        const auto dateTimeString = QDateTime::currentDateTime().toString(
                    QStringLiteral("dd-MM-yyyy_hh-mm-ss"));

        // Get the preferred extension
        QMimeDatabase mimeDb;
        auto ext = mimeDb.mimeTypeForData(btArray).preferredSuffix();
        if (ext.isEmpty())
            ext = QStringLiteral("jpg");

        // Construct the target path
        const auto targetFile = QStringLiteral("%1/image_%2.%3").arg(
                    targetDir, dateTimeString, ext);

        // Save the image in a safe way
        QSaveFile image(targetFile);
        if (!image.open(QIODevice::WriteOnly)) {
            qWarning() << "SystemUtilsInternal::downloadImageByUrl: "
                          "Downloading image failed while opening the save file:"
                       << targetFile;
            return;
        }

        if (image.write(btArray) != -1)
            image.commit();
        else
            qWarning() << "SystemUtilsInternal::downloadImageByUrl: "
                          "Downloading image failed while saving to file:"
                       << targetFile;
    });
}
