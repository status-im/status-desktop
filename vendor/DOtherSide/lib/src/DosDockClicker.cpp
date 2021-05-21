#include "DOtherSide/DosDockClicker.h"

#include <QQuickWindow>
#include <QCoreApplication>


bool DockClicker::eventFilter(QObject *obj, QEvent *event)
{
#ifdef Q_OS_MACOS
    if (obj == qApp) {
        if (event->type() == QEvent::ApplicationStateChange) {
            auto ev = static_cast<QApplicationStateChangeEvent*>(event);
            if (_prevAppState == Qt::ApplicationActive && ev->applicationState() == Qt::ApplicationActive) {
                QObject *topLevel = _engine->rootObjects().value(0);
                QQuickWindow *window = qobject_cast<QQuickWindow *>(topLevel);
                window->setVisible(true);
                window->showNormal();
            }
            _prevAppState = ev->applicationState();
            return true;
        } else {
            return false;
        }
    }
#endif // Q_OS_MACOS
    return QObject::eventFilter(obj, event);
}
