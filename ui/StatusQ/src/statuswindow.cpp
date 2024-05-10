#include "StatusQ/statuswindow.h"

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
