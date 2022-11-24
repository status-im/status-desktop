#include "DOtherSide/Status/QClipboardProxy.h"

#include <QGuiApplication>
#include <QClipboard>

QClipboardProxy::QClipboardProxy()
{
    connect(QGuiApplication::clipboard(), &QClipboard::dataChanged, this, &QClipboardProxy::textChanged);
}

QString QClipboardProxy::text() const
{
    return QGuiApplication::clipboard()->text();
}
