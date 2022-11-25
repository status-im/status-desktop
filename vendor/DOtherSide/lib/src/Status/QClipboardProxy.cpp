#include "DOtherSide/Status/QClipboardProxy.h"

#include <QBuffer>
#include <QClipboard>
#include <QGuiApplication>
#include <QImage>
#include <QMimeData>
#include <QUrl>

QClipboardProxy::QClipboardProxy()
    : m_clipboard(QGuiApplication::clipboard())
{
    connect(m_clipboard, &QClipboard::changed, this, [this](QClipboard::Mode mode) {
        if (mode == QClipboard::Clipboard)
            emit contentChanged();
    });
}

bool QClipboardProxy::hasText() const
{
    return m_clipboard->mimeData()->hasText();
}

QString QClipboardProxy::text() const
{
    return m_clipboard->text();
}

bool QClipboardProxy::hasHtml() const
{
    return m_clipboard->mimeData()->hasHtml();
}

QString QClipboardProxy::html() const
{
    return m_clipboard->mimeData()->html();
}

bool QClipboardProxy::hasImage() const
{
    return m_clipboard->mimeData()->hasImage();
}

QImage QClipboardProxy::image() const
{
    return m_clipboard->image();
}

QString QClipboardProxy::imageBase64() const
{
    if (!hasImage())
        return {};

    const auto img = image();
    QByteArray byteArray;
    QBuffer buffer(&byteArray);
    img.save(&buffer, "JPG");
    return QStringLiteral("data:image/jpeg;base64,") + byteArray.toBase64();
}

bool QClipboardProxy::hasUrls() const
{
    return m_clipboard->mimeData()->hasUrls();
}

QList<QUrl> QClipboardProxy::urls() const
{
    return m_clipboard->mimeData()->urls();
}
