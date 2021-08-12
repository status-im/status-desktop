#ifndef STATUS_OS_THEME_EVENT_H
#define STATUS_OS_THEME_EVENT_H

#include "../DOtherSideTypes.h"

#include <QObject>
#include <QQmlApplicationEngine>

class StatusOSThemeEvent : public QObject
{
    Q_OBJECT

public:
    StatusOSThemeEvent(DosQQmlApplicationEngine* vptr, QObject* parent = nullptr);

protected:
    bool eventFilter(QObject* obj, QEvent* event) override;

private:
    QQmlApplicationEngine* m_engine;
};

#endif
