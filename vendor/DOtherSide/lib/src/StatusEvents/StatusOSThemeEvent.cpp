#include "DOtherSide/StatusEvents/StatusOSThemeEvent.h"

#include <QQuickWindow>

StatusOSThemeEvent::StatusOSThemeEvent(DosQQmlApplicationEngine* vptr, QObject* parent)
    : QObject(parent) 
{
    m_engine = static_cast<QQmlApplicationEngine*>(vptr);
}

bool StatusOSThemeEvent::eventFilter(QObject *obj, QEvent *event)
{
    if (event->type() == QEvent::PaletteChange ||
        event->type() == QEvent::ApplicationPaletteChange)
    {
        QObject* topLevelObj = m_engine->rootObjects().value(0);
        if(topLevelObj && topLevelObj->objectName() == "mainWindow")
        {
            QQuickWindow* window = qobject_cast<QQuickWindow *>(topLevelObj);
            if(window)
            {
                QMetaObject::invokeMethod(window, "changeThemeFromOutside");
                return true;
            }
        }
    }

    return QObject::eventFilter(obj, event);
}
