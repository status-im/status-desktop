#include "StatusQ/clipboardutils.h"

#include <QBuffer>
#include <QClipboard>
#include <QFile>
#include <QGuiApplication>
#include <QImage>
#include <QMimeData>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QUrl>

#include <algorithm>

ClipboardUtils::ClipboardUtils()
{
    connect(QGuiApplication::clipboard(), &QClipboard::changed, this,
            [this](QClipboard::Mode mode) {
        if (mode == QClipboard::Clipboard)
            emit contentChanged();
    });
}

bool ClipboardUtils::hasText() const
{
    return QGuiApplication::clipboard()->mimeData()->hasText();
}

QString ClipboardUtils::text() const
{
    return QGuiApplication::clipboard()->text();
}

bool ClipboardUtils::hasHtml() const
{
    return QGuiApplication::clipboard()->mimeData()->hasHtml();
}

QString ClipboardUtils::html() const
{
    auto mimeData = QGuiApplication::clipboard()->mimeData();
    return mimeData ? mimeData->html() : QString{};
}

bool ClipboardUtils::hasImage() const
{
    return QGuiApplication::clipboard()->mimeData()->hasImage();
}

QImage ClipboardUtils::image() const
{
    return QGuiApplication::clipboard()->image();
}

QString ClipboardUtils::imageBase64() const
{
    if (!hasImage())
        return {};

    const auto img = image();
    QByteArray byteArray;
    QBuffer buffer(&byteArray);
    img.save(&buffer, "JPG");
    return QByteArrayLiteral("data:image/jpeg;base64,") + byteArray.toBase64();
}

bool ClipboardUtils::hasUrls() const
{
    return QGuiApplication::clipboard()->mimeData()->hasUrls();
}

QList<QUrl> ClipboardUtils::urls() const
{
    return QGuiApplication::clipboard()->mimeData()->urls();
}

void ClipboardUtils::setText(const QString &text)
{
    QGuiApplication::clipboard()->setText(text);
}

void ClipboardUtils::setImageByUrl(const QUrl &url)
{
    static thread_local QNetworkAccessManager manager;
    manager.setAutoDeleteReplies(true);

    QNetworkReply *reply = manager.get(QNetworkRequest(url));

    QObject::connect(reply, &QNetworkReply::finished, [reply]() {
        if(reply->error() == QNetworkReply::NoError) {
            QByteArray btArray = reply->readAll();
            QImage image;
            image.loadFromData(btArray);
            Q_ASSERT(!image.isNull());
            QGuiApplication::clipboard()->setImage(image);
        } else {
            qWarning() << "ClipboardUtils::setImageByUrl: Downloading image failed!";
        }
    });
}

void ClipboardUtils::clear()
{
    QGuiApplication::clipboard()->clear();
}

QObject* ClipboardUtils::qmlInstance(QQmlEngine* engine, QJSEngine* scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);

    return new ClipboardUtils;
}
