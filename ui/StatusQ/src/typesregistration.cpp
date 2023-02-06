#include "StatusQ/typesregistration.h"

#include "StatusQ/statuswindow.h"
#include "StatusQ/QClipboardProxy.h"

#include <QQmlEngine>

void registerStatusQTypes()
{
	qmlRegisterType<StatusWindow>("StatusQ", 0 , 1, "StatusWindow");
    qmlRegisterSingletonType<QClipboardProxy>("StatusQ", 0 , 1, "QClipboardProxy",
                                              &QClipboardProxy::qmlInstance);
}
