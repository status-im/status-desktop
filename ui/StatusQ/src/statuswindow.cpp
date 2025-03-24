#include "StatusQ/statuswindow.h"

#include <QQuickItem>

#include <QFileOpenEvent>

StatusWindow::StatusWindow(QWindow *parent)
    : QQuickWindow(parent)
{
    if (!windowStates().testFlag(Qt::WindowFullScreen))
        removeTitleBar();

    connect(this, &QQuickWindow::windowStateChanged, [&](Qt::WindowState windowState) {
        if (windowState == Qt::WindowFullScreen) {
            showTitleBar();
        } else {
            removeTitleBar();
        }
    });
}

void StatusWindow::restoreWindowState()
{
    setWindowStates(windowStates() & ~Qt::WindowMinimized);
}

void StatusWindow::toggleFullScreen()
{
    setWindowStates(windowStates() ^ Qt::WindowFullScreen);
}

void StatusWindow::toggleMinimize()
{
    setWindowStates(windowStates() ^ Qt::WindowMinimized);
}

bool StatusWindow::eventFilter(QObject *obj, QEvent *event)
{
    if (event->type() == QEvent::PaletteChange
        || event->type() == QEvent::ApplicationPaletteChange) {
        if (contentItem()->objectName() == QLatin1String("mainWindow")) {
            QMetaObject::invokeMethod(this, "changeThemeFromOutside");
        }
    }

    if (event->type() == QEvent::FileOpen) {
        auto fileEvent = static_cast<QFileOpenEvent *>(event);
        if (fileEvent) {
            emit urlActivated(fileEvent->url().toString());
        }
    }

    return QQuickWindow::eventFilter(obj, event);
}
