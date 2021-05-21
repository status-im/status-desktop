#ifndef DOCKCLICKER_H
#define DOCKCLICKER_H

#include <QObject>

#include <QQmlApplicationEngine>
#include "DOtherSidetypes.h"

class DockClicker : public QObject
{
    Q_OBJECT

private:
    Qt::ApplicationState _prevAppState;
    QQmlApplicationEngine* _engine;

protected:
    bool eventFilter(QObject *obj, QEvent *event) override;

public:
    DockClicker(DosQQmlApplicationEngine *vptr) {
        auto engine = static_cast<QQmlApplicationEngine *>(vptr);
        _engine = engine;
    }
};

#endif // DOCKCLICKER_H
