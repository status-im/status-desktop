#ifndef STATUS_DOCK_SHOW_APP_EVENT_H
#define STATUS_DOCK_SHOW_APP_EVENT_H

#include "../DOtherSideTypes.h"

#include <QObject>
#include <QQmlApplicationEngine>

class StatusDockShowAppEvent : public QObject
{
    Q_OBJECT

public:
    StatusDockShowAppEvent(DosQQmlApplicationEngine* vptr, QObject* parent = nullptr);

protected:
    bool eventFilter(QObject* obj, QEvent* event) override;

private:
    Qt::ApplicationState m_prevAppState;
    QQmlApplicationEngine* m_engine;
};

#endif
