#include "DOtherSide/Status/DockShowAppEvent.h"

#include <QQuickWindow>


/*
    Code here is exactly the same as it was before, logic is not changed. I only 
    put it in another form, nothing else. To match an improved flow for 
    installing filters.
*/

using namespace Status;

DockShowAppEvent::DockShowAppEvent(DosQQmlApplicationEngine* vptr, 
    QObject* parent)
    : QObject(parent) 
{
    m_engine = static_cast<QQmlApplicationEngine*>(vptr);
}

bool DockShowAppEvent::eventFilter(QObject* obj, QEvent* event)
{
#ifdef Q_OS_MACOS
    if (event->type() == QEvent::ApplicationStateChange) 
    {
        auto ev = static_cast<QApplicationStateChangeEvent*>(event);
        if (m_prevAppState == Qt::ApplicationActive 
            && ev->applicationState() == Qt::ApplicationActive) 
        {
            QObject* topLevelObj = m_engine->rootObjects().value(0);
            if(topLevelObj && topLevelObj->objectName() == "mainWindow")
            {
                QQuickWindow* window = qobject_cast<QQuickWindow *>(topLevelObj);
                if(window)
                {
                    window->setVisible(true);
                    window->showNormal();
                    return true;
                }
            }
        }
        m_prevAppState = ev->applicationState();
    }
#endif

    return QObject::eventFilter(obj, event);
}
