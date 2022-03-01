#include "DOtherSide/Status/QClipboardProxy.h"

#include <QClipboard>

QClipboardProxy::QClipboardProxy(QClipboard* c) : clipboard(c)
{
    QObject::connect(c, SIGNAL (dataChanged()), this, SLOT(textChanged()));
}

QString QClipboardProxy::text() const
{
    return clipboard->text();
}
