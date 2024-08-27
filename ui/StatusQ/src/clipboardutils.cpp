#include "StatusQ/clipboardutils.h"

#include <QBuffer>
#include <QClipboard>
#include <QGuiApplication>
#include <QImage>
#include <QMimeData>
#include <QUrl>
#include <QFile>

#include <algorithm>

ClipboardUtils::ClipboardUtils()
    : m_clipboard(QGuiApplication::clipboard())
{
    connect(m_clipboard, &QClipboard::changed, this, [this](QClipboard::Mode mode) {
        if (mode == QClipboard::Clipboard)
            emit contentChanged();
    });
}

bool ClipboardUtils::hasText() const
{
    return m_clipboard->mimeData()->hasText();
}

QString ClipboardUtils::text() const
{
    return m_clipboard->text();
}

bool ClipboardUtils::hasHtml() const
{
    return m_clipboard->mimeData()->hasHtml();
}

QString ClipboardUtils::html() const
{
    auto mimeData = m_clipboard->mimeData();
    return mimeData ? mimeData->html() : QString{};
}

bool ClipboardUtils::hasImage() const
{
    return m_clipboard->mimeData()->hasImage();
}

QImage ClipboardUtils::image() const
{
    return m_clipboard->image();
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
    return m_clipboard->mimeData()->hasUrls();
}

QList<QUrl> ClipboardUtils::urls() const
{
    return m_clipboard->mimeData()->urls();
}

void ClipboardUtils::setText(const QString &text)
{
    m_clipboard->setText(text);
}

void ClipboardUtils::clear()
{
    m_clipboard->clear();
}
